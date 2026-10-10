
import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';

class AddBookScreen extends StatefulWidget {
  final BookModel? book;

  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  static const Color _forest = Color(0xFF1F3A2E);
  static const Color _cream = Color(0xFFFAF7F0);
  static const Color _border = Color(0xFFE5E0D5);

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _genre = TextEditingController();
  final _description = TextEditingController();
  final _coverImage = TextEditingController();
  final _price = TextEditingController();
  final _rating = TextEditingController();
  final _reviewCount = TextEditingController();
  final _badge = TextEditingController();
  final _publishedDate = TextEditingController();
  final _stock = TextEditingController();

  String _format = 'Paperback';
  bool _saving = false;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();

    final book = widget.book;
    if (book != null) {
      _title.text = book.title;
      _author.text = book.author;
      _genre.text = book.genre;
      _description.text = book.description;
      _coverImage.text = book.coverImage;
      _price.text = book.price.toString();
      _rating.text = book.rating.toString();
      _reviewCount.text = book.reviewCount.toString();
      _badge.text = book.badge;
      _publishedDate.text = book.publishedDate;
      _stock.text = book.stock.toString();
      _format = book.format;
    } else {
      _rating.text = '0';
      _reviewCount.text = '0';
      _publishedDate.text = DateTime.now().toIso8601String().split('T').first;
      _stock.text = '10';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _genre.dispose();
    _description.dispose();
    _coverImage.dispose();
    _price.dispose();
    _rating.dispose();
    _reviewCount.dispose();
    _badge.dispose();
    _publishedDate.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _validNumber(String? value, {double minimum = 0}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a number.';
    }
    final number = double.tryParse(value.trim());
    if (number == null || !number.isFinite || number < minimum) {
      return 'Enter a valid number (minimum $minimum).';
    }
    return null;
  }

  String? _validInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a whole number.';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number < 0) {
      return 'Enter a non-negative whole number.';
    }
    return null;
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final book = BookModel(
      id: widget.book?.id,
      title: _title.text.trim(),
      author: _author.text.trim(),
      genre: _genre.text.trim(),
      description: _description.text.trim(),
      coverImage: _coverImage.text.trim(),
      price: double.parse(_price.text.trim()),
      rating: double.parse(_rating.text.trim()),
      reviewCount: int.parse(_reviewCount.text.trim()),
      badge: _badge.text.trim(),
      publishedDate: _publishedDate.text.trim(),
      format: _format,
      stock: int.parse(_stock.text.trim()),
    );

    try {
      if (_isEditing) {
        await BookService.instance.update(book);
      } else {
        await BookService.instance.add(book);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Book updated.' : 'Book added.'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the book. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _textField(
      String label,
      TextEditingController controller, {
        String? Function(String?)? validator,
        int maxLines = 1,
        TextInputType? keyboardType,
        String? hint,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit book' : 'Add a book'),
        backgroundColor: _forest,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditing ? 'Update book details' : 'New catalogue entry',
              style: const TextStyle(
                color: _forest,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the details that will appear in your bookstore.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _textField('Book title', _title, validator: _requiredText),
            _textField('Author', _author, validator: _requiredText),
            _textField('Genre', _genre, validator: _requiredText),
            _textField(
              'Description',
              _description,
              validator: _requiredText,
              maxLines: 4,
            ),
            _textField(
              'Cover image path or URL',
              _coverImage,
              hint: 'assets/covers/book_1.jpg',
            ),
            _textField(
              'Price (₦)',
              _price,
              validator: (value) => _validNumber(value, minimum: 0.01),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _textField(
              'Rating (0 to 5)',
              _rating,
              validator: (value) {
                final error = _validNumber(value);
                if (error != null) return error;
                final rating = double.parse(value!.trim());
                return rating > 5 ? 'Rating cannot exceed 5.' : null;
              },
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _textField(
              'Review count',
              _reviewCount,
              validator: _validInteger,
              keyboardType: TextInputType.number,
            ),
            _textField(
              'Badge',
              _badge,
              hint: 'Bestseller, New, or leave blank',
            ),
            _textField(
              'Published date',
              _publishedDate,
              validator: _requiredText,
              hint: 'YYYY-MM-DD',
            ),
            DropdownButtonFormField<String>(
              initialValue: _format,
              decoration: InputDecoration(
                labelText: 'Format',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Paperback',
                  child: Text('Paperback'),
                ),
                DropdownMenuItem(
                  value: 'Hardcover',
                  child: Text('Hardcover'),
                ),
                DropdownMenuItem(
                  value: 'E-book',
                  child: Text('E-book'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _format = value);
              },
            ),
            const SizedBox(height: 16),
            _textField(
              'Stock quantity',
              _stock,
              validator: _validInteger,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _forest,
                  foregroundColor: Colors.white,
                ),
                child: _saving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(_isEditing ? 'Save changes' : 'Add book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
