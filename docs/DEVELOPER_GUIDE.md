# leaf & lore — Developer Guide

A Flutter + SQLite book store app. This guide covers the architecture, database schema, and how to extend the project.

## Stack

- **Language:** Dart
- **Framework:** Flutter
- **Database:** SQLite via `sqflite`
- **Session storage:** `shared_preferences`
- **State management:** `provider` (installed, lightly used)
- **Date formatting:** `intl`
- **IDE:** Android Studio

## Project structure

```
lib/
├── main.dart                    App entry, routes
├── models/                      Data classes
│   ├── book_model.dart
│   ├── user_model.dart
│   ├── address_model.dart
│   ├── payment_method_model.dart
│   ├── order_model.dart
│   ├── order_item_model.dart
│   └── review_model.dart
├── services/                    Business logic + DB access
│   ├── database_service.dart    Opens DB, creates tables, seeds
│   ├── auth_service.dart
│   ├── book_service.dart
│   ├── cart_service.dart
│   ├── wishlist_service.dart
│   ├── address_service.dart
│   ├── payment_method_service.dart
│   ├── order_service.dart
│   └── review_service.dart
├── screens/
│   ├── auth/                    Login, Register, Forgot Password
│   ├── home/                    MainShell (bottom nav), Home
│   ├── catalog/                 Browse, Book Details, Reviews, Write Review
│   ├── cart/                    Cart, Wishlist, Checkout, Order Placed
│   ├── profile/                 Profile, Edit, Addresses, Payments, Orders, Track
│   └── admin/                   Admin login, shell, dashboard, manage screens
├── widgets/                     Reusable UI
│   ├── book_card.dart
│   ├── book_cover_placeholder.dart
│   ├── custom_textfield.dart
│   ├── section_header.dart
│   ├── filter_sheet.dart
│   └── sort_sheet.dart
└── utils/
    ├── app_colors.dart          Color palette
    ├── app_text_styles.dart     Typography
    ├── app_theme.dart           Global theme
    ├── app_state.dart           Global ValueNotifiers
    ├── auth_guard.dart          Login-gated actions
    └── validators.dart          Form validation
```

## Architecture

The app follows a simple **3-layer architecture**.

### Layer 1 — Screens (UI)

Every screen is a `StatelessWidget` or `StatefulWidget`. Screens contain zero business logic. They load data via a service, render UI using `AppColors` and `AppTextStyles`, and never touch SQLite directly.

### Layer 2 — Services (Logic + DB access)

Each service owns one domain. They wrap all database queries, enforce validation, and return plain Dart models.

Standard pattern:

```dart
class SomethingService {
  static final SomethingService instance = SomethingService._internal();
  SomethingService._internal();

  Future<List<Something>> getAll() async { ... }
  Future<int> add(Something s) async { ... }
  Future<void> update(Something s) async { ... }
  Future<void> remove(int id) async { ... }
}
```

### Layer 3 — Models (Data classes)

Each model represents one row of a SQL table. Every model has:

- `final` fields
- A named-parameter constructor
- `toMap()` — Dart object → Map (for SQL)
- `fromMap()` — Map (SQL row) → Dart object

Map keys must match SQL column names exactly.

## Database schema

Opened once by `DatabaseService`. Versioned. Upgrades handled via `_onUpgrade`.

### Table: users

- `id` — INTEGER PRIMARY KEY AUTOINCREMENT
- `name` — TEXT NOT NULL
- `email` — TEXT UNIQUE NOT NULL
- `password` — TEXT NOT NULL (plain text; see Security below)
- `phone` — TEXT (nullable)
- `role` — TEXT NOT NULL DEFAULT 'user'
- `created_at` — TEXT NOT NULL (ISO string)

### Table: books

- `id` — INTEGER PRIMARY KEY
- `title`, `author`, `genre`, `description` — TEXT
- `cover_image` — TEXT (nullable)
- `price`, `rating` — REAL
- `review_count`, `stock` — INTEGER
- `badge` — TEXT
- `published_date` — TEXT
- `format` — TEXT

### Table: addresses

- `id` — INTEGER PRIMARY KEY
- `user_id` — INTEGER (FK users)
- `label`, `street`, `city`, `state`, `zip`, `country` — TEXT

### Table: payment_methods

- `id` — INTEGER PRIMARY KEY
- `user_id` — INTEGER (FK users)
- `card_holder`, `card_number`, `expiry`, `brand` — TEXT

### Table: cart_items

- `id` — INTEGER PRIMARY KEY
- `user_id` — INTEGER (FK users)
- `book_id` — INTEGER
- `title`, `author` — TEXT
- `price` — REAL
- `quantity` — INTEGER
- `genre`, `cover_image` — TEXT

### Table: wishlist_items

