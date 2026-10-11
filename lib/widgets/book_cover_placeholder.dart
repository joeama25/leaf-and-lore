import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BookCoverPlaceholder extends StatelessWidget {
  final String title;
  final String author;
  final Color background;
  final double? width;
  final double? height;
  final String? imagePath;

  const BookCoverPlaceholder({
    super.key,
    required this.title,
    required this.author,
    this.background = AppColors.tan,
    this.width,
    this.height,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = background.computeLuminance() < 0.5;
    final mainText = isDark ? AppColors.white : AppColors.ink;
    final mutedText = isDark
        ? AppColors.white.withOpacity(0.7)
        : AppColors.ink.withOpacity(0.6);
    final compact = (width ?? double.infinity) < 100;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        color: background,
        child: imagePath != null && imagePath!.isNotEmpty
            ? Image.asset(
          imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _fallback(mainText, mutedText, compact),
        )
            : _fallback(mainText, mutedText, compact),
      ),
    );
  }

  Widget _fallback(Color mainText, Color mutedText, bool compact) {
    if (compact) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'LEAF & LORE EDITIONS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 6,
              fontWeight: FontWeight.w600,
              color: mutedText,
              letterSpacing: 1.5,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mainText,
                  height: 1.1,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                author.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: mutedText,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}