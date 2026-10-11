import '../models/review_model.dart';
import 'database_service.dart';

class ReviewService {
  static final ReviewService instance = ReviewService._internal();
  ReviewService._internal();

  Future<List<ReviewModel>> getForBook(int bookId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT r.*, u.name AS reviewer_name
      FROM reviews r
      LEFT JOIN users u ON u.id = r.user_id
      WHERE r.book_id = ?
      ORDER BY r.created_at DESC, r.id DESC
    ''', [bookId]);
    return rows.map((row) => ReviewModel.fromMap(row)).toList();
  }

  Future<int> add(ReviewModel review) async {
    if (review.rating < 1 || review.rating > 5) {
      throw ArgumentError.value(review.rating, 'rating', 'Must be 1–5');
    }
    final db = await DatabaseService.instance.database;
    return db.insert('reviews', review.toMap());
  }

  Future<double> averageForBook(int bookId) async {
    final db = await DatabaseService.instance.database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) AS average_rating FROM reviews WHERE book_id = ?',
      [bookId],
    );
    return (result.first['average_rating'] as num?)?.toDouble() ?? 0.0;
  }
}
