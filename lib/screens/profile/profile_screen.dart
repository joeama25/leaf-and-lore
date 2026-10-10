import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';
import 'addresses_screen.dart';
import 'payments_screen.dart';
import 'orders_screen.dart';

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
      if (mounted) {
        setState(() {
          _user = null;
          _loading = false;
        });
      }
      return;
    }
    try {
      final db = await DatabaseService.instance.database;
      final rows =
      await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (!mounted) return;
      setState(() {
        _user = rows.isEmpty ? null : UserModel.fromMap(rows.first);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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
            Text(
              'Your little corner of leaf & lore',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),

            _accountCard(),
            const SizedBox(height: 32),

            const Text('ACCOUNT', style: AppTextStyles.eyebrow),
            const SizedBox(height: 12),

            _menuTile(Icons.person_outline, 'Edit profile', _guardOrSkip),
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
            _menuTile(Icons.receipt_long_outlined, 'My orders', _openOrders),
            _menuTile(Icons.favorite_border, 'Wishlist', _guardOrSkip),

            const SizedBox(height: 24),

            const Text('MORE FROM LEAF & LORE',
                style: AppTextStyles.eyebrow),
            const SizedBox(height: 12),
            _menuTile(Icons.help_outline, 'Help & FAQ', () {}),
            _menuTile(Icons.menu_book_outlined, 'User guide', () {}),

            if (_user != null) ...[
              const SizedBox(height: 28),
              _logoutTile(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Account card ─────────────────────────────────────────────
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

  // ── Menu tile ────────────────────────────────────────────────
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
                width: 36,
                height: 36,
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
            Text(
              'Log out',
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  // ── Guard helper ─────────────────────────────────────────────
  Future<void> _guardOrSkip() async {
    if (_user == null) {
      await _requireLogin();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        );
      }
    }
  }

  // ── Navigate helpers ─────────────────────────────────────────
  Future<void> _openAddresses() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressesScreen()),
    );
  }

  Future<void> _openOrders() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      if (!mounted) return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _openPayments() async {
    if (_user == null) {
      final ok = await AuthGuard.requireLogin(context);
      if (!ok || !mounted) return;
      await _load();
      return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentsScreen()),
    );
  }
}