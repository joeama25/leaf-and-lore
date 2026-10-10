import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../../widgets/book_cover_placeholder.dart';
import '../../utils/app_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _checking = true;
  int? _userId;
  List<CartItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final id = await AuthService().currentUserId();
    if (!mounted) return;
    setState(() => _userId = id);
    if (id != null) {
      await _load();
    } else {
      setState(() {
        _checking = false;
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    if (_userId == null) return;
    setState(() => _loading = true);
    try {
      final items = await CartService.instance.getItems(_userId!);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _checking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
        _checking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart error: $e')),
      );
    }
  }

  Future<void> _signIn() async {
    final ok = await AuthGuard.requireLogin(context);
    if (!ok) return;
    final id = await AuthService().currentUserId();
    if (!mounted) return;
    setState(() => _userId = id);
    await _load();
  }

  Future<void> _changeQty(CartItem item, int newQty) async {
    if (newQty < 1) return;
    await CartService.instance.updateQuantity(item.id!, newQty);
    await _load();
  }

  Future<void> _remove(CartItem item) async {
    await CartService.instance.remove(item.id!);
    await _load();
  }

  double get _subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.subtotal);
  double get _shipping => _subtotal > 50 ? 0 : 5.50;
  double get _total => _subtotal + _shipping;

  // Developer B owns the actual checkout flow; avoid a silent tap.
  void _showCheckoutUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout is coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_userId == null) return _guestView();
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_items.isEmpty) return _emptyView();
    return _filledView();
  }

  Widget _guestView() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circleIcon(Icons.shopping_bag_outlined),
                const SizedBox(height: 24),
                const Text('Your cart is waiting',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Sign in to save books and pick up where you left off.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign in  →'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _circleIcon(Icons.shopping_bag_outlined),
                      const SizedBox(height: 24),
                      const Text('Your cart feels\na little light.',
                          style: AppTextStyles.display,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                        'Wonderful stories are just around the corner. '
                            "Let's find your next read.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: ()=> AppState.selectedTab.value = 1,
                        child: const Text('Explore books'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filledView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  ..._items.map(_cartItemTile).toList(),
                  const SizedBox(height: 20),
                  _summaryBox(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showCheckoutUnavailable,
                    child: const Text('Proceed to checkout  →'),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => AppState.selectedTab.value = 1,
                      child: const Text('Continue shopping'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your cart', style: AppTextStyles.display),
          const SizedBox(height: 4),
          Text(
            '${_items.length} ${_items.length == 1 ? "book" : "books"} in your bag',
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  Widget _cartItemTile(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCoverPlaceholder(
            title: item.title,
            author: item.author,
            width: 70,
            height: 100,
            background: _coverColor(item.genre),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.genre.toUpperCase(),
                    style: AppTextStyles.eyebrow),
                const SizedBox(height: 4),
                Text(item.title,
                    style: AppTextStyles.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('by ${item.author}', style: AppTextStyles.small),
                const SizedBox(height: 8),
                Text('\$${item.price.toStringAsFixed(2)}',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _qtyButton(Icons.remove,
                            () => _changeQty(item, item.quantity - 1)),
                    const SizedBox(width: 12),
                    Text('${item.quantity}',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    _qtyButton(Icons.add,
                            () => _changeQty(item, item.quantity + 1)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _remove(item),
                      child: const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.ink),
      ),
    );
  }

  Widget _summaryBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order summary', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow('Shipping', '\$${_shipping.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
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

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodyMuted),
        const Spacer(),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.sage,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.forest, size: 32),
    );
  }

  Color _coverColor(String genre) {
    switch (genre) {
      case 'Mindfulness':
        return AppColors.tan;
      case 'Fiction':
        return AppColors.forest;
      case 'Science':
        return const Color(0xFF2A3D4F);
      case 'Nature':
        return const Color(0xFFE8E4D0);
      case 'Mystery':
        return const Color(0xFF1B2838);
      case 'Romance':
        return const Color(0xFFE3C7C7);
      default:
        return AppColors.tan;
    }
  }
}