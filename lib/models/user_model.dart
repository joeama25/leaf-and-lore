class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String role;
  final String createdAt;


  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.role= 'user',
    required this.createdAt,
  });


  Map<String, dynamic> toMap()=> {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'role': role,
    'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    password: map['password'] as String,
    phone: map['phone'] as String?,
    role: map['role'] as String,
    createdAt: map['created_at'] as String,
  );
}

// A model represents one row of a database table.
// It:
//   1. Holds data (fields)
//   2. Has a constructor to build a new object from named arguments
//   3. toMap()   → object → Map  (for INSERT/UPDATE)
//   4. fromMap() → Map → object  (for SELECT results)
// fromMap uses `factory` because it doesn't allocate directly —
// it constructs the object from an existing Map (a SQL row).