import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

enum BrowseSort {
  mostPopular,
  newest,
  oldest,
  highestRated,
  priceLowToHigh,
  priceHighToLow,
}

extension BrowseSortLabel on BrowseSort {
  String get label {
    switch (this) {
      case BrowseSort.mostPopular: return 'Most Popular';
      case BrowseSort.newest: return 'Newest';
      case BrowseSort.oldest: return 'Oldest';
      case BrowseSort.highestRated: return 'Highest Rated';
      case BrowseSort.priceLowToHigh: return 'Price: Low to High';
      case BrowseSort.priceHighToLow: return 'Price: High to Low';
    }
  }
}

class SortSheet extends StatelessWidget {
  final BrowseSort selected;
  const SortSheet({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 42, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 22),
            const Text('Sort books', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            ...BrowseSort.values.map((option) => RadioListTile<BrowseSort>(
              title: Text(option.label, style: AppTextStyles.body),
              value: option,
              groupValue: selected,
              activeColor: AppColors.forest,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                if (value != null) Navigator.of(context).pop(value);
              },
            )),
          ],
        ),
      ),
    );
  }
}
