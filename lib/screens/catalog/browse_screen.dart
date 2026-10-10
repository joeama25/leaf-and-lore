import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/book_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_state.dart';
import '../../widgets/book_card.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/sort_sheet.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  static const _genres = [
    'All', 'Fiction', 'Mindfulness', 'Nature', 'Romance', 'Mystery', 'Science',
  ];
  String _genre = 'All';
  String _query = '';
  double _maximumPrice = 50;
  BrowseSort _sort = BrowseSort.mostPopular;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _genreScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final pending = AppState.pendingGenre.value;
    if (pending != null && _genres.contains(pending)) {
      _genre = pending;
      AppState.pendingGenre.value = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToGenre());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _genreScrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToGenre() {
    if (!mounted || !_genreScrollCtrl.hasClients) return;
    final selectedIndex = _genres.indexOf(_genre);
    if (selectedIndex < 0) return;
    // Each chip has 16px horizontal inset on each side and an 8px gap.
    double offset = 0;
    for (var i = 0; i < selectedIndex; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: _genres[i],
          style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        textDirection: Directionality.of(context),
      )..layout();
      offset += painter.width + 32 + 8;
      painter.dispose();
    }
    final maxScroll = _genreScrollCtrl.position.maxScrollExtent;
    _genreScrollCtrl.animateTo(
      offset.clamp(0.0, maxScroll).toDouble(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectGenre(String genre) {
    setState(() => _genre = genre);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToGenre());
  }

  List<BookModel> _visibleBooks() {
    final query = _query.trim().toLowerCase();
    final books = MockData.books.where((book) {
      final searchMatches = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query);
      // Text search overrides the genre chips, as specified in the brief.
      final genreMatches = query.isNotEmpty || _genre == 'All' || book.genre == _genre;
      return searchMatches && genreMatches && book.price <= _maximumPrice;
    }).toList();

    // MockData does not provide a sales counter. Use reviewCount as a
    // popularity proxy until Developer B exposes a real popularity field.
    switch (_sort) {
      case BrowseSort.mostPopular:
        books.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case BrowseSort.newest:
        books.sort((a, b) => _bookDate(b).compareTo(_bookDate(a)));
        break;
      case BrowseSort.oldest:
        books.sort((a, b) => _bookDate(a).compareTo(_bookDate(b)));
        break;
      case BrowseSort.highestRated:
        books.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case BrowseSort.priceLowToHigh:
        books.sort((a, b) => a.price.compareTo(b.price));
        break;
      case BrowseSort.priceHighToLow:
        books.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
    return books;
  }

  DateTime _bookDate(BookModel book) {
    // Current BookModel stores dates as e.g. 'March 2025'.
    final parts = book.publishedDate.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return DateTime(1900);
    const months = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    final month = months.indexOf(parts[0].toLowerCase()) + 1;
    final year = int.tryParse(parts.last);
    return year == null || month == 0 ? DateTime(1900) : DateTime(year, month);
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<BrowseFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => FilterSheet(
        initialGenre: _genre,
        initialMaximumPrice: _maximumPrice,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _genre = result.genre;
      _maximumPrice = result.maximumPrice;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToGenre());
  }

  Future<void> _openSort() async {
    final result = await showModalBottomSheet<BrowseSort>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SortSheet(selected: _sort),
    );
    if (!mounted || result == null) return;
    setState(() => _sort = result);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _genre = 'All';
      _maximumPrice = 50;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToGenre());
  }

  @override
  Widget build(BuildContext context) {
    final books = _visibleBooks();
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                const Expanded(child: Text('Browse', style: AppTextStyles.display)),
                IconButton(
                  tooltip: 'Focus search',
                  onPressed: () {
                    _searchFocus.requestFocus();
                  },
                  icon: const Icon(Icons.search, color: AppColors.ink),
                ),
              ]),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('A good book is always waiting.', style: AppTextStyles.bodyMuted),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (value) => setState(() => _query = value),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search books, authors, genres',
                  hintStyle: AppTextStyles.bodyMuted,
                  prefixIcon: const Icon(Icons.search, color: AppColors.inkMuted, size: 20),
                  suffixIcon: _query.isEmpty ? null : IconButton(
                    tooltip: 'Clear search',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close, color: AppColors.inkMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                controller: _genreScrollCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final genre = _genres[index];
                  final active = genre == _genre;
                  return GestureDetector(
                    onTap: () => _selectGenre(genre),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: active ? AppColors.forest : AppColors.white,
                        border: Border.all(color: active ? AppColors.forest : AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(genre, style: AppTextStyles.body.copyWith(
                        color: active ? AppColors.white : AppColors.ink,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: Text('${books.length} books to discover', style: AppTextStyles.small)),
                _iconChip(Icons.filter_list, 'Filters', _openFilters),
                const SizedBox(width: 8),
                _iconChip(Icons.sort, 'Sort', _openSort),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: books.isEmpty
                  ? _emptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.46,
                      ),
                      itemCount: books.length,
                      itemBuilder: (_, i) => BookCard(book: books[i], width: double.infinity),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76, width: 76,
              decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
              child: const Icon(Icons.search, size: 34, color: AppColors.forest),
            ),
            const SizedBox(height: 20),
            const Text('No books found', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            const Text(
              'Try searching for another title, author or genre.',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: AppColors.ink),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.small.copyWith(
            color: AppColors.ink, fontWeight: FontWeight.w500,
          )),
        ]),
      ),
    );
  }
}
