import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class SortSheet extends StatelessWidget {
  final String current;
  const SortSheet({super.key, required this.current});

  static const options = [
    'Most Popular',
    'Newest',
    'Oldest',
    'Highest Rated',
    'Price: Low to High',
    'Price: High to Low',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Sort by', style: AppTextStyles.heading),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final opt in options)
            GestureDetector(
              onTap: () => Navigator.pop(context, opt),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: opt == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: opt == current
                              ? AppColors.forest
                              : AppColors.ink,
                        ),
                      ),
                    ),
                    if (opt == current)
                      const Icon(Icons.check,
                          color: AppColors.forest, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}