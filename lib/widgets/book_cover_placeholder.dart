import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BookCoverPlaceholder extends StatelessWidget {
  final String title;
  final String author;
  final Color background;
  final double width;
  final double height;

  const BookCoverPlaceholder({
    super.key,
    required this.title,
    required this.author,
    this.background = AppColors.tan,
    this.width = 150,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-pick text color based on background brightness
    final isDark = background.computeLuminance() < 0.5;
    final mainText = isDark ? AppColors.white : AppColors.ink;
    final mutedText = isDark
        ? AppColors.white.withOpacity(0.7)
        : AppColors.ink.withOpacity(0.6);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
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