
import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';
import 'add_book_screen.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  static const Color _forest = Color(0xFF1F3A2E);
  static const Color _cream = Color(0xFFFAF7F0);

  bool _loading = true;
  String? _error;
  List<BookModel> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final books = await BookService.instance.getAll();
      if (!mounted) return;
      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load books.';
        _loading = false;
      });
    }
  }

  Future<void> _openBookForm([BookModel? book]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddBookScreen(book: book),
      ),
    );

    if (saved == true && mounted) {
      await _loadBooks();
    }
  }

  Future<void> _deleteBook(BookModel book) async {
    if (book.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove book?'),
        content: Text('Remove "${book.title}" from the catalogue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await BookService.instance.remove(book.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book removed.')),
      );
      await _loadBooks();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove book.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBookForm(),
        backgroundColor: _forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add book'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        color: _forest,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Center(child: Text(_error!)),
            Center(
              child: TextButton(
                onPressed: _loadBooks,
                child: const Text('Try again'),
              ),
            ),
          ],
        )
            : _books.isEmpty
            ? ListView(
          padding: const EdgeInsets.all(32),
          children: const [
            SizedBox(height: 90),
            Icon(Icons.menu_book_outlined, size: 64),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No books yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Use Add book to create your first listing.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: _books.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final book = _books[index];
            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: Color(0xFFE5E0D5),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 52,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: book.coverImage.isNotEmpty
                        ? Image.asset(
                      book.coverImage,
                      width: 52,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.menu_book_outlined,
                        color: _forest,
                      ),
                    )
                        : const Icon(
                      Icons.menu_book_outlined,
                      color: _forest,
                    ),
                  ),
                ),
                title: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _forest,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${book.author}\n${book.genre} • ₦${book.price.toStringAsFixed(2)}\nStock: ${book.stock}',
                  ),
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') {
                      _openBookForm(book);
                    } else if (action == 'delete') {
                      _deleteBook(book);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Remove'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
