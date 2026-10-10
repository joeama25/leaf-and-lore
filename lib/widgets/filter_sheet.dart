import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class BrowseFilterResult {
  final String genre;
  final double maximumPrice;
  const BrowseFilterResult({required this.genre, required this.maximumPrice});
}

class FilterSheet extends StatefulWidget {
  final String initialGenre;
  final double initialMaximumPrice;

  const FilterSheet({
    super.key,
    required this.initialGenre,
    required this.initialMaximumPrice,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  static const genres = [
    'All', 'Fiction', 'Mindfulness', 'Nature', 'Romance', 'Mystery', 'Science',
  ];
  late String _genre;
  late double _maximumPrice;

  @override
  void initState() {
    super.initState();
    _genre = widget.initialGenre;
    _maximumPrice = widget.initialMaximumPrice.clamp(0.0, 50.0).toDouble();
  }

  void _clear() {
    setState(() {
      _genre = 'All';
      _maximumPrice = 50;
    });
  }

  void _apply() {
    Navigator.of(context).pop(BrowseFilterResult(
      genre: _genre,
      maximumPrice: _maximumPrice,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Filter books', style: AppTextStyles.heading),
              const SizedBox(height: 24),
              const Text('GENRE', style: AppTextStyles.eyebrow),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 10,
                children: genres.map((genre) {
                  final selected = genre == _genre;
                  return ChoiceChip(
                    label: Text(genre),
                    selected: selected,
                    onSelected: (_) => setState(() => _genre = genre),
                    selectedColor: AppColors.forest,
                    backgroundColor: AppColors.white,
                    checkmarkColor: AppColors.white,
                    labelStyle: AppTextStyles.small.copyWith(
                      color: selected ? AppColors.white : AppColors.ink,
                    ),
                    side: BorderSide(color: selected ? AppColors.forest : AppColors.border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              const Text('PRICE RANGE', style: AppTextStyles.eyebrow),
              const SizedBox(height: 10),
              Text('Up to \$${_maximumPrice.round()}', style: AppTextStyles.body),
              Slider(
                value: _maximumPrice,
                min: 0, max: 50,
                divisions: 50,
                activeColor: AppColors.forest,
                inactiveColor: AppColors.sage,
                label: '\$${_maximumPrice.round()}',
                onChanged: (value) => setState(() => _maximumPrice = value),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Clear all'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply filters'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
