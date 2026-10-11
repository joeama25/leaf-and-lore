import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';

class AddBookScreen extends StatefulWidget {
  final BookModel? book;
  const AddBookScreen({super.key, this.book});
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _coverCtrl;

  String _genre = 'Fiction';
  String _format = 'Paperback';
  bool _loading = false;

  static const _genres = [
    'Fiction', 'Mindfulness', 'Nature',
    'Romance', 'Mystery', 'Science',
  ];
  static const _formats = ['Paperback', 'Hardcover'];

  bool get _isEdit => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _descCtrl = TextEditingController(text: b?.description ?? '');
    _priceCtrl = TextEditingController(
        text: b != null ? b.price.toStringAsFixed(2) : '');
    _stockCtrl = TextEditingController(
        text: b != null ? b.stock.toString() : '10');
    _coverCtrl = TextEditingController(text: b?.coverImage ?? '');
    if (b != null) {
      _genre = _genres.contains(b.genre) ? b.genre : _genres.first;
      _format = _formats.contains(b.format) ? b.format : _formats.first;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final book = BookModel(
        id: widget.book?.id,
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        genre: _genre,
        description: _descCtrl.text.trim(),
        coverImage: _coverCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        rating: widget.book?.rating ?? 0,
        reviewCount: widget.book?.reviewCount ?? 0,
        badge: widget.book?.badge ?? '',
        publishedDate: widget.book?.publishedDate ??
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
        format: _format,
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
      );

      if (_isEdit) {
        await BookService.instance.update(book);
      } else {
        await BookService.instance.add(book);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit book' : 'Add a book',
            style: AppTextStyles.heading),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  label: 'Title',
                  controller: _titleCtrl,
                  validator: (v) => Validators.required(v, 'Title'),
                ),
                CustomTextField(
                  label: 'Author',
                  controller: _authorCtrl,
                  validator: (v) => Validators.required(v, 'Author'),
                ),
                const SizedBox(height: 12),
                const Text('GENRE', style: AppTextStyles.eyebrow),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _genre,
                      isExpanded: true,
                      style: AppTextStyles.body,
                      items: _genres
                          .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _genre = v ?? _genre),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Description',
                  controller: _descCtrl,
                  validator: (v) => Validators.required(v, 'Description'),
                ),
                CustomTextField(
                  label: 'Price',
                  controller: _priceCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Price required';
                    final d = double.tryParse(v.trim());
                    if (d == null || d <= 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Stock',
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Stock required';
                    if (int.tryParse(v.trim()) == null) return 'Whole number';
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Cover image path (optional)',
                  controller: _coverCtrl,
                ),
                const SizedBox(height: 12),
                const Text('FORMAT', style: AppTextStyles.eyebrow),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _format,
                      isExpanded: true,
                      style: AppTextStyles.body,
                      items: _formats
                          .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _format = v ?? _format),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                      : Text(_isEdit ? 'Save changes' : 'Add book'),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}