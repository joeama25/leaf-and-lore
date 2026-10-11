import '../models/book_model.dart';
import 'database_service.dart';

class BookService {
  static final BookService instance = BookService._internal();
  BookService._internal();

  Future<List<BookModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('books', orderBy: 'id ASC');
    return rows.map((r) => BookModel.fromMap(r)).toList();
  }

  Future<BookModel?> getById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BookModel.fromMap(rows.first);
  }

  Future<List<BookModel>> byGenre(String genre) async {
    if (genre == 'All') return getAll();
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'books',
      where: 'genre = ?',
      whereArgs: [genre],
      orderBy: 'id ASC',
    );
    return rows.map((r) => BookModel.fromMap(r)).toList();
  }

  Future<List<BookModel>> bestsellers() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'books',
      where: 'badge = ?',
      whereArgs: ['bestseller'],
    );
    return rows.map((r) => BookModel.fromMap(r)).toList();
  }

  Future<List<BookModel>> newArrivals() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'books',
      where: 'badge = ?',
      whereArgs: ['new'],
    );
    return rows.map((r) => BookModel.fromMap(r)).toList();
  }

  Future<List<BookModel>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    final all = await getAll();
    return all.where((b) =>
    b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        b.genre.toLowerCase().contains(q),
    ).toList();
  }

  Future<int> add(BookModel book) async {
    final db = await DatabaseService.instance.database;
    return db.insert('books', book.toMap());
  }

  Future<void> update(BookModel book) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<void> remove(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}