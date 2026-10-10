
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../admin/admin_login_screen.dart';
import 'addresses_screen.dart';
import 'payments_screen.dart';
import 'wishlist_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
final _auth = AuthService();

UserModel? _user;
bool _loading = true;
bool _loadError = false;
@override
void initState() {
super.initState();
_load();
}

Future<void> _load() async {
if (mounted) {
setState(() {
_loading = true;
_loadError = false;
});
}

try {
final id = await _auth.currentUserId();

if (id == null) {
if (!mounted) return;
setState(() {
_user = null;
_loading = false;
});
return;
}

final db = await DatabaseService.instance.database;
final rows = await db.query(
'users',
where: 'id = ?',
whereArgs: [id],
limit: 1,
);

if (!mounted) return;

setState(() {
_user = rows.isEmpty ? null : UserModel.fromMap(rows.first);
_loading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_loading = false;
_loadError = true;
});
}
}

Future<void> _requireLogin() async {
final ok = await AuthGuard.requireLogin(context);

if (ok && mounted) {
await _load();
}
}

Future<bool> _ensureSignedIn() async {
if (_user != null) return true;

await _requireLogin();

return mounted && _user != null;
}

Future<void> _logout() async {
try {
await _auth.logout();

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
'/home',
(route) => false,
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Unable to log out. Please try again.'),
),
);
}
}

Future<void> _openAdminPortal() async {
if (_user?.role != 'admin' || !mounted) return;

await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const AdminLoginScreen(),
),
);
}

Future<void> _openWishlist() async {
if (!await _ensureSignedIn() || !mounted) return;

await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const WishlistScreen(),
),
);
}

Future<void> _openAddresses() async {
if (!await _ensureSignedIn() || !mounted) return;

await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const AddressesScreen(),
),
);
}

Future<void> _openPayments() async {
if (!await _ensureSignedIn() || !mounted) return;

await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const PaymentsScreen(),
),
);
}

Future<void> _openOrders() async {
if (!await _ensureSignedIn() || !mounted) return;

await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const MyOrdersScreen(),
),
);
}

void _openHelp() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const HelpFaqScreen(),
),
);
}

void _openUserGuide() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const UserGuideScreen(),
),
);
}

@override
Widget build(BuildContext context) {
if (_loading) {
return const Scaffold(
body: Center(child: CircularProgressIndicator()),
);
}

if (_loadError) {
return Scaffold(
body: Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.error_outline, size: 42),
const SizedBox(height: 12),
const Text('Unable to load your profile.'),
const SizedBox(height: 16),
ElevatedButton(
onPressed: _load,
child: const Text('Try again'),
),
],
),
),
),
);
}

return Scaffold(
body: SafeArea(
child: ListView(
padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
children: [
const Text(
'My profile',
style: AppTextStyles.display,
),
const SizedBox(height: 6),
Text(
'Your little corner of leaf & lore',
style: AppTextStyles.bodyMuted,
),
const SizedBox(height: 24),
_accountCard(),
const SizedBox(height: 32),
const Text(
'ACCOUNT',
style: AppTextStyles.eyebrow,
),
const SizedBox(height: 12),
_menuTile(
Icons.person_outline,
'Edit profile',
() {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Edit profile is not available yet.'),
),
);
},
),
_menuTile(
Icons.location_on_outlined,
'My addresses',
_openAddresses,
),
_menuTile(
Icons.credit_card_outlined,
'Payment methods',
_openPayments,
),
_menuTile(
Icons.receipt_long_outlined,
'My orders',
_openOrders,
),
_menuTile(
Icons.favorite_border,
'Wishlist',
_openWishlist,
),
if (_user?.role == 'admin') ...[
const SizedBox(height: 12),
_menuTile(
Icons.admin_panel_settings_outlined,
'Admin Portal',
_openAdminPortal,
),
],

const SizedBox(height: 12),
_menuTile(
Icons.help_outline,
'Help & FAQ',
_openHelp,
),
_menuTile(
Icons.menu_book_outlined,
'User guide',
_openUserGuide,
),
if (_user != null) ...[
const SizedBox(height: 28),
_logoutTile(),
],
],
),
),
);
}

