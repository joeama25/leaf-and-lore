
import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color _forest = Color(0xFF1F3A2E);
  static const Color _cream = Color(0xFFFAF7F0);
  static const Color _gold = Color(0xFFC9A961);

  bool _loading = true;
  String? _error;
  int _books = 0;
  int _users = 0;
  int _orders = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = await DatabaseService.instance.database;

      final books = await db.rawQuery('SELECT COUNT(*) AS total FROM books');
      final users = await db.rawQuery('SELECT COUNT(*) AS total FROM users');
      final orders = await db.rawQuery('SELECT COUNT(*) AS total FROM orders');

      if (!mounted) return;

      setState(() {
        _books = (books.first['total'] as num).toInt();
        _users = (users.first['total'] as num).toInt();
        _orders = (orders.first['total'] as num).toInt();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not load dashboard statistics.';
        _loading = false;
      });
    }
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _forest, size: 28),
          const SizedBox(height: 18),
          Text(
            _loading ? '...' : '$value',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _forest,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required int index,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E0D5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _cream,
          child: Icon(icon, color: _forest),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => widget.onNavigate(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      color: _forest,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Good to see you.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _forest,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is an overview of your bookstore.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('Could not load statistics.')),
                  TextButton(
                    onPressed: _loadStats,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          if (_loading && _error == null)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_loading)
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 650 ? 3 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _statCard(
                      title: 'Books',
                      value: _books,
                      icon: Icons.menu_book_outlined,
                    ),
                    _statCard(
                      title: 'Users',
                      value: _users,
                      icon: Icons.people_outline,
                    ),
                    _statCard(
                      title: 'Orders',
                      value: _orders,
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 30),
          const Text(
            'Quick access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _forest,
            ),
          ),
          const SizedBox(height: 12),
          _quickAction(
            title: 'Manage books',
            subtitle: 'Add, edit, and remove titles',
            icon: Icons.library_books_outlined,
            index: 1,
          ),
          _quickAction(
            title: 'Manage users',
            subtitle: 'View registered customers',
            icon: Icons.group_outlined,
            index: 2,
          ),
          _quickAction(
            title: 'Manage orders',
            subtitle: 'Review and update orders',
            icon: Icons.receipt_long_outlined,
            index: 3,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _forest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_outlined, color: _gold, size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'A thoughtful reading experience starts with a well-managed bookstore.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
