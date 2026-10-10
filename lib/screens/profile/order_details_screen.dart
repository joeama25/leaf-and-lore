import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/book_cover_placeholder.dart';
import 'track_order_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _loading = true;
  OrderModel? _order;
  List<OrderItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final userId = await AuthService().currentUserId();
      if (userId == null || widget.order.id == null) {
        throw StateError('Order unavailable. Please sign in again.');
      }
      final order = await OrderService.instance.getById(widget.order.id!, userId);
      if (order == null) throw StateError('Order not found.');
      final items = await OrderService.instance.getItemsForOrder(order.id!, userId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load order details.')),
      );
    }
  }

  Future<void> _trackOrder() async {
    final order = _order;
    if (order == null) return;
    await Navigator.push<void>(context,
      MaterialPageRoute(builder: (_) => TrackOrderScreen(order: order)));
    if (!mounted) return;
    await _load();
  }

  String _date(String iso) {
    final parsed = DateTime.tryParse(iso);
    return parsed == null ? iso : DateFormat('MMMM d, yyyy').format(parsed);
  }

  Widget _section({required String title, required Widget child}) => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );

  Widget _summaryRow(String label, String value, {bool strong = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(label, style: strong ? AppTextStyles.body : AppTextStyles.bodyMuted),
          const Spacer(),
          Text(value, style: strong
              ? AppTextStyles.title.copyWith(color: AppColors.forest)
              : AppTextStyles.body),
        ]),
      );

  Widget _itemTile(OrderItemModel item) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      BookCoverPlaceholder(
        title: item.title,
        author: item.author,
        background: AppColors.sage,
        width: 62,
        height: 89,
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTextStyles.title,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('by ${item.author}', style: AppTextStyles.small),
          const SizedBox(height: 8),
          Text('Qty ${item.quantity}  ·  \$${item.price.toStringAsFixed(2)} each',
              style: AppTextStyles.small),
          const SizedBox(height: 5),
          Text('\$${item.lineTotal.toStringAsFixed(2)}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      )),
    ]),
  );

  Widget _header(OrderModel order) {
    final delivered = order.status.toLowerCase() == 'delivered';
    final pending = order.status.toLowerCase() == 'pending';
    final message = delivered
        ? 'Your stories have arrived.'
        : pending
            ? 'Your next chapter starts here.'
            : 'Your books are on their way.';
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ORDER #${order.orderNumber}', style: AppTextStyles.eyebrow
            .copyWith(color: AppColors.sage)),
        const SizedBox(height: 10),
        Text(order.status.toUpperCase(), style: AppTextStyles.small
            .copyWith(color: AppColors.gold, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(message, style: AppTextStyles.heading
            .copyWith(color: AppColors.white)),
        const SizedBox(height: 10),
        Text('Placed on ${_date(order.placedAt)}',
            style: AppTextStyles.bodyMuted.copyWith(color: AppColors.sage)),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: _trackOrder,
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text('Track order'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.sage),
          ),
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Order details', style: AppTextStyles.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Order details unavailable',
                      style: AppTextStyles.heading),
                  const SizedBox(height: 14),
                  TextButton(onPressed: _load, child: const Text('Try again')),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                    children: [
                      _header(order),
                      _section(title: 'Books in this order', child: Column(
                        children: _items.isEmpty
                            ? [const Text('No items found.', style: AppTextStyles.bodyMuted)]
                            : _items.map(_itemTile).toList(),
                      )),
                      _section(title: 'Delivery & payment', child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SHIPPING ADDRESS', style: AppTextStyles.eyebrow),
                          const SizedBox(height: 8),
                          Text(order.shippingAddress, style: AppTextStyles.body),
                          const SizedBox(height: 20),
                          const Text('PAYMENT METHOD', style: AppTextStyles.eyebrow),
                          const SizedBox(height: 8),
                          Text(order.paymentMethod, style: AppTextStyles.body),
                        ],
                      )),
                      _section(title: 'Order total', child: Column(children: [
                        _summaryRow('Subtotal',
                            '\$${order.subtotal.toStringAsFixed(2)}'),
                        _summaryRow('Shipping',
                            '\$${order.shipping.toStringAsFixed(2)}'),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 12),
                        _summaryRow('Total',
                            '\$${order.total.toStringAsFixed(2)}', strong: true),
                      ])),
                    ],
                  ),
                ),
    );
  }
}
