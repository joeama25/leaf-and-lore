
import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'order_placed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0;
  int? _userId;
  int? _selectedAddressId;
  String? _selectedPayment;
  List<AddressModel> _addresses = [];
  List<Map<String, dynamic>> _cards = [];
  List<CartItem> _items = [];
  bool _loading = true;
  bool _placingOrder = false;
  String? _error;

  static const double _shippingFee = 5.50;

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _shipping => _subtotal > 50 ? 0 : _shippingFee;

  double get _total => _subtotal + _shipping;

  AddressModel? get _selectedAddress {
    for (final address in _addresses) {
      if (address.id == _selectedAddressId) return address;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userId = await AuthService().currentUserId();

      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Please sign in before checking out.';
        });
        return;
      }

      final addresses = await AddressService.instance.getForUser(userId);
      final items = await CartService.instance.getItems(userId);
      final db = await DatabaseService.instance.database;

      final cards = await db.query(
        'payment_methods',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _addresses = addresses;
        _items = items;
        _cards = cards;
        _selectedAddressId =
        addresses.isNotEmpty ? addresses.first.id : null;
        _selectedPayment = cards.isNotEmpty
            ? 'card:${cards.first['id']}'
            : 'Cash on delivery';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load checkout: $e';
      });
    }
  }

  void _continue() {
    if (_step == 0 && _selectedAddress == null) {
      _message('Please select a shipping address.');
      return;
    }

    if (_step == 1 && _selectedPayment == null) {
      _message('Please select a payment method.');
      return;
    }

    if (_step < 2) {
      setState(() => _step++);
    } else {
      _placeOrder();
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _placeOrder() async {
    if (_userId == null || _selectedAddress == null ||
        _items.isEmpty || _selectedPayment == null) {
      _message('Please check your address, payment, and cart.');
      return;
    }

    setState(() => _placingOrder = true);

    try {
      final db = await DatabaseService.instance.database;
      final now = DateTime.now();
      final orderNumber =
          'LL${now.millisecondsSinceEpoch.toString()}';
      final address = _selectedAddress!;
      final payment = _selectedPayment!;

      final paymentLabel = payment.startsWith('card:')
          ? 'Saved card'
          : payment;

      final addressText =
          '${address.street}, ${address.city}, ${address.state}, '
          '${address.country}';

      final orderId = await db.transaction<int>((txn) async {
        final currentRows = await txn.query(
          'cart_items',
          where: 'user_id = ?',
          whereArgs: [_userId],
          orderBy: 'id DESC',
        );

        if (currentRows.isEmpty) {
          throw Exception('Your cart is empty.');
        }

        final currentItems =
        currentRows.map((row) => CartItem.fromMap(row)).toList();

        final subtotal = currentItems.fold<double>(
          0,
              (sum, item) => sum + item.subtotal,
        );
        final shipping = subtotal > 50 ? 0.0 : _shippingFee;
        final total = subtotal + shipping;

        final id = await txn.insert('orders', {
          'user_id': _userId,
          'order_number': orderNumber,
          'status': 'Pending',
          'subtotal': subtotal,
          'shipping': shipping,
          'total': total,
          'shipping_address': addressText,
          'payment_method': paymentLabel,
          'placed_at': now.toIso8601String(),
        });

        for (final item in currentItems) {
          await txn.insert('order_items', {
            'order_id': id,
            'book_id': item.bookId,
            'title': item.title,
            'author': item.author,
            'price': item.price,
            'quantity': item.quantity,
            'genre': item.genre,
          });
        }

        await txn.delete(
          'cart_items',
          where: 'user_id = ?',
          whereArgs: [_userId],
        );

        return id;
      });

      if (!mounted) return;

      setState(() => _placingOrder = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderPlacedScreen(
            orderId: orderId,
            orderNumber: orderNumber,
            total: _total,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _placingOrder = false);
      _message('Could not place order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Checkout', style: AppTextStyles.heading),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      )
          : _items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
        children: [
          _progress(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_step == 0) _shippingStep(),
                if (_step == 1) _paymentStep(),
                if (_step == 2) _reviewStep(),
              ],
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _progress() {
    const labels = ['Shipping', 'Payment', 'Review'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: List.generate(3, (index) {
          final active = index <= _step;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor:
                  active ? AppColors.forest : AppColors.border,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? AppColors.forest : AppColors.inkMuted,
                      fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (index < 2)
                  const Expanded(
                    child: Divider(
                      indent: 6,
                      endIndent: 6,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _shippingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Where should we send your books?',
            style: AppTextStyles.heading),
        const SizedBox(height: 8),
        Text('Choose a saved delivery address.',
            style: AppTextStyles.bodyMuted),
        const SizedBox(height: 20),
        if (_addresses.isEmpty)
          const Text(
            'You have no saved addresses. Add an address from your Profile '
                'before checking out.',
            style: AppTextStyles.bodyMuted,
          ),
        ..._addresses.map((address) {
          return Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _selectedAddressId == address.id
                    ? AppColors.forest
                    : AppColors.border,
              ),
            ),
            child: RadioListTile<int>(
              value: address.id!,
              groupValue: _selectedAddressId,
              activeColor: AppColors.forest,
              onChanged: (value) =>
                  setState(() => _selectedAddressId = value),
              title: Text(address.label ?? 'Delivery address'),
              subtitle: Text(
                '${address.street}, ${address.city}, '
                    '${address.state}, ${address.country}',
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _paymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How would you like to pay?',
            style: AppTextStyles.heading),
        const SizedBox(height: 8),
        Text('Select a payment method.',
            style: AppTextStyles.bodyMuted),
        const SizedBox(height: 20),
        ..._cards.map((card) {
          final value = 'card:${card['id']}';
          final number = card['card_number']?.toString() ?? '';
          final lastFour = number.length >= 4
              ? number.substring(number.length - 4)
              : number;

          return Card(
            color: Colors.white,
            elevation: 0,
            child: RadioListTile<String>(
              value: value,
              groupValue: _selectedPayment,
              activeColor: AppColors.forest,
              onChanged: (v) => setState(() => _selectedPayment = v),
              title: Text(
                '${card['brand'] ?? 'Card'} ending in $lastFour',
              ),
              subtitle: Text(
                'Expires ${card['expiry'] ?? 'not specified'}',
              ),
            ),
          );
        }),
        Card(
          color: Colors.white,
          elevation: 0,
          child: RadioListTile<String>(
            value: 'Cash on delivery',
            groupValue: _selectedPayment,
            activeColor: AppColors.forest,
            onChanged: (v) => setState(() => _selectedPayment = v),
            title: const Text('Cash on delivery'),
            subtitle: const Text('Pay when your order arrives.'),
          ),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review your order', style: AppTextStyles.heading),
        const SizedBox(height: 16),
        ..._items.map((item) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.title),
          subtitle: Text('${item.quantity} × \$'
              '${item.price.toStringAsFixed(2)}'),
          trailing: Text('\$${item.subtotal.toStringAsFixed(2)}'),
        )),
        const Divider(color: AppColors.border),
        _summaryRow('Subtotal', _subtotal),
        _summaryRow('Shipping', _shipping),
        const Divider(color: AppColors.border),
        _summaryRow('Total', _total, bold: true),
        const SizedBox(height: 20),
        const Text('Delivery address', style: AppTextStyles.title),
        const SizedBox(height: 6),
        Text(_selectedAddress?.oneLine ?? 'No address selected'),
        const SizedBox(height: 20),
        const Text('Payment method', style: AppTextStyles.title),
        const SizedBox(height: 6),
        Text(_selectedPayment ?? 'No payment method selected'),
      ],
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? AppColors.forest : AppColors.ink,
      fontSize: bold ? 18 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text('\$${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: _placingOrder
                  ? null
                  : () => setState(() => _step--),
              child: const Text('Back'),
            ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _placingOrder ? null : _continue,
              child: _placingOrder
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(_step == 2 ? 'Place order' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}