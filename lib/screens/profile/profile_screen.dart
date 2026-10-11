import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import '../admin/admin_login_screen.dart';
import 'addresses_screen.dart';
import 'edit_profile_screen.dart';
import 'orders_screen.dart';
import 'payments_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await _auth.currentUserId();
    if (id == null) {
      if (mounted) setState(() { _user = null; _loading = false; });
      return;
    }
    try {
      final db = await DatabaseService.instance.database;
      final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (!mounted) return;
      setState(() {
        _user = rows.isEmpty ? null : UserModel.fromMap(rows.first);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requireLogin() async {
    final ok = await AuthGuard.requireLogin(context);
    if (ok) _load();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text('My profile', style: AppTextStyles.display),
            const SizedBox(height: 6),
            Text('Your little corner of leaf & lore',
                style: AppTextStyles.bodyMuted),
            const SizedBox(height: 24),
            _accountCard(),
            const SizedBox(height: 32),

            const Text('ACCOUNT', style: AppTextStyles.eyebrow),
            const SizedBox(height: 12),
            _menuTile(Icons.person_outline, 'Edit profile', _openEditProfile),
            _menuTile(Icons.location_on_outlined, 'My addresses', _openAddresses),
            _menuTile(Icons.credit_card_outlined, 'Payment methods', _openPayments),
            _menuTile(Icons.receipt_long_outlined, 'My orders', _openOrders),
            _menuTile(Icons.favorite_border, 'Wishlist', _openWishlist),

            const SizedBox(height: 24),
            const Text('MORE FROM LEAF & LORE', style: AppTextStyles.eyebrow),
            const SizedBox(height: 12),
            _menuTile(Icons.help_outline, 'Help & FAQ', _openHelp),
            _menuTile(Icons.menu_book_outlined, 'User guide', _openUserGuide),

            if (_user?.role == 'admin') ...[
              const SizedBox(height: 24),
              const Text('STAFF ACCESS', style: AppTextStyles.eyebrow),
              const SizedBox(height: 12),
              _menuTile(Icons.shield_outlined, 'Admin portal', () =>
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen(),
                  )),
              ),
            ],

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
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.tan, shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  signedIn ? _initials(_user!.name) : 'GR',
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay', fontSize: 20,
                    fontWeight: FontWeight.w500, color: AppColors.forest,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('READER ACCOUNT',
                        style: AppTextStyles.eyebrow),
                    const SizedBox(height: 4),
                    Text(
                      signedIn ? _user!.name : 'Guest Reader',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.white, fontSize: 22,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      signedIn ? _user!.email
                          : 'Sign in to keep your stories close',
                      style: AppTextStyles.bodyMuted
                          .copyWith(color: AppColors.sage),
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
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.forest, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppTextStyles.body)),
              const Icon(Icons.chevron_right,
                  color: AppColors.inkMuted, size: 20),
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
            const Icon(Icons.logout, color: AppColors.danger, size: 20),
            const SizedBox(width: 12),
            Text('Log out',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.danger)),
          ],
        ),
      ),
    );
  }

  // ── Navigation ────────────────────────────────────
  Future<void> _openEditProfile() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      return;
    }
    final result = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => EditProfileScreen(user: _user!),
    ));
    if (result == true) _load();
  }

  Future<void> _openAddresses() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      return;
    }
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => const AddressesScreen(),
    ));
  }

  Future<void> _openPayments() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      return;
    }
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => const PaymentsScreen(),
    ));
  }

  Future<void> _openOrders() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      return;
    }
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => const OrdersScreen(),
    ));
  }

  void _openWishlist() {
    AppState.selectedTab.value = 2;
  }

  void _openHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Help & FAQ', style: AppTextStyles.heading),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _FaqItem('Do I need an account?',
                  'No — you can browse as a guest. Sign in when you want to save books, add to cart or place an order.'),
              _FaqItem('How do I save a book?',
                  'Tap the heart icon on any book cover. Saved books appear in the Wishlist tab.'),
              _FaqItem('How do I track my order?',
                  'Profile → My orders → tap the order → Track order.'),
              _FaqItem('Payment didnt go through?',
                  'Check your saved card under Payment methods, or contact support.'),
              _FaqItem('How do I get help?',
                  'Email support@leafandlore.com — we reply within 24 hours.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openUserGuide() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('User guide', style: AppTextStyles.heading),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _FaqItem('1. Create an account',
                  'Tap Create an account on the login screen. Or browse as a guest first.'),
              _FaqItem('2. Explore books',
                  'Home shows Editors picks, Bestsellers and New arrivals. Browse has filters and search.'),
                  _FaqItem('3. Add to cart',
                  'On any book, tap Add to cart. Adjust quantity with + and −.'),
              _FaqItem('4. Checkout',
                  'Cart → Proceed to checkout. Choose shipping, payment, review, place order.'),
              _FaqItem('5. Manage your account',
                  'Profile → Edit profile, My addresses, Payment methods, My orders.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String q;
  final String a;
  const _FaqItem(this.q, this.a);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 4),
          Text(a, style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}