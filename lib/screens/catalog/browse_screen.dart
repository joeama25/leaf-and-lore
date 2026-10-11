import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/book_card.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/sort_sheet.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _genre = 'All';
  String _query = '';
  double _maxPrice = 50;
  String _sort = 'Most Popular';
  List<BookModel> _allBooks = [];
  bool _loading = true;
  bool _pendingScroll = false;
  final _chipScrollCtrl = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};

  static const _genres = [
    'All', 'Fiction', 'Mindfulness', 'Nature', 'Romance', 'Mystery', 'Science'
  ];

  @override
  void initState() {
    super.initState();
    for (final g in _genres) {
      _chipKeys[g] = GlobalKey();
    }

    final pending = AppState.pendingGenre.value;
    if (pending != null && _genres.contains(pending)) {
      _genre = pending;
      AppState.pendingGenre.value = null;
      _pendingScroll = true;      // defer until after load completes
    }
    _load();
  }

  void _scrollToSelectedChip() {
    final key = _chipKeys[_genre];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.35,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _load() async {
    try {
      final books = await BookService.instance.getAll();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _loading = false;
      });

      // Chips are now in the tree — safe to scroll
      if (_pendingScroll) {
        _pendingScroll = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedChip();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<BookModel> get _filtered {
    var list = _genre == 'All'
        ? _allBooks
        : _allBooks.where((b) => b.genre == _genre).toList();

    final q = _query.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((b) =>
      b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.genre.toLowerCase().contains(q),
      ).toList();
    }

    list = list.where((b) => b.price <= _maxPrice).toList();
    list = List<BookModel>.from(list);

    switch (_sort) {
      case 'Newest':
        list.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
        break;
      case 'Oldest':
        list.sort((a, b) => a.publishedDate.compareTo(b.publishedDate));
        break;
      case 'Highest Rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Most Popular':
      default:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }
    return list;
  }

  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        initialGenre: _genre,
        initialMaxPrice: _maxPrice,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _genre = result.genre;
        _maxPrice = result.maxPrice;
      });
    }
  }

  Future<void> _openSort() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortSheet(current: _sort),
    );
    if (picked != null && mounted) {
      setState(() => _sort = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final books = _filtered;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: const [
                  Expanded(
                    child: Text('Browse', style: AppTextStyles.display),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('A good book is always waiting.',
                  style: AppTextStyles.bodyMuted),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
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
            SizedBox(
              height: 40,
              child: SingleChildScrollView(
                controller: _chipScrollCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (int i = 0; i < _genres.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _chip(_genres[i]),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${books.length} books to discover',
                        style: AppTextStyles.small),
                  ),
                  _iconChip(Icons.filter_list, 'Filters', _openFilter),
                  const SizedBox(width: 8),
                  _iconChip(Icons.sort, 'Sort', _openSort),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: books.isEmpty
                  ? _emptyState()
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.46,
                ),
                itemCount: books.length,
                itemBuilder: (_, i) => BookCard(
                  book: books[i],
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String g) {
    final active = g == _genre;
    return GestureDetector(
      key: _chipKeys[g],
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
  }

  Widget _iconChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(label,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: AppColors.sage,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search,
                  color: AppColors.forest, size: 32),
            ),
            const SizedBox(height: 24),
            const Text('No books found',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Try searching for another title, author or genre.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {
                _query = '';
                _genre = 'All';
                _maxPrice = 50;
              }),
              child: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }
}