import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../../widgets/book_cover_placeholder.dart';

class BookDetailsScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  int _quantity = 1;
  bool _wishlisted = false;

int? _userId;
  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final id = await AuthService().currentUserId();
    if (id == null || widget.book.id == null) return;
    final saved =
    await WishlistService.instance.isWishlisted(id, widget.book.id!);
    if (!mounted) return;
    setState(() {
      _userId = id;
      _wishlisted = saved;
    });
  }

  Future<void> _toggleWishlist() async {
    final ok = await AuthGuard.requireLogin(context);
    if (!ok || !mounted) return;

    final id = await AuthService().currentUserId();
    if (id == null) return;

    await WishlistService.instance.toggle(id, widget.book);
    final saved =
    await WishlistService.instance.isWishlisted(id, widget.book.id!);
    if (!mounted) return;

    setState(() {
      _userId = id;
      _wishlisted = saved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_wishlisted ? 'Added to wishlist' : 'Removed from wishlist'),
      ),
    );
  }

  Future<void> _addToCart() async {
    final ok = await AuthGuard.requireLogin(context);
    if (!ok || !mounted) return;

    final id = await AuthService().currentUserId();
    if (id == null) return;

    await CartService.instance
        .addBook(id, widget.book, quantity: _quantity);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $_quantity to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _wishlisted ? Icons.favorite : Icons.favorite_border,
                      color: _wishlisted ? AppColors.danger : AppColors.ink,
                    ),
                    onPressed: _toggleWishlist,
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    child: Center(
                      child: BookCoverPlaceholder(
                        title: book.title,
                        author: book.author,
                        background: _coverColor(book.genre),
                        width: 220,
                        height: 320,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${book.genre.toUpperCase()} · LEAF & LORE EDITIONS',
                          style: AppTextStyles.eyebrow,
                        ),
                        const SizedBox(height: 10),
                        Text(book.title, style: AppTextStyles.display),
                        const SizedBox(height: 6),
                        Text('by ${book.author}',
                            style: AppTextStyles.bodyMuted),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: AppTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text('· ${book.reviewCount} reviews',
                                style: AppTextStyles.small),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${book.price.toStringAsFixed(2)}',
                              style: AppTextStyles.display
                                  .copyWith(fontSize: 28),
                            ),
                            const Spacer(),
                            Text('In stock · Ships in 1–2 days',
                                style: AppTextStyles.small),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 20),

                        Text('About this book',
                            style: AppTextStyles.heading),
                        const SizedBox(height: 12),
                        Text(book.description, style: AppTextStyles.body),
                        const SizedBox(height: 24),

                        _metaRow('Genre', book.genre),
                        _metaRow('Published', book.publishedDate),
                        _metaRow('Format', book.format),

                        const SizedBox(height: 32),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Text('Reader reviews',
                                  style: AppTextStyles.heading),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _reviewCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom bar ──────────────────────────
      bottomNavigationBar: Container(
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
                // Quantity stepper — working
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: _quantity > 1
                              ? AppColors.ink
                              : AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setState(() => _quantity++),
                        child: const Icon(Icons.add,
                            size: 16, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Add to cart
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 18, color: AppColors.white),
                        SizedBox(width: 8),
                        Text('Add to cart'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.forest,
                  ),
                  child: const Text('Buy now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.small)),
          Text(value,
              style:
              AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _reviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
                  (_) => const Icon(Icons.star,
                  color: AppColors.gold, size: 14),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '"A book I wanted to read slowly and never finish. So beautifully written."',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text('— Amelia R.', style: AppTextStyles.small),
        ],
      ),
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