import '../models/book_model.dart';
import 'database_service.dart';

class CartItem {
  final int? id;
  final int userId;
  final int bookId;
  final String title;
  final String author;
  final double price;
  final int quantity;
  final String genre;

  CartItem({
    this.id,
    required this.userId,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    this.quantity = 1,
    required this.genre,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'book_id': bookId,
    'title': title,
    'author': author,
    'price': price,
    'quantity': quantity,
    'genre': genre,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    bookId: map['book_id'] as int,
    title: map['title'] as String,
    author: map['author'] as String,
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'] as int,
    genre: map['genre'] as String,
  );
}

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  Future<List<CartItem>> getItems(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((r) => CartItem.fromMap(r)).toList();
  }

  Future<void> addBook(int userId, BookModel book, {int quantity = 1}) async {
    final db = await DatabaseService.instance.database;
    final existing = await db.query(
      'cart_items',
      where: 'user_id = ? AND book_id = ?',
      whereArgs: [userId, book.id],
    );

    if (existing.isNotEmpty) {
      final current = existing.first;
      final qty = (current['quantity'] as int) + quantity;
      await db.update(
        'cart_items',
        {'quantity': qty},
        where: 'id = ?',
        whereArgs: [current['id']],
      );
    } else {
      await db.insert('cart_items', {
        'user_id': userId,
        'book_id': book.id ?? 0,
        'title': book.title,
        'author': book.author,
        'price': book.price,
        'quantity': quantity,
        'genre': book.genre,
      });
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) return;
    final db = await DatabaseService.instance.database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<void> remove(int cartItemId) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<void> clear(int userId) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<double> subtotal(int userId) async {
    final items = await getItems(userId);
    return items.fold<double>(0.0, (sum, i) => sum + i.subtotal);
  }
}