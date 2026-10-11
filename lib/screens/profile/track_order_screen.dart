import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class TrackOrderScreen extends StatefulWidget {
  final OrderModel order;
  const TrackOrderScreen({super.key, required this.order});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  bool _loading = true;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final id = await AuthService().currentUserId();
      if (id == null || widget.order.id == null) {
        throw StateError('Please sign in again.');
      }
      final order = await OrderService.instance.getById(widget.order.id!, id);
      if (order == null) throw StateError('Order not found.');
      if (!mounted) return;
      setState(() { _order = order; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not refresh order status.')),
      );
    }
  }

  Widget _step(String label, int index, int current, bool last) {
    final completed = current >= index;
    final isCurrent = current == index;
    final tone = completed ? AppColors.forest : AppColors.border;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: completed ? AppColors.forest : AppColors.cream,
            shape: BoxShape.circle, border: Border.all(color: tone, width: 2)),
          child: Icon(completed ? Icons.check : Icons.circle_outlined,
              color: completed ? AppColors.white : AppColors.inkMuted, size: 17),
        ),
        if (!last)
          Container(height: 40, width: 2,
              color: current > index ? AppColors.forest : AppColors.border),
      ]),
      const SizedBox(width: 16),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.body.copyWith(
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: completed ? AppColors.ink : AppColors.inkMuted)),
          if (isCurrent)
            Text('Current status', style: AppTextStyles.small
                .copyWith(color: AppColors.forest)),
        ]),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Track order', style: AppTextStyles.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(child: TextButton(
                  onPressed: _load, child: const Text('Unable to load. Try again.')))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 40),
                    children: [
                      const CircleAvatar(
                        radius: 33,
                        backgroundColor: AppColors.sage,
                        child: Icon(Icons.local_shipping_outlined,
                            color: AppColors.forest, size: 34),
                      ),
                      const SizedBox(height: 22),
                      const Center(child: Text('ORDER STATUS',
                          style: AppTextStyles.eyebrow)),
                      const SizedBox(height: 10),
                      const Text('A little closer to your doorstep.',
                          style: AppTextStyles.heading, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Center(child: Text('Order #${order.orderNumber}',
                          style: AppTextStyles.bodyMuted)),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(children: [
                          for (var i = 0; i < OrderService.statuses.length; i++)
                            _step(OrderService.statuses[i], i,
                                OrderService.statuses.indexOf(order.status),
                                i == OrderService.statuses.length - 1),
                        ]),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.sage,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline, color: AppColors.forest),
                          const SizedBox(width: 12),
                          Expanded(child: Text(
                            'This timeline reflects the order status saved in the app. '
                            'Pull down to check for local updates.',
                            style: AppTextStyles.small.copyWith(color: AppColors.forest),
                          )),
                        ]),
                      ),
                    ],
                  ),
                ),
    );
  }
}
