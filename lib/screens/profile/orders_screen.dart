import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../../widgets/book_cover_placeholder.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  int? _userId;
  List<OrderModel> _orders = [];
  Map<int, List<OrderItemModel>> _linesByOrder = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final userId = await AuthService().currentUserId();
      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _userId = null;
          _orders = [];
          _linesByOrder = {};
          _loading = false;
        });
        return;
      }
      final orders = await OrderService.instance.getForUser(userId);
      final items = await OrderService.instance.getItemsForUser(userId);
      final byOrder = <int, List<OrderItemModel>>{};
      for (final item in items) {
        if (item.orderId != null) {
          byOrder.putIfAbsent(item.orderId!, () => []).add(item);
        }
      }
      if (!mounted) return;
      setState(() {
        _userId = userId;
        _orders = orders;
        _linesByOrder = byOrder;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load orders. Please try again.')),
      );
    }
  }

  Future<void> _signIn() async {
    final ok = await AuthGuard.requireLogin(context);
    if (!mounted) return;
    if (ok) await _load();
  }

  Future<void> _openOrder(OrderModel order) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
    );
    if (!mounted) return;
    await _load();
  }

  String _date(String iso) {
    final parsed = DateTime.tryParse(iso);
    return parsed == null ? iso : DateFormat('MMM d, yyyy').format(parsed);
  }

  Widget _statusBadge(String status) {
    final complete = status.toLowerCase() == 'delivered';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: complete ? AppColors.sage : AppColors.creamDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: AppTextStyles.small.copyWith(
        color: AppColors.forest, fontWeight: FontWeight.w600,
      )),
    );
  }

  Widget _orderCard(OrderModel order) {
    final items = _linesByOrder[order.id] ?? const <OrderItemModel>[];
    final bookCount = items.fold<int>(0, (sum, item) => sum + item.quantity);
    return InkWell(
      onTap: () { _openOrder(order); },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('#${order.orderNumber}',
                style: AppTextStyles.title, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            _statusBadge(order.status),
          ]),
          const SizedBox(height: 12),
          if (items.isNotEmpty) ...[
            SizedBox(height: 72, child: Row(children: [
              for (final item in items.take(4)) ...[
                BookCoverPlaceholder(
                  title: item.title,
                  author: item.author,
                  background: AppColors.sage,
                  width: 49,
                  height: 68,
                ),
                const SizedBox(width: 8),
              ],
              if (items.length > 4)
                Text('+${items.length - 4}', style: AppTextStyles.small),
            ])),
            const SizedBox(height: 10),
          ],
          Row(children: [
            Expanded(child: Text(_date(order.placedAt),
                style: AppTextStyles.small)),
            Text('$bookCount ${bookCount == 1 ? "item" : "items"}',
                style: AppTextStyles.small),
          ]),
          const Divider(height: 24, color: AppColors.border),
          Row(children: [
            const Text('Total', style: AppTextStyles.bodyMuted),
            const Spacer(),
            Text('\$${order.total.toStringAsFixed(2)}',
              style: AppTextStyles.title.copyWith(color: AppColors.forest)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.inkMuted),
          ]),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.sage,
          child: Icon(Icons.local_shipping_outlined,
              size: 34, color: AppColors.forest),
        ),
        const SizedBox(height: 24),
        const Text('No orders yet', style: AppTextStyles.heading),
        const SizedBox(height: 10),
        Text('Your next favorite story is waiting to be discovered.',
          style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('My orders', style: AppTextStyles.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
                children: [
                  const Text('My orders', style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  const Text('Every story has a journey.',
                      style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 28),
                  if (_userId == null) ...[
                    _emptyState(),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign in to view orders'),
                    ),
                  ] else if (_orders.isEmpty)
                    _emptyState()
                  else
                    for (final order in _orders) _orderCard(order),
                ],
              ),
            ),
    );
  }
}
