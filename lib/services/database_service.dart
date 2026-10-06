import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();


  static Database? _db;
  Future<Database> get database async{
    if(_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async{
   final dbPath = join(await getDatabasesPath(), 'bookstore.db');
   return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate (Database db, int version) async{
    await db.execute('''
    CREATE TABLE users(
    id INTEGER PRIMARY KEY AUTOINCREMENT
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'user'
    created_at TEXT NOT NULL 
    )
    (''');

    await db.execute('''
    CREATE TABLE addresses(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    label TEXT,
    street TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT,
    country TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id) on DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE payment_methods(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    card_holder TEXT NOT NULL,
    expiry TEXT NOT NULL,
    brand TEXT,
    FOREIGN KEY(user_id) REFERENCES users (id) on DELETE CASCADE
    )
    ''');
  }
}
