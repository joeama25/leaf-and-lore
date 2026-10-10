class ReviewModel {
  final int? id;
  final int userId;
  final int bookId;
  final int rating;
  final String? comment;
  final String createdAt;
  // Supplied by the ReviewService JOIN; not stored in the reviews table.
  final String? reviewerName;

  const ReviewModel({
    this.id,
    required this.userId,
    required this.bookId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'book_id': bookId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt,
  };

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    bookId: map['book_id'] as int,
    rating: map['rating'] as int,
    comment: map['comment'] as String?,
    createdAt: map['created_at'] as String,
    reviewerName: map['reviewer_name'] as String?,
  );
}
