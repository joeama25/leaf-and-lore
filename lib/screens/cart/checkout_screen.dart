import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_method_model.dart';
import '../../services/address_service.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/payment_method_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../profile/add_address_screen.dart';
import '../profile/add_payment_screen.dart';
import 'order_placed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0;
  int? _userId;
  bool _loading = true;
  bool _placing = false;

  List<AddressModel> _addresses = [];
  List<PaymentMethodModel> _cards = [];
  List<CartItem> _items = [];

  AddressModel? _selectedAddress;
  PaymentMethodModel? _selectedCard;

  double get _subtotal => _items.fold(0.0, (s, i) => s + i.subtotal);
  double get _shipping => _subtotal > 50 ? 0 : 5.50;
  double get _total => _subtotal + _shipping;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await AuthService().currentUserId();
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final addrs = await AddressService.instance.getForUser(id);
      final cards = await PaymentMethodService.instance.getForUser(id);
      final items = await CartService.instance.getItems(id);
      if (!mounted) return;
      setState(() {
        _userId = id;
        _addresses = addrs;
        _cards = cards;
        _items = items;
        _selectedAddress = addrs.isNotEmpty ? addrs.first : null;
        _selectedCard = cards.isNotEmpty ? cards.first : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addAddress() async {
    if (_userId == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(userId: _userId!),
      ),
    );
    if (result == true) await _load();
  }

  Future<void> _addCard() async {
    if (_userId == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPaymentScreen(userId: _userId!),
      ),
    );
    if (result == true) await _load();
  }

  Future<void> _placeOrder() async {
    if (_userId == null ||
        _selectedAddress == null ||
        _selectedCard == null) {
      _snack('Select an address and a payment method');
      return;
    }
    if (_items.isEmpty) {
      _snack('Cart is empty');
      return;
    }
    setState(() => _placing = true);

    try {
      final orderNumber =
          'LL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final order = OrderModel(
        userId: _userId!,
        orderNumber: orderNumber,
        status: 'Pending',
        subtotal: _subtotal,
        shipping: _shipping,
        total: _total,
        shippingAddress: _selectedAddress!.oneLine,
        paymentMethod: _selectedCard!.masked,
        placedAt: DateTime.now().toIso8601String(),
      );

      final items = _items.map((c) => OrderItemModel(
        bookId: c.bookId,
        title: c.title,
        author: c.author,
        price: c.price,
        quantity: c.quantity,
        genre: c.genre,
        coverImage: c.coverImage,
      )).toList();

      // Atomic insert via service (transaction — all or nothing)
      final orderId = await OrderService.instance.add(order, items: items);

      // Clear cart AFTER successful order
      await CartService.instance.clear(_userId!);

      if (!mounted) return;

      // Build the persisted order for the next screen
      final placedOrder = OrderModel(
        id: orderId,
        userId: order.userId,
        orderNumber: orderNumber,
        status: order.status,
        subtotal: order.subtotal,
        shipping: order.shipping,
        total: order.total,
        shippingAddress: order.shippingAddress,
        paymentMethod: order.paymentMethod,
        placedAt: order.placedAt,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderPlacedScreen(order: placedOrder),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      _snack('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: AppTextStyles.heading),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _progressBar(),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: _stepBody(),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    const labels = ['Shipping', 'Payment', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (_step * 2) > i;
            return Expanded(
              child: Container(
                height: 1,
                color: done ? AppColors.forest : AppColors.border,
              ),
            );
          }
          final index = i ~/ 2;
          final done = index < _step;
          final current = index == _step;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: (done || current)
                      ? AppColors.forest
                      : AppColors.white,
                  border: Border.all(
                    color: (done || current)
                        ? AppColors.forest
                        : AppColors.border,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check,
                    size: 14, color: AppColors.white)
                    : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: current
                        ? AppColors.white
                        : AppColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[index],
                style: AppTextStyles.small.copyWith(
                  color: current
                      ? AppColors.forest
                      : AppColors.inkMuted,
                  fontWeight: current
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0: return _shippingStep();
      case 1: return _paymentStep();
      case 2: return _reviewStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _shippingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STEP 01', style: AppTextStyles.eyebrow),
        const SizedBox(height: 6),
        const Text('Shipping address', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text('Where should we send your stories?',
            style: AppTextStyles.bodyMuted),
        const SizedBox(height: 20),
        if (_addresses.isEmpty)
          Text('No saved addresses. Add one below.',
              style: AppTextStyles.bodyMuted)
        else
          for (final a in _addresses) _addressCard(a),
        const SizedBox(height: 12),
        _outlinedAction(Icons.add, 'Add new address', _addAddress),
      ],
    );
  }

  Widget _paymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STEP 02', style: AppTextStyles.eyebrow),
        const SizedBox(height: 6),
        const Text('Payment method', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text("Choose how you'd like to pay.",
            style: AppTextStyles.bodyMuted),
        const SizedBox(height: 20),
        if (_cards.isEmpty)
          Text('No saved cards. Add one below.',
              style: AppTextStyles.bodyMuted)
        else
          for (final c in _cards) _cardTile(c),
        const SizedBox(height: 12),
        _outlinedAction(Icons.add, 'Add payment method', _addCard),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.shield_outlined,
                size: 16, color: AppColors.inkMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your payment details are kept private and secure.',
                style: AppTextStyles.small,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STEP 03', style: AppTextStyles.eyebrow),
        const SizedBox(height: 6),
        const Text('Review your order', style: AppTextStyles.heading),
        const SizedBox(height: 20),
        for (final item in _items) _reviewItemRow(item),
        const SizedBox(height: 20),
        _infoRow(Icons.location_on_outlined, 'Delivering to',
            _selectedAddress?.oneLine ?? '—'),
        const SizedBox(height: 12),
        _infoRow(Icons.credit_card, 'Paying with',
            _selectedCard?.masked ?? '—'),
        const SizedBox(height: 24),
        _summaryBlock(),
      ],
    );
  }

  Widget _addressCard(AddressModel a) {
    final selected = _selectedAddress?.id == a.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.forest),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.label ?? 'Address',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(a.oneLine, style: AppTextStyles.small),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.forest, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _cardTile(PaymentMethodModel c) {
    final selected = _selectedCard?.id == c.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCard = c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.credit_card,
                size: 18, color: AppColors.forest),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.masked,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Expires ${c.expiry}',
                      style: AppTextStyles.small),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.forest, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _reviewItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.body),
                Text('Qty ${item.quantity} · ${item.author}',
                    style: AppTextStyles.small),
              ],
            ),
          ),
          Text('\$${item.subtotal.toStringAsFixed(2)}',
              style: AppTextStyles.body
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.forest),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.eyebrow),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryBlock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _row('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _row('Shipping', '\$${_shipping.toStringAsFixed(2)}'),
          const Divider(color: AppColors.border, height: 24),
          Row(
            children: [
              const Text('Total',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  )),
              const Spacer(),
              Text('\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.forest,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        const Spacer(),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }

  Widget _outlinedAction(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.forest),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.forest),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.forest, fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final canContinue = (_step == 0 && _selectedAddress != null) ||
        (_step == 1 && _selectedCard != null) ||
        (_step == 2 && _items.isNotEmpty);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              if (_step > 0) ...[
                OutlinedButton(
                  onPressed: _placing
                      ? null
                      : () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(90, 52),
                    side: const BorderSide(color: AppColors.forest),
                    foregroundColor: AppColors.forest,
                  ),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: (!canContinue || _placing)
                      ? null
                      : () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      _placeOrder();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _placing
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                      : Text(
                    _step < 2
                        ? 'Continue  →'
                        : 'Place order · \$${_total.toStringAsFixed(2)}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}