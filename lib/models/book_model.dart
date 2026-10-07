class BookModel {
  final int? id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final String coverImage;
  final double price;
  final double rating;
  final int reviewCount;
  final String badge;
  final String publishedDate;
  final String format;
  final int stock;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.coverImage,
    required this.price,
    this.rating = 0,
    this.reviewCount = 0,
    this.badge = '',
    required this.publishedDate,
    this.format = 'Paperback',
    this.stock = 10,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'genre': genre,
    'description': description,
    'cover_image': coverImage,
    'price': price,
    'rating': rating,
    'review_count': reviewCount,
    'badge': badge,
    'published_date': publishedDate,
    'format': format,
    'stock': stock,
  };

  factory BookModel.fromMap(Map<String, dynamic> map) => BookModel(
    id: map['id'] as int?,
    title: map['title'] as String,
    author: map['author'] as String,
    genre: map['genre'] as String,
    description: map['description'] as String,
    coverImage: map['cover_image'] as String,
    price: (map['price'] as num).toDouble(),
    rating: (map['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: map['review_count'] as int? ?? 0,
    badge: map['badge'] as String? ?? '',
    publishedDate: map['published_date'] as String,
    format: map['format'] as String? ?? 'Paperback',
    stock: map['stock'] as int? ?? 10,
  );
}