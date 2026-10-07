import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../../widgets/book_cover_placeholder.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _checking = true;
  int? _userId;
  List<WishlistItem> _items = [];
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
    final items = await WishlistService.instance.getItems(_userId!);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
      _checking = false;
    });
  }

  Future<void> _signIn() async {
    final ok = await AuthGuard.requireLogin(context);
    if (!ok) return;
    final id = await AuthService().currentUserId();
    if (!mounted) return;
    setState(() => _userId = id);
    await _load();
  }

  Future<void> _remove(WishlistItem item) async {
    await WishlistService.instance.remove(_userId!, item.bookId);
    await _load();
  }

  Future<void> _moveToCart(WishlistItem item) async {
    final book = BookModel(
      id: item.bookId,
      title: item.title,
      author: item.author,
      genre: item.genre,
      description: '',
      coverImage: '',
      price: item.price,
      publishedDate: '',
    );
    await CartService.instance.addBook(_userId!, book);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
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
                _circleIcon(Icons.favorite_border),
                const SizedBox(height: 24),
                const Text('Save stories for later',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Sign in to keep a list of books you want to read.',
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
                      _circleIcon(Icons.favorite_border),
                      const SizedBox(height: 24),
                      const Text('No stories\nsaved yet.',
                          style: AppTextStyles.display,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                        'Tap the heart on any book to save it here.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted,
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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _items.length,
                itemBuilder: (_, i) => _tile(_items[i]),
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
          const Text('My wishlist', style: AppTextStyles.display),
          const SizedBox(height: 4),
          Text(
            '${_items.length} saved ${_items.length == 1 ? "story" : "stories"}',
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }

  Widget _tile(WishlistItem item) {
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
                Row(
                  children: [
                    Expanded(
                      child: Text(item.genre.toUpperCase(),
                          style: AppTextStyles.eyebrow),
                    ),
                    GestureDetector(
                      onTap: () => _remove(item),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.inkMuted),
                    ),
                  ],
                ),
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
                GestureDetector(
                  onTap: () => _moveToCart(item),
                  child: Row(
                    children: const [
                      Icon(Icons.add, size: 14, color: AppColors.forest),
                      SizedBox(width: 4),
                      Text('Add to cart',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forest,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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