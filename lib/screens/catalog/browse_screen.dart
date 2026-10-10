
import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/book_card.dart';

class BrowseScreen extends StatefulWidget {
const BrowseScreen({super.key});

@override
State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
final BookService _bookService = BookService.instance;
final TextEditingController _searchController = TextEditingController();

List<BookModel> _allBooks = [];
bool _loading = true;
String? _error;

String _selectedGenre = 'All';
String _sortBy = 'Recommended';

double _minPrice = 0;
double? _maxPrice;
double _minRating = 0;

double get _priceSliderMax {
final highestPrice = _allBooks.fold<double>(
100,
(highest, book) => book.price > highest ? book.price : highest,
);

return (highestPrice / 10).ceil() * 10.0;
}

final List<String> _genres = [
'All',
'Fiction',
'Mindfulness',
'Nature',
'Romance',
'Mystery',
'Science',
];

@override
void initState() {
super.initState();
_searchController.addListener(_refreshResults);
_loadBooks();
}

@override
void dispose() {
_searchController.removeListener(_refreshResults);
_searchController.dispose();
super.dispose();
}

Future<void> _loadBooks() async {
if (mounted) {
setState(() {
_loading = true;
_error = null;
});
}

try {
final books = await _bookService.getAll();

if (!mounted) return;

final pendingGenre = AppState.pendingGenre.value;

setState(() {
_allBooks = books;

if (pendingGenre != null && pendingGenre.trim().isNotEmpty) {
_selectedGenre = pendingGenre;
AppState.pendingGenre.value = null;
}

_loading = false;
});
} catch (error) {
if (!mounted) return;

setState(() {
_error = 'Could not load books. Please try again.';
_loading = false;
});
}
}

void _refreshResults() {
if (mounted) setState(() {});
}

List<BookModel> get _filteredBooks {
final query = _searchController.text.trim().toLowerCase();

Iterable<BookModel> results = _allBooks;

if (query.isNotEmpty) {
results = results.where((book) {
return book.title.toLowerCase().contains(query) ||
book.author.toLowerCase().contains(query) ||
book.genre.toLowerCase().contains(query) ||
book.description.toLowerCase().contains(query);
});
}

if (_selectedGenre != 'All') {
results = results.where(
(book) =>
book.genre.trim().toLowerCase() ==
_selectedGenre.trim().toLowerCase(),
);
}

results = results.where((book) {
final aboveMinimum = book.price >= _minPrice;
final belowMaximum =
_maxPrice == null || book.price <= _maxPrice!;
final aboveRating = book.rating >= _minRating;

return aboveMinimum && belowMaximum && aboveRating;
});

final sorted = results.toList();

switch (_sortBy) {
case 'Price: Low to High':
sorted.sort((a, b) => a.price.compareTo(b.price));
break;
case 'Price: High to Low':
sorted.sort((a, b) => b.price.compareTo(a.price));
break;
case 'Title: A to Z':
sorted.sort(
(a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
);
break;
case 'Highest Rated':
sorted.sort((a, b) => b.rating.compareTo(a.rating));
break;
}

return sorted;
}

void _resetFilters() {
setState(() {
_selectedGenre = 'All';
_minPrice = 0;
_maxPrice = null;
_minRating = 0;
_sortBy = 'Recommended';
});
}

void _showSortOptions() {
const options = [
'Recommended',
'Price: Low to High',
'Price: High to Low',
'Title: A to Z',
'Highest Rated',
];

showModalBottomSheet<void>(
context: context,
backgroundColor: AppColors.cream,
builder: (sheetContext) {
return SafeArea(
child: Padding(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Sort books by',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: AppColors.forest,
),
),
const SizedBox(height: 12),
...options.map(
(option) => RadioListTile<String>(
value: option,
groupValue: _sortBy,
activeColor: AppColors.forest,
title: Text(option),
onChanged: (value) {
if (value == null) return;
setState(() => _sortBy = value);
Navigator.pop(sheetContext);
},
),
),
],
),
),
);
},
);
}

void _showFilterOptions() {
final sliderMax = _priceSliderMax;
double minPrice = _minPrice.clamp(0, sliderMax).toDouble();
double maxPrice = (_maxPrice ?? sliderMax).clamp(0, sliderMax).toDouble();
double minRating = _minRating;

showModalBottomSheet<void>(
context: context,
isScrollControlled: true,
backgroundColor: AppColors.cream,
builder: (sheetContext) {
return StatefulBuilder(
builder: (context, setSheetState) {
return SafeArea(
child: Padding(
padding: EdgeInsets.fromLTRB(
24,
24,
24,
MediaQuery.of(context).viewInsets.bottom + 24,
),
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Filter books',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: AppColors.forest,
),
),
const SizedBox(height: 24),
Text(
'Minimum price: \$${minPrice.toStringAsFixed(0)}',
),
Slider(
value: minPrice,
min: 0,
max: sliderMax,
divisions: sliderMax >= 20 ? 20 : null,
activeColor: AppColors.forest,
onChanged: (value) {
setSheetState(() {
minPrice = value;
if (minPrice > maxPrice) {
maxPrice = minPrice;
}
});
},
),
Text(
'Maximum price: \$${maxPrice.toStringAsFixed(0)}',
),
Slider(
value: maxPrice,
min: 0,
max: sliderMax,
divisions: sliderMax >= 20 ? 20 : null,
activeColor: AppColors.forest,
onChanged: (value) {
setSheetState(() {
maxPrice = value;
if (maxPrice < minPrice) {
minPrice = maxPrice;
}
});
},
),
const SizedBox(height: 12),
const Text('Minimum rating'),
const SizedBox(height: 8),
Wrap(
spacing: 8,
children: [0.0, 3.0, 4.0, 4.5].map((rating) {
return ChoiceChip(
label: Text(
rating == 0 ? 'Any' : '$rating+ stars',
),
selected: minRating == rating,
selectedColor: AppColors.sage,
onSelected: (_) {
setSheetState(() => minRating = rating);
},
);
}).toList(),
),
const SizedBox(height: 24),
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: () {
setSheetState(() {
minPrice = 0;
maxPrice = sliderMax;
minRating = 0;
});
},
child: const Text('Reset'),
),
),
const SizedBox(width: 12),
Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.forest,
foregroundColor: AppColors.white,
),
onPressed: () {
setState(() {
_minPrice = minPrice;
_maxPrice = maxPrice >= sliderMax
? null
    : maxPrice;
_minRating = minRating;
});
Navigator.pop(sheetContext);
},
child: const Text('Apply filters'),
),
),
],
),
],
),
),
),
);
},
);
},
);
}