- `id` — INTEGER PRIMARY KEY
- `user_id` — INTEGER (FK users)
- `book_id` — INTEGER
- `title`, `author` — TEXT
- `price` — REAL
- `genre`, `added_at`, `cover_image` — TEXT

### Table: reviews

- `id` — INTEGER PRIMARY KEY
- `user_id`, `book_id` — INTEGER (FKs)
- `rating` — INTEGER (1–5)
- `comment`, `created_at` — TEXT

### Table: orders

- `id` — INTEGER PRIMARY KEY
- `user_id` — INTEGER (FK users)
- `order_number` — TEXT
- `status` — TEXT ('Pending', 'Processing', 'Shipped', 'Out for Delivery', 'Delivered')
- `subtotal`, `shipping`, `total` — REAL
- `shipping_address`, `payment_method`, `placed_at` — TEXT

### Table: order_items

- `id` — INTEGER PRIMARY KEY
- `order_id` — INTEGER (FK orders)
- `book_id` — INTEGER
- `title`, `author` — TEXT
- `price` — REAL
- `quantity` — INTEGER
- `genre`, `cover_image` — TEXT

Foreign keys cascade on delete: deleting a user removes their addresses, payments, cart, wishlist, and orders.

## How to add a new screen

1. Create the file in the right `screens/` folder.
2. Use the standard Stateful pattern:

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _loading = true;
  List<Thing> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await ThingService.instance.getAll();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(/* UI */);
  }
}
```

3. Use `AppColors.X` and `AppTextStyles.X` — never hardcode colors or fonts.
4. Always check `mounted` after every `await`.

## How to add a new model

```dart
class Thing {
  final int? id;
  final String name;

  const Thing({this.id, required this.name});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  factory Thing.fromMap(Map<String, dynamic> row) => Thing(
    id: row['id'] as int?,
    name: row['name'] as String,
  );
}
```

## How to add a new table

1. Open `lib/services/database_service.dart`.
2. Bump `version:` by 1.
3. Add the `CREATE TABLE` inside `_onCreate`.
4. Add the same `CREATE TABLE` inside `_onUpgrade` under a new `if (oldVersion < N)` guard.
5. Uninstall the app from the emulator so the DB rebuilds fresh:

```powershell
adb uninstall com.example.book_store_app
flutter run
```

## How to run the project

```powershell
git clone https://github.com/joeama25/leaf-and-lore.git
cd leaf-and-lore
flutter pub get
flutter run
```

Pick the Android emulator when prompted.

- **Hot reload:** `r` (small changes)
- **Hot restart:** `R` (widget structure changes)
- **Quit:** `q`

## Design system

### Colors (`lib/utils/app_colors.dart`)

- **forest** — `#1F3A2E` — primary, buttons, headers
- **cream** — `#FAF7F0` — background
- **gold** — `#C9A961` — accents, stars
- **ink** — `#1A1A1A` — body text
- **inkMuted** — `#6B6B5F` — secondary text
- **sage** — `#C9D5C0` — soft green accents
- **border** — `#E5E0D5` — dividers
- **danger** — `#A84832` — errors

### Typography (`lib/utils/app_text_styles.dart`)

- `display` — Playfair Display 36
- `heading` — Playfair Display 24
- `title` — Playfair Display 18
- `eyebrow` — Inter 10 uppercase
- `body` — Inter 15
- `bodyMuted` — Inter 14
- `small` — Inter 12
- `button` — Inter 14 semibold

## Admin panel

Access: log in with an admin account, then Profile → **Admin portal** → sign in.

Default admin (auto-seeded on first install):

- **Email:** admin@leafandlore.com
- **Password:** admin123

Admin screens:

- **Dashboard** — Total books, users, orders, pending orders
- **Books** — Add, edit, delete books
- **Users** — View reader accounts
- **Orders** — Update order status

## Security note

Passwords are currently stored in plain text in SQLite. For production, hash them with `bcrypt` or `argon2` before storing. SQLite itself provides no encryption. This is acceptable for the eProject scope.

## Git workflow

```
git pull origin main
git checkout -b feat/your-feature
# work...
git add .
git commit -m "feat: what you did"
git push origin feat/your-feature
```

Open a Pull Request. Never push directly to `main`.

Commit prefixes: `feat:`, `fix:`, `style:`, `refactor:`, `docs:`

## Common errors

- **`no such table: X`** — uninstall app + `flutter run`
- **`no such column: X`** — model key doesn't match SQL column name
- **`RenderBox was not laid out`** — add `mainAxisSize: MainAxisSize.min`; use AspectRatio
- **`BOTTOM OVERFLOWED BY N pixels`** — increase the parent's fixed height
- **`Unable to load asset`** — register the folder in `pubspec.yaml` under `assets:`
- **`_XState is not a subtype of State`** — press `R` (hot restart), not `r`