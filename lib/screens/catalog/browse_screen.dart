import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/book_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _genre = 'All';
  final _searchCtrl = TextEditingController();

  static const _genres = [
    'All', 'Fiction', 'Mindfulness', 'Nature', 'Romance', 'Mystery', 'Science'
  ];

  @override
  Widget build(BuildContext context) {
    final books = MockData.byGenre(_genre);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Browse', style: AppTextStyles.display),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text('A good book is always waiting.',
                        style: AppTextStyles.bodyMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Search bar ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search books, authors, genres',
                  hintStyle: AppTextStyles.bodyMuted,
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.inkMuted, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Genre chips ────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final g = _genres[i];
                  final active = g == _genre;
                  return GestureDetector(
                    onTap: () => setState(() => _genre = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: active ? AppColors.forest : AppColors.white,
                        border: Border.all(
                          color: active ? AppColors.forest : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        g,
                        style: AppTextStyles.body.copyWith(
                          color: active ? AppColors.white : AppColors.ink,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Result count ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${books.length} books to discover',
                        style: AppTextStyles.small),
                  ),
                  _iconChip(Icons.filter_list, 'Filters'),
                  const SizedBox(width: 8),
                  _iconChip(Icons.sort, 'Sort'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Grid ───────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.48,
                ),
                itemCount: books.length,
                itemBuilder: (_, i) => BookCard(
                  book: books[i],
                  width: double.infinity,

                  onWishlist: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.ink),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.small.copyWith(
              color: AppColors.ink, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}