Widget _buildGenreChips() {
return SizedBox(
height: 42,
child: ListView.separated(
scrollDirection: Axis.horizontal,
itemCount: _genres.length,
separatorBuilder: (_, _) => const SizedBox(width: 8),
itemBuilder: (context, index) {
final genre = _genres[index];
final selected = _selectedGenre == genre;

return ChoiceChip(
label: Text(genre),
selected: selected,
selectedColor: AppColors.forest,
backgroundColor: AppColors.white,
labelStyle: TextStyle(
color: selected ? AppColors.white : AppColors.ink,
fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
),
side: const BorderSide(color: AppColors.border),
onSelected: (_) {
setState(() => _selectedGenre = genre);
},
);
},
),
);
}

@override
Widget build(BuildContext context) {
final books = _filteredBooks;

return Scaffold(
backgroundColor: AppColors.cream,
body: SafeArea(
child: RefreshIndicator(
onRefresh: _loadBooks,
color: AppColors.forest,
child: CustomScrollView(
physics: const AlwaysScrollableScrollPhysics(),
slivers: [
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Find your next story',
style: AppTextStyles.display,
),
const SizedBox(height: 8),
const Text(
'Explore stories, ideas, and new perspectives.',
style: AppTextStyles.bodyMuted,
),
const SizedBox(height: 24),
TextField(
controller: _searchController,
textInputAction: TextInputAction.search,
decoration: InputDecoration(
hintText: 'Search books, authors, genres...',
prefixIcon: const Icon(Icons.search),
suffixIcon: _searchController.text.isEmpty
? null
    : IconButton(
tooltip: 'Clear search',
onPressed: _searchController.clear,
icon: const Icon(Icons.close),
),
filled: true,
fillColor: AppColors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(
color: AppColors.border,
),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(
color: AppColors.border,
),
),
),
),
const SizedBox(height: 16),
_buildGenreChips(),
const SizedBox(height: 16),
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: _showFilterOptions,
icon: const Icon(Icons.tune),
label: const Text('Filters'),
),
),
const SizedBox(width: 12),
Expanded(
child: OutlinedButton.icon(
onPressed: _showSortOptions,
icon: const Icon(Icons.sort),
label: Text(
_sortBy == 'Recommended' ? 'Sort' : _sortBy,
overflow: TextOverflow.ellipsis,
),
),
),
],
),
if (_minPrice > 0 ||
_maxPrice != null ||
_minRating > 0) ...[
const SizedBox(height: 8),
Align(
alignment: Alignment.centerLeft,
child: TextButton(
onPressed: _resetFilters,
child: const Text('Clear all filters'),
),
),
],
const SizedBox(height: 12),
Text(
'${books.length} ${books.length == 1 ? 'book' : 'books'} found',
style: const TextStyle(
color: AppColors.inkMuted,
fontSize: 13,
),
),
],
),
),
),
if (_loading)
const SliverFillRemaining(
hasScrollBody: false,
child: Center(child: CircularProgressIndicator()),
)
else if (_error != null)
SliverFillRemaining(
hasScrollBody: false,
child: Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.error_outline, size: 44),
const SizedBox(height: 12),
Text(_error!, textAlign: TextAlign.center),
const SizedBox(height: 12),
ElevatedButton(
onPressed: _loadBooks,
child: const Text('Try again'),
),
],
),
),
),
)
else if (books.isEmpty)
SliverFillRemaining(
hasScrollBody: false,
child: Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Text(
_searchController.text.trim().isNotEmpty
? 'No books found for "${_searchController.text.trim()}". Try another title, author, or keyword.'
    : 'No books match your current filters.',
textAlign: TextAlign.center,
),
),
),
)
else
SliverPadding(
padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
sliver: SliverGrid(
gridDelegate:
const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 16,
mainAxisSpacing: 20,
childAspectRatio: 0.52,
),
delegate: SliverChildBuilderDelegate(
(context, index) {
return BookCard(
book: books[index],
width: double.infinity,
);
},
childCount: books.length,
),
),
),
],
),
),
),
);
}
}
