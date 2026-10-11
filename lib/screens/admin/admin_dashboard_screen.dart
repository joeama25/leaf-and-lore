import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _books = 0;
  int _users = 0;
  int _orders = 0;
  int _pending = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = await DatabaseService.instance.database;
      final books = await db.rawQuery('SELECT COUNT(*) AS c FROM books');
      final users = await db.rawQuery('SELECT COUNT(*) AS c FROM users');
      final orders = await db.rawQuery('SELECT COUNT(*) AS c FROM orders');
      final pending = await db.rawQuery(
          "SELECT COUNT(*) AS c FROM orders WHERE status = 'Pending'");
      if (!mounted) return;
      setState(() {
        _books = books.first['c'] as int? ?? 0;
        _users = users.first['c'] as int? ?? 0;
        _orders = orders.first['c'] as int? ?? 0;
        _pending = pending.first['c'] as int? ?? 0;
        _loading = false;
      });
    } catch (e) {
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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.heading.copyWith(fontSize: 20),
                      children: const [
                        TextSpan(text: 'leaf '),
                        TextSpan(text: '&',
                            style: TextStyle(color: AppColors.gold)),
                        TextSpan(text: ' lore'),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.logout, color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('STAFF WORKSPACE', style: AppTextStyles.eyebrow),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: AppTextStyles.display,
                children: const [
                  TextSpan(text: 'Good morning,\n'),
                  TextSpan(
                    text: 'team.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.forest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text("Here's what's happening in your bookstore.",
                style: AppTextStyles.bodyMuted),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _statCard(Icons.menu_book_outlined,
                    'Total books', '$_books')),
                const SizedBox(width: 12),
                Expanded(child: _statCard(Icons.people_outline,
                    'Total users', '$_users')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard(Icons.receipt_long_outlined,
                    'Total orders', '$_orders')),
                const SizedBox(width: 12),
                Expanded(child: _statCard(Icons.schedule,
                    'Pending orders', '$_pending')),
              ],
            ),
            const SizedBox(height: 32),
            const Text('QUICK ACCESS', style: AppTextStyles.eyebrow),
            const SizedBox(height: 6),
            const Text('Manage store', style: AppTextStyles.heading),
            const SizedBox(height: 12),
            _menuTile(Icons.menu_book_outlined, 'Books',
                'Add, edit and organize your catalog', 1),
            _menuTile(Icons.people_outline, 'Users',
                'View reader accounts and details', 2),
            _menuTile(Icons.receipt_long_outlined, 'Orders',
                'Review and update order status', 3),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.forest, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label.toUpperCase(),
              style: AppTextStyles.eyebrow.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 28, fontWeight: FontWeight.w500,
                color: AppColors.ink,
              )),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, String subtitle, int tabIndex) {
    return GestureDetector(
      onTap: () => AppState.adminTab.value = tabIndex,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.small),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.inkMuted, size: 20),
          ],
        ),
      ),
    );
  }
}