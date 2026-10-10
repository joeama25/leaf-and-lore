
import '../models/book_model.dart';
import 'database_service.dart';

class BookService {
static final BookService instance = BookService._internal();

BookService._internal();

Future<List<BookModel>> getAll() async {
final db = await DatabaseService.instance.database;
final rows = await db.query(
'books',
orderBy: 'id DESC',
);

return rows.map((row) => _fromRow(row)).toList();
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
return _fromRow(rows.first);
}

Future<List<BookModel>> search(String query) async {
final term = query.trim();

if (term.isEmpty) return getAll();

final db = await DatabaseService.instance.database;
final pattern = '%$term%';

final rows = await db.query(
'books',
where: '''
        LOWER(title) LIKE LOWER(?) OR
        LOWER(author) LIKE LOWER(?) OR
        LOWER(genre) LIKE LOWER(?) OR
        LOWER(description) LIKE LOWER(?)
      ''',
whereArgs: [pattern, pattern, pattern, pattern],
orderBy: 'title COLLATE NOCASE ASC',
);

return rows.map((row) => _fromRow(row)).toList();
}

Future<List<BookModel>> byGenre(String genre) async {
final db = await DatabaseService.instance.database;
final rows = await db.query(
'books',
where: 'LOWER(TRIM(genre)) = LOWER(TRIM(?))',
whereArgs: [genre],
orderBy: 'title COLLATE NOCASE ASC',
);

return rows.map((row) => _fromRow(row)).toList();
}

Future<int> add(BookModel book) async {
final db = await DatabaseService.instance.database;
final data = book.toMap()..remove('id');

return db.insert('books', data);
}

Future<void> update(BookModel book) async {
if (book.id == null) {
throw ArgumentError('A book ID is required to update a book.');
}

final db = await DatabaseService.instance.database;
final data = book.toMap()..remove('id');

await db.update(
'books',
data,
where: 'id = ?',
whereArgs: [book.id],
);
}

Future<void> remove(int id) async {
final db = await DatabaseService.instance.database;

await db.delete(
'books',
where: 'id = ?',
whereArgs: [id],
);
}

BookModel _fromRow(Map<String, dynamic> row) {
final safeRow = Map<String, dynamic>.from(row);

safeRow['cover_image'] ??= '';
safeRow['rating'] ??= 0;
safeRow['review_count'] ??= 0;
safeRow['badge'] ??= '';
safeRow['format'] ??= 'Paperback';
safeRow['stock'] ??= 10;

return BookModel.fromMap(safeRow);
}
}
