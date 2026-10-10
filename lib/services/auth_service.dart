
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
static const _sessionKey = 'logged_in_user_id';

Future<UserModel?> register({
required String name,
required String email,
required String password,
String? phone,
}) async {
final db = await DatabaseService.instance.database;

final existing = await db.query(
'users',
where: 'email = ?',
whereArgs: [email],
);

if (existing.isNotEmpty) {
throw Exception('Email already registered');
}

final user = UserModel(
name: name,
email: email,
password: password,
phone: phone,
createdAt: DateTime.now().toIso8601String(),
);

final id = await db.insert('users', user.toMap());
await _saveSession(id);

return UserModel.fromMap({
...user.toMap(),
'id': id,
});
}

Future<UserModel?> login({
required String email,
required String password,
}) async {
final db = await DatabaseService.instance.database;

final rows = await db.query(
'users',
where: 'email = ? AND password = ?',
whereArgs: [email, password],
);

if (rows.isEmpty) {
throw Exception('Invalid email or password');
}

final user = UserModel.fromMap(rows.first);
await _saveSession(user.id!);

return user;
}

Future<void> logout() async {
final prefs = await SharedPreferences.getInstance();
await prefs.remove(_sessionKey);
}

Future<int?> currentUserId() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getInt(_sessionKey);
}

Future<void> _saveSession(int userId) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setInt(_sessionKey, userId);
}

Future<bool> isLoggedIn() async {
final id = await currentUserId();
return id != null;
}

// TEMPORARY DEVELOPMENT METHOD.
// Remove this method after promoting your test account.
Future<void> promoteCurrentUserToAdmin() async {
final userId = await currentUserId();

if (userId == null) {
throw Exception('Please sign in first.');
}

final db = await DatabaseService.instance.database;

final updated = await db.update(
'users',
{'role': 'admin'},
where: 'id = ?',
whereArgs: [userId],
);

if (updated == 0) {
throw Exception('User account not found.');
}
}
}
