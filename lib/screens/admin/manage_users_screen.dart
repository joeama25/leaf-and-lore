
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/database_service.dart';

class ManageUsersScreen extends StatefulWidget {
const ManageUsersScreen({super.key});

@override
State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
static const Color _forest = Color(0xFF1F3A2E);
static const Color _cream = Color(0xFFFAF7F0);
static const Color _gold = Color(0xFFC9A961);
static const Color _muted = Color(0xFF6B6B5F);

final TextEditingController _searchController = TextEditingController();

List<UserModel> _users = [];
bool _loading = true;
String? _error;
String _searchQuery = '';

@override
void initState() {
super.initState();
_loadUsers();
}

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

Future<void> _loadUsers() async {
setState(() {
_loading = true;
_error = null;
});

try {
final db = await DatabaseService.instance.database;
final rows = await db.query(
'users',
orderBy: 'id DESC',
);

final users = rows.map((row) => UserModel.fromMap(row)).toList();

if (!mounted) return;

setState(() {
_users = users;
_loading = false;
});
} catch (error) {
if (!mounted) return;

setState(() {
_error = 'Could not load users. Please try again.';
_loading = false;
});
}
}

List<UserModel> get _filteredUsers {
final query = _searchQuery.trim().toLowerCase();

if (query.isEmpty) return _users;

return _users.where((user) {
return user.name.toLowerCase().contains(query) ||
user.email.toLowerCase().contains(query) ||
user.role.toLowerCase().contains(query);
}).toList();
}

int get _adminCount =>
_users.where((user) => user.role.toLowerCase() == 'admin').length;

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: _cream,
body: SafeArea(
child: RefreshIndicator(
color: _forest,
onRefresh: _loadUsers,
child: ListView(
padding: const EdgeInsets.all(20),
children: [
const Text(
'Manage Users',
style: TextStyle(
color: _forest,
fontSize: 27,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 6),
const Text(
'View registered customers and administrator accounts.',
style: TextStyle(color: _muted, fontSize: 14),
),
const SizedBox(height: 22),
_buildSummaryCard(),
const SizedBox(height: 22),
TextField(
controller: _searchController,
onChanged: (value) {
setState(() => _searchQuery = value);
},
decoration: InputDecoration(
hintText: 'Search name, email or role',
prefixIcon: const Icon(Icons.search, color: _forest),
suffixIcon: _searchQuery.isEmpty
? null
    : IconButton(
onPressed: () {
_searchController.clear();
setState(() => _searchQuery = '');
},
icon: const Icon(Icons.close),
),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: Color(0xFFE5E0D5)),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: Color(0xFFE5E0D5)),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: const BorderSide(color: _forest, width: 1.5),
),
),
),
const SizedBox(height: 18),
Row(
children: [
const Expanded(
child: Text(
'Registered accounts',
style: TextStyle(
color: _forest,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
Text(
'${_filteredUsers.length} found',
style: const TextStyle(color: _muted),
),
],
),
const SizedBox(height: 12),
if (_loading)
const Padding(
padding: EdgeInsets.all(40),
child: Center(
child: CircularProgressIndicator(color: _forest),
),
)
else if (_error != null)
_buildMessage(
icon: Icons.error_outline,
message: _error!,
buttonText: 'Try again',
onPressed: _loadUsers,
)
else if (_filteredUsers.isEmpty)
_buildMessage(
icon: Icons.people_outline,
message: _users.isEmpty
? 'No users have registered yet.'
    : 'No users match your search.',
buttonText: _users.isEmpty ? 'Refresh' : 'Clear search',
onPressed: _users.isEmpty
? _loadUsers
    : () {
_searchController.clear();
setState(() => _searchQuery = '');
},
)
else
..._filteredUsers.map(_buildUserCard),
],
),
),
),
);
}

Widget _buildSummaryCard() {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: _forest,
borderRadius: BorderRadius.circular(18),
),
child: Row(
children: [
Container(
width: 52,
height: 52,
decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.12),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.groups_outlined,
color: _gold,
size: 29,
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Total registered users',
style: TextStyle(color: Colors.white70, fontSize: 13),
),
const SizedBox(height: 5),
Text(
'$_usersCount',
style: const TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
],
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
decoration: BoxDecoration(
color: _gold.withValues(alpha: 0.16),
borderRadius: BorderRadius.circular(12),
),
child: Column(
children: [
Text(
'$_adminCount',
style: const TextStyle(
color: _gold,
fontWeight: FontWeight.bold,
fontSize: 18,
),
),
const Text(
'Admins',
style: TextStyle(color: Colors.white70, fontSize: 11),
),
],
),
),
],
),
);
}

int get _usersCount => _users.length;

Widget _buildUserCard(UserModel user) {
final isAdmin = user.role.toLowerCase() == 'admin';
final initial = user.name.trim().isEmpty
? '?'
    : user.name.trim()[0].toUpperCase();

return Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: const Color(0xFFE5E0D5)),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
CircleAvatar(
radius: 24,
backgroundColor: isAdmin
? _gold.withValues(alpha: 0.22)
    : const Color(0xFFC9D5C0),
child: Text(
initial,
style: const TextStyle(
color: _forest,
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
user.name,
style: const TextStyle(
color: _forest,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 5),
Text(
user.email,
style: const TextStyle(color: _muted, fontSize: 13),
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 10),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 5,
),
decoration: BoxDecoration(
color: isAdmin
? _gold.withValues(alpha: 0.20)
    : const Color(0xFFC9D5C0).withValues(alpha: 0.55),
borderRadius: BorderRadius.circular(20),
),
child: Text(
isAdmin ? 'ADMINISTRATOR' : 'CUSTOMER',
style: TextStyle(
color: _forest,
fontSize: 10,
letterSpacing: 0.7,
fontWeight: FontWeight.bold,
),
),
),
],
),
),
const SizedBox(width: 8),
Icon(
isAdmin ? Icons.shield_outlined : Icons.person_outline,
color: isAdmin ? _gold : _muted,
),
],
),
);
}

Widget _buildMessage({
required IconData icon,
required String message,
required String buttonText,
required VoidCallback onPressed,
}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 35),
child: Column(
children: [
Icon(icon, size: 42, color: _muted),
const SizedBox(height: 12),
Text(
message,
textAlign: TextAlign.center,
style: const TextStyle(color: _muted),
),
const SizedBox(height: 16),
OutlinedButton(
onPressed: onPressed,
style: OutlinedButton.styleFrom(
foregroundColor: _forest,
side: const BorderSide(color: _forest),
),
child: Text(buttonText),
),
],
),
);
}
}

