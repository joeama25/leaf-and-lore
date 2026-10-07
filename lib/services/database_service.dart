import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'bookstore.db');
    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        label TEXT,
        street TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        zip TEXT,
        country TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        card_holder TEXT NOT NULL,
        card_number TEXT NOT NULL,
        expiry TEXT NOT NULL,
        brand TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        genre TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE wishlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price REAL NOT NULL,
        genre TEXT NOT NULL,
        added_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE cart_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          author TEXT NOT NULL,
          price REAL NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          genre TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE wishlist_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          author TEXT NOT NULL,
          price REAL NOT NULL,
          genre TEXT NOT NULL,
          added_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }
  }
}