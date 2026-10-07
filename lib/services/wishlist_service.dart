import '../models/book_model.dart';
import 'database_service.dart';

class WishlistItem {
  final int? id;
  final int userId;
  final int bookId;
  final String title;
  final String author;
  final double price;
  final String genre;
  final String addedAt;

  WishlistItem({
    this.id,
    required this.userId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.genre,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'book_id': bookId,
    'title': title,
    'author': author,
    'price': price,
    'genre': genre,
    'added_at': addedAt,
  };

  factory WishlistItem.fromMap(Map<String, dynamic> map) => WishlistItem(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    bookId: map['book_id'] as int,
    title: map['title'] as String,
    author: map['author'] as String,
    price: (map['price'] as num).toDouble(),
    genre: map['genre'] as String,
    addedAt: map['added_at'] as String,
  );
}

class WishlistService {
  static final WishlistService instance = WishlistService._internal();
  WishlistService._internal();

  Future<List<WishlistItem>> getItems(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'wishlist_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((r) => WishlistItem.fromMap(r)).toList();
  }

  Future<bool> isWishlisted(int userId, int bookId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'wishlist_items',
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [userId, bookId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> add(int userId, BookModel book) async {
    if (await isWishlisted(userId, book.id ?? 0)) return;
    final db = await DatabaseService.instance.database;
    await db.insert('wishlist_items', {
      'user_id': userId,
      'book_id': book.id ?? 0,
      'title': book.title,
      'author': book.author,
      'price': book.price,
      'genre': book.genre,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> remove(int userId, int bookId) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      'wishlist_items',
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [userId, bookId],
    );
  }

  Future<void> toggle(int userId, BookModel book) async {
    if (await isWishlisted(userId, book.id ?? 0)) {
      await remove(userId, book.id ?? 0);
    } else {
      await add(userId, book);
    }
  }
}