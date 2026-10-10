import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import 'write_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final BookModel book;
  const ReviewsScreen({super.key, required this.book});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _loading = true;
  List<ReviewModel> _reviews = [];
  double _average = 0;
  final Set<int> _helpful = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookId = widget.book.id;
    if (bookId == null) {
      if (!mounted) return;
      setState(() { _loading = false; _reviews = []; _average = 0; });
      return;
    }
    if (!_loading) setState(() => _loading = true);
    try {
      final reviews = await ReviewService.instance.getForBook(bookId);
      final average = await ReviewService.instance.averageForBook(bookId);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _average = average;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load reader reviews.')),
      );
    }
  }

  Future<void> _writeReview() async {
    if (widget.book.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This book is not available for reviews yet.')),
      );
      return;
    }
    final ok = await AuthGuard.requireLogin(context);
    if (!ok || !mounted) return;
    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WriteReviewScreen(book: widget.book)),
    );
    if (!mounted) return;
    if (submitted == true) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for sharing your review!')),
      );
    }
  }

  void _toggleHelpful(int id) {
    setState(() {
      if (!_helpful.add(id)) _helpful.remove(id);
    });
  }

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    return date == null ? '' : DateFormat('MMM d, yyyy').format(date);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'R';
    return parts.length == 1
        ? parts.first[0].toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _stars(int rating, {double size = 17}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => Icon(
      i < rating ? Icons.star : Icons.star_border,
      size: size,
      color: AppColors.gold,
    )),
  );

  Widget _distribution(int stars) {
    final count = _reviews.where((r) => r.rating == stars).length;
    final fraction = _reviews.isEmpty ? 0.0 : count / _reviews.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 25, child: Text('$stars★', style: AppTextStyles.small)),
        const SizedBox(width: 10),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
        )),
        const SizedBox(width: 10),
        SizedBox(width: 26, child: Text('$count',
          textAlign: TextAlign.end, style: AppTextStyles.small)),
      ]),
    );
  }

  Widget _reviewCard(ReviewModel review) {
    final name = (review.reviewerName?.trim().isNotEmpty ?? false)
        ? review.reviewerName!.trim() : 'Reader';
    final helpful = review.id != null && _helpful.contains(review.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.sage,
            child: Text(_initials(name), style: AppTextStyles.small.copyWith(
              color: AppColors.forest, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            Text(_formatDate(review.createdAt), style: AppTextStyles.small),
          ])),
          _stars(review.rating, size: 15),
        ]),
        if (review.comment?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: 14),
          Text(review.comment!, style: AppTextStyles.body),
        ],
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: review.id == null ? null : () => _toggleHelpful(review.id!),
          icon: Icon(helpful ? Icons.thumb_up : Icons.thumb_up_outlined, size: 16),
          label: Text(helpful ? 'Helpful ✓' : 'Helpful'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.forest,
            padding: EdgeInsets.zero,
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Reader reviews', style: AppTextStyles.title)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
            children: [
              Text(widget.book.title, style: AppTextStyles.title),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(_reviews.isEmpty ? '—' : _average.toStringAsFixed(1),
                  style: AppTextStyles.display.copyWith(fontSize: 54)),
                const SizedBox(width: 20),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stars(_average.round()),
                    const SizedBox(height: 6),
                    Text('Based on ${_reviews.length} reader reviews',
                      style: AppTextStyles.small),
                  ],
                )),
              ]),
              const SizedBox(height: 20),
              for (int star = 5; star >= 1; star--) _distribution(star),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _writeReview,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Write a review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forest,
                  side: const BorderSide(color: AppColors.forest),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 30),
              const Text('What readers are saying', style: AppTextStyles.heading),
              const SizedBox(height: 18),
              if (_reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(children: [
                    const Icon(Icons.rate_review_outlined,
                      color: AppColors.forest, size: 42),
                    const SizedBox(height: 16),
                    const Text('No reader reviews yet', style: AppTextStyles.title),
                    const SizedBox(height: 6),
                    Text('Be the first to share your thoughts.',
                      textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
                  ]),
                )
              else
                for (final review in _reviews) _reviewCard(review),
            ],
          ),
        ),
    );
  }
}