Widget _accountCard() {
final signedIn = _user != null;

return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.forest,
borderRadius: BorderRadius.circular(16),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
Row(
children: [
Container(
width: 56,
height: 56,
decoration: const BoxDecoration(
color: AppColors.tan,
shape: BoxShape.circle,
),
alignment: Alignment.center,
child: Text(
signedIn ? _initials(_user!.name) : 'GR',
style: const TextStyle(
fontFamily: 'PlayfairDisplay',
fontSize: 20,
fontWeight: FontWeight.w500,
color: AppColors.forest,
),
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
const Text(
'READER ACCOUNT',
style: AppTextStyles.eyebrow,
),
const SizedBox(height: 4),
Text(
signedIn ? _user!.name : 'Guest Reader',
style: AppTextStyles.heading.copyWith(
color: AppColors.white,
fontSize: 22,
),
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 2),
Text(
signedIn
? _user!.email
    : 'Sign in to keep your stories close',
style: AppTextStyles.bodyMuted.copyWith(
color: AppColors.sage,
),
overflow: TextOverflow.ellipsis,
),
],
),
),
],
),
if (!signedIn) ...[
const SizedBox(height: 16),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: _requireLogin,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.white,
foregroundColor: AppColors.forest,
),
child: const Text('Sign in or create an account'),
),
),
],
],
),
);
}

String _initials(String name) {
final parts = name.trim().split(RegExp(r'\s+'));

if (parts.isEmpty || parts.first.isEmpty) {
return '?';
}

if (parts.length == 1) {
return parts.first.substring(0, 1).toUpperCase();
}

return (parts[0][0] + parts[1][0]).toUpperCase();
}

Widget _menuTile(
IconData icon,
String label,
VoidCallback onTap,
) {
return Padding(
padding: const EdgeInsets.only(bottom: 10),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(12),
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 14,
),
decoration: BoxDecoration(
color: AppColors.white,
border: Border.all(color: AppColors.border),
borderRadius: BorderRadius.circular(12),
),
child: Row(
children: [
Container(
width: 36,
height: 36,
decoration: BoxDecoration(
color: AppColors.sage,
borderRadius: BorderRadius.circular(8),
),
child: Icon(
icon,
color: AppColors.forest,
size: 18,
),
),
const SizedBox(width: 14),
Expanded(
child: Text(
label,
style: AppTextStyles.body,
),
),
const Icon(
Icons.chevron_right,
color: AppColors.inkMuted,
size: 20,
),
],
),
),
),
);
}

Widget _logoutTile() {
return InkWell(
onTap: _logout,
borderRadius: BorderRadius.circular(12),
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 14),
child: Row(
children: [
const Icon(
Icons.logout,
color: AppColors.danger,
size: 20,
),
const SizedBox(width: 12),
Text(
'Log out',
style: AppTextStyles.body.copyWith(
color: AppColors.danger,
),
),
],
),
),
);
}
}

class HelpFaqScreen extends StatelessWidget {
const HelpFaqScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Help & FAQ')),
body: ListView(
padding: const EdgeInsets.all(20),
children: const [
Text(
'How do I save a book?',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
SizedBox(height: 8),
Text('Tap the heart icon on a book to add it to your wishlist.'),
Divider(height: 32),
Text(
'How do I manage my addresses?',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
SizedBox(height: 8),
Text('Open My Profile, then choose My addresses.'),
Divider(height: 32),
Text(
'How do I manage payment methods?',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
SizedBox(height: 8),
Text('Open My Profile and select Payment methods.'),
Divider(height: 32),
Text(
'How do I sign out?',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
SizedBox(height: 8),
Text('Scroll to the bottom of your profile and tap Log out.'),
],
),
);
}
}

class UserGuideScreen extends StatelessWidget {
const UserGuideScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('User Guide')),
body: ListView(
padding: const EdgeInsets.all(20),
children: const [
Text(
'Welcome to leaf & lore',
style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
),
SizedBox(height: 16),
Text(
'1. Browse books to explore the collection.\n\n'
'2. Open a book to view its details.\n\n'
'3. Use the heart icon to save books to your wishlist.\n\n'
'4. Sign in to manage your addresses, payment methods, and saved books.\n\n'
'5. Open your profile to access your account options.',
style: TextStyle(fontSize: 16, height: 1.6),
),
],
),
);
}
}
