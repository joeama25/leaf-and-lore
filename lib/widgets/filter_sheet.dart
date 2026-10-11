import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class FilterResult {
  final String genre;
  final double maxPrice;
  FilterResult(this.genre, this.maxPrice);
}

class FilterSheet extends StatefulWidget {
  final String initialGenre;
  final double initialMaxPrice;

  const FilterSheet({
    super.key,
    required this.initialGenre,
    required this.initialMaxPrice,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  static const _genres = [
    'All', 'Fiction', 'Mindfulness', 'Nature', 'Romance', 'Mystery', 'Science'
  ];
  late String _genre;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _genre = widget.initialGenre;
    _maxPrice = widget.initialMaxPrice;
  }

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
                child: Text('Filter books', style: AppTextStyles.heading),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('GENRE', style: AppTextStyles.eyebrow),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _genres.map((g) {
              final active = g == _genre;
              return GestureDetector(
                onTap: () => setState(() => _genre = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.forest : AppColors.white,
                    border: Border.all(
                      color: active ? AppColors.forest : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    g,
                    style: AppTextStyles.body.copyWith(
                      color: active ? AppColors.white : AppColors.ink,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('PRICE RANGE', style: AppTextStyles.eyebrow),
              const Spacer(),
              Text('Up to \$${_maxPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.small),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 0, max: 50, divisions: 50,
            activeColor: AppColors.forest,
            onChanged: (v) => setState(() => _maxPrice = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _genre = 'All';
                    _maxPrice = 50;
                  }),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.forest),
                    foregroundColor: AppColors.forest,
                  ),
                  child: const Text('Clear all'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    FilterResult(_genre, _maxPrice),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}