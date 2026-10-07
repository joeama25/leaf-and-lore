import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../screens/catalog/book_details_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'book_cover_placeholder.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onWishlist;

  const BookCard({
    super.key,
    required this.book,
    this.width = 150,
    this.onTap,
    this.onWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailsScreen(book: book),
              ),
            );
          },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                BookCoverPlaceholder(
                  title: book.title,
                  author: book.author,
                  background: _coverColor(book.genre),
                  width: width,
                  height: width * 1.45,
                ),
                if (book.badge.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _badge(book.badge),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlist,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(book.genre.toUpperCase(), style: AppTextStyles.eyebrow),
            const SizedBox(height: 4),
            Text(
              book.title,
              style: AppTextStyles.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('by ${book.author}', style: AppTextStyles.small),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${book.price.toStringAsFixed(2)}',
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Icon(Icons.star, color: AppColors.gold, size: 14),
                const SizedBox(width: 3),
                Text(book.rating.toStringAsFixed(1),
                    style: AppTextStyles.small),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String badge) {
    final label = badge == 'bestseller'
        ? 'BESTSELLER'
        : badge == 'new'
        ? 'NEW'
        : "EDITOR'S PICK";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.forest,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 1,
        ),
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