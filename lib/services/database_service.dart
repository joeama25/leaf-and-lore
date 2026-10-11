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
      version: 5,
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

    // Seed default admin — every fresh install gets one
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@leafandlore.com',
      'password': 'admin123',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });

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
        cover_image TEXT,
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
        cover_image TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        genre TEXT NOT NULL,
        description TEXT NOT NULL,
        cover_image TEXT,
        price REAL NOT NULL,
        rating REAL NOT NULL DEFAULT 0,
        review_count INTEGER NOT NULL DEFAULT 0,
        badge TEXT DEFAULT '',
        published_date TEXT NOT NULL,
        format TEXT NOT NULL DEFAULT 'Paperback',
        stock INTEGER NOT NULL DEFAULT 10
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        order_number TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        subtotal REAL NOT NULL,
        shipping REAL NOT NULL,
        total REAL NOT NULL,
        shipping_address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        placed_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        genre TEXT NOT NULL,
        cover_image TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // Seed books
    final seedBooks = [
      {
        'id': 1, 'title': 'The Art of Stillness', 'author': 'Elena Marlowe',
        'genre': 'Mindfulness',
        'description': 'An invitation to slow down, notice the small things, '
            'and find wonder in the spaces between.',
        'cover_image': 'assets/covers/book_1.png',
        'price': 24.99, 'rating': 4.9, 'review_count': 128,
        'badge': 'bestseller', 'published_date': 'March 2025',
        'format': 'Paperback', 'stock': 18,
      },
      {
        'id': 2, 'title': 'Between the Pines', 'author': 'Noah Reid',
        'genre': 'Fiction',
        'description': 'A quiet novel about returning home.',
        'cover_image': 'assets/covers/book_2.png',
        'price': 18.50, 'rating': 4.7, 'review_count': 96,
        'badge': 'editors_pick', 'published_date': 'January 2025',
        'format': 'Paperback', 'stock': 12,
      },
      {
        'id': 3, 'title': 'The Quiet Universe', 'author': 'Daniel Cho',
        'genre': 'Science',
        'description': 'A luminous exploration of the cosmos.',
        'cover_image': 'assets/covers/book_3.png',
        'price': 25.00, 'rating': 4.9, 'review_count': 128,
        'badge': '', 'published_date': 'January 2025',
        'format': 'Hardcover', 'stock': 9,
      },
      {
        'id': 4, 'title': 'A Field Guide to Wonder', 'author': 'Mara Finch',
        'genre': 'Nature',
        'description': 'A gentle companion for a more intentional life.',
        'cover_image': 'assets/covers/book_4.png',
        'price': 21.99, 'rating': 4.8, 'review_count': 82,
        'badge': 'new', 'published_date': 'March 2025',
        'format': 'Paperback', 'stock': 14,
      },
      {
        'id': 5, 'title': 'Small Rituals', 'author': 'Clara West',
        'genre': 'Mindfulness',
        'description': 'Everyday practices for a slower, kinder life.',
        'cover_image': 'assets/covers/book_5.png',
        'price': 16.99, 'rating': 4.8, 'review_count': 64,
        'badge': 'new', 'published_date': 'April 2025',
        'format': 'Paperback', 'stock': 7,
      },
      {
        'id': 6, 'title': 'The Night Archive', 'author': 'Julian Bell',
        'genre': 'Mystery',
        'description': 'A librarian discovers a hidden collection.',
        'cover_image': 'assets/covers/book_6.png',
        'price': 27.00, 'rating': 4.6, 'review_count': 110,
        'badge': '', 'published_date': 'February 2025',
        'format': 'Hardcover', 'stock': 14,
      },
      {
        'id': 7, 'title': 'Wildflower Season', 'author': 'Sophie Hart',
        'genre': 'Romance',
        'description': 'A slow-burn love story set in a coastal town.',
        'cover_image': 'assets/covers/book_7.png',
        'price': 19.99, 'rating': 4.7, 'review_count': 91,
        'badge': 'bestseller', 'published_date': 'May 2025',
        'format': 'Paperback', 'stock': 11,
      },
      {
        'id': 8, 'title': 'The Shape of Tomorrow', 'author': 'Iris Bennett',
        'genre': 'Fiction',
        'description': 'Speculative short stories about the near future.',
        'cover_image': 'assets/covers/book_8.png',
        'price': 22.00, 'rating': 4.5, 'review_count': 74,
        'badge': '', 'published_date': 'June 2025',
        'format': 'Paperback', 'stock': 20,
      },
    ];

    for (final book in seedBooks) {
      await db.insert('books', book);
    }
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
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          author TEXT NOT NULL,
          genre TEXT NOT NULL,
          description TEXT NOT NULL,
          cover_image TEXT,
          price REAL NOT NULL,
          rating REAL NOT NULL DEFAULT 0,
          review_count INTEGER NOT NULL DEFAULT 0,
          badge TEXT DEFAULT '',
          published_date TEXT NOT NULL,
          format TEXT NOT NULL DEFAULT 'Paperback',
          stock INTEGER NOT NULL DEFAULT 10
        )
      ''');

      await db.execute('''
        CREATE TABLE reviews (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          rating INTEGER NOT NULL,
          comment TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          order_number TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'Pending',
          subtotal REAL NOT NULL,
          shipping REAL NOT NULL,
          total REAL NOT NULL,
          shipping_address TEXT NOT NULL,
          payment_method TEXT NOT NULL,
          placed_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          author TEXT NOT NULL,
          price REAL NOT NULL,
          quantity INTEGER NOT NULL,
          genre TEXT NOT NULL,
          cover_image TEXT,
          FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE cart_items ADD COLUMN cover_image TEXT');
      await db.execute('ALTER TABLE wishlist_items ADD COLUMN cover_image TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE order_items ADD COLUMN cover_image TEXT');
    }
  }
}