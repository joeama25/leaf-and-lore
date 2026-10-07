import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/book_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../../widgets/book_cover_placeholder.dart';

class BookDetailsScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.favorite_border,
                        color: AppColors.ink),
                    onPressed: () async {
                      final ok = await AuthGuard.requireLogin(context);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to wishlist')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Big cover on cream background
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

                  // Meta + title
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

                        // Rating row
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text('· ${book.reviewCount} reviews',
                                style: AppTextStyles.small),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Price + stock row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${book.price.toStringAsFixed(2)}',
                              style: AppTextStyles.display.copyWith(
                                  fontSize: 28),
                            ),
                            const Spacer(),
                            Text(
                              'In stock · Ships in 1–2 days',
                              style: AppTextStyles.small,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 20),

                        Text('About this book',
                            style: AppTextStyles.heading),
                        const SizedBox(height: 12),
                        Text(
                          book.description,
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 24),

                        // Meta table
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

      // ── Bottom bar: quantity + add to cart ──
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
                // Quantity stepper
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
                    children: const [
                      Icon(Icons.remove, size: 16, color: AppColors.ink),
                      SizedBox(width: 12),
                      Text('1',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          )),
                      SizedBox(width: 12),
                      Icon(Icons.add, size: 16, color: AppColors.ink),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Add to cart
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await AuthGuard.requireLogin(context);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      }
                    },
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

                // Buy now (text button)
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
          Expanded(
            child: Text(label, style: AppTextStyles.small),
          ),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
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
                  (_) => const Icon(Icons.star, color: AppColors.gold, size: 14),
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