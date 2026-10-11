import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class WriteReviewScreen extends StatefulWidget {
  final BookModel book;
  const WriteReviewScreen({super.key, required this.book});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  int _rating = 0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userId = await AuthService().currentUserId();
      if (!mounted) return;
      setState(() {
        _userId = userId;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your account.')),
      );
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to leave a review.')),
      );
      return;
    }
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a star rating.')),
      );
      return;
    }
    if (widget.book.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This book cannot be reviewed yet.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ReviewService.instance.add(
        ReviewModel(
          userId: _userId!,
          bookId: widget.book.id!,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit your review. Please retry.')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Write a review', style: AppTextStyles.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              children: [
                const Text('YOUR READING EXPERIENCE', style: AppTextStyles.eyebrow),
                const SizedBox(height: 12),
                Text(widget.book.title, style: AppTextStyles.heading),
                const SizedBox(height: 5),
                Text('by ${widget.book.author}', style: AppTextStyles.bodyMuted),
                const SizedBox(height: 30),
                const Divider(color: AppColors.border),
                const SizedBox(height: 28),
                const Text('How would you rate this book?', style: AppTextStyles.title),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => IconButton(
                    tooltip: '${index + 1} star${index == 0 ? '' : 's'}',
                    iconSize: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.gold,
                    ),
                  )),
                ),
                const SizedBox(height: 32),
                const Text('What did you think?', style: AppTextStyles.title),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 6,
                  maxLength: 1200,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Share what stayed with you…',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Submit review'),
                ),
              ],
            ),
    );
  }
}
