import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/book_cover_placeholder.dart';
import 'add_book_screen.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});
  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  List<BookModel> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final books = await BookService.instance.getAll();
      if (!mounted) return;
      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _addNew() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (result == true) _load();
  }

  Future<void> _edit(BookModel book) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddBookScreen(book: book)),
    );
    if (result == true) _load();
  }

  Future<void> _delete(BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete book?', style: AppTextStyles.heading),
        content: Text(
          'Remove "${book.title}" from the catalog? This cannot be undone.',
          style: AppTextStyles.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await BookService.instance.remove(book.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Book management',
                        style: AppTextStyles.heading),
                  ),
                  IconButton(
                    onPressed: _addNew,
                    icon: const Icon(Icons.add, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('${_books.length} books in catalog',
                      style: AppTextStyles.small),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addNew,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 18, color: AppColors.white),
                      SizedBox(width: 8),
                      Text('Add a book'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _books.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _books.length,
                itemBuilder: (_, i) => _bookRow(_books[i]),
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
              child: const Icon(Icons.menu_book_outlined,
                  color: AppColors.forest, size: 32),
            ),
            const SizedBox(height: 20),
            const Text('No books yet', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text('Add your first book to get started.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
    );
  }

  Widget _bookRow(BookModel book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          BookCoverPlaceholder(
            title: book.title,
            author: book.author,
            width: 60,
            height: 85,
            background: _coverColor(book.genre),
            imagePath: book.coverImage,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${book.author} · ${book.genre}',
                    style: AppTextStyles.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('\$${book.price.toStringAsFixed(2)} · ${book.stock} in stock',
                    style: AppTextStyles.small),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _edit(book),
            icon: const Icon(Icons.edit_outlined,
                size: 20, color: AppColors.forest),
          ),
          IconButton(
            onPressed: () => _delete(book),
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Color _coverColor(String genre) {
    switch (genre) {
      case 'Mindfulness': return AppColors.tan;
      case 'Fiction':     return AppColors.forest;
      case 'Science':     return const Color(0xFF2A3D4F);
      case 'Nature':      return const Color(0xFFE8E4D0);
      case 'Mystery':     return const Color(0xFF1B2838);
      case 'Romance':     return const Color(0xFFE3C7C7);
      default:            return AppColors.tan;
    }
  }
}