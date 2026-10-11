import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});
  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  static const _statuses = [
    'Pending', 'Processing', 'Shipped', 'Out for Delivery', 'Delivered'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = await DatabaseService.instance.database;
      final rows = await db.query('orders', orderBy: 'id DESC');
      if (!mounted) return;
      setState(() {
        _orders = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(Map<String, dynamic> order) async {
    final current = order['status'] as String? ?? 'Pending';
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Update status',
                      style: AppTextStyles.heading),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final s in _statuses)
              _statusOption(s, s == current),
          ],
        ),
      ),
    );

    if (picked == null || picked == current) return;

    final db = await DatabaseService.instance.database;
    await db.update(
      'orders',
      {'status': picked},
      where: 'id = ?',
      whereArgs: [order['id']],
    );
    _load();
  }

  Widget _statusOption(String status, bool active) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: active ? AppColors.forest : AppColors.border,
            width: active ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(child: Text(status, style: AppTextStyles.body)),
            if (active)
              const Icon(Icons.check, size: 18, color: AppColors.forest),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: const [
                  Expanded(
                    child: Text('Orders', style: AppTextStyles.heading),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Manage customer orders',
                      style: AppTextStyles.small),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _orders.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _orders.length,
                itemBuilder: (_, i) => _orderRow(_orders[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: AppColors.sage,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.forest, size: 32),
            ),
            const SizedBox(height: 20),
            const Text('No orders yet', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text('Orders from customers will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
    );
  }

  Widget _orderRow(Map<String, dynamic> o) {
    final status = o['status'] as String? ?? 'Pending';
    return GestureDetector(
      onTap: () => _changeStatus(o),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    o['order_number'] as String? ?? '—',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _statusChip(status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Placed ${_shortDate(o['placed_at'] as String?)}',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    o['shipping_address'] as String? ?? '',
                    style: AppTextStyles.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${(o['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Pending':
        bg = AppColors.tan;
        fg = AppColors.ink;
        break;
      case 'Processing':
        bg = AppColors.gold;
        fg = AppColors.ink;
        break;
      case 'Shipped':
        bg = AppColors.sage;
        fg = AppColors.forest;
        break;
      case 'Out for Delivery':
        bg = AppColors.forest;
        fg = AppColors.white;
        break;
      case 'Delivered':
        bg = AppColors.forest;
        fg = AppColors.white;
        break;
      default:
        bg = AppColors.sage;
        fg = AppColors.forest;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  String _shortDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '—';
    }
  }
}