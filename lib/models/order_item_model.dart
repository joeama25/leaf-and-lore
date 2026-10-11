class OrderItemModel {
  final int? id;
  final int? orderId;
  final int bookId;
  final String title;
  final String author;
  final double price;
  final int quantity;
  final String genre;
  final String? coverImage;

  const OrderItemModel({
    this.id,
    this.orderId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.quantity,
    required this.genre,
    this.coverImage,
  });

  double get lineTotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'book_id': bookId,
    'title': title,
    'author': author,
    'price': price,
    'quantity': quantity,
    'genre': genre,
    'cover_image': coverImage,
  };

  factory OrderItemModel.fromMap(Map<String, dynamic> row) => OrderItemModel(
    id: row['id'] as int?,
    orderId: row['order_id'] as int?,
    bookId: row['book_id'] as int,
    title: row['title'] as String,
    author: row['author'] as String,
    price: (row['price'] as num).toDouble(),
    quantity: row['quantity'] as int,
    genre: row['genre'] as String,
    coverImage: row['cover_image'] as String?,
  );
}
