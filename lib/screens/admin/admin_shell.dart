
import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'manage_books_screen.dart';
import 'manage_users_screen.dart';
import 'manage_orders_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const Color _forest = Color(0xFF1F3A2E);
  static const Color _cream = Color(0xFFFAF7F0);
  static const Color _gold = Color(0xFFC9A961);

  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  final List<String> _titles = const [
    'Dashboard',
    'Books',
    'Users',
    'Orders',
  ];

  late final List<Widget> _screens = [
    AdminDashboardScreen(onNavigate: _navigateTo),
    const ManageBooksScreen(),
    const ManageUsersScreen(),
    const ManageOrdersScreen(),
  ];

  void _navigateTo(int index) {
    _selectedIndex.value = index;
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          backgroundColor: _cream,
          appBar: AppBar(
            backgroundColor: _forest,
            foregroundColor: Colors.white,
            title: Text('leaf & lore | ${_titles[selectedIndex]}'),
            actions: [
              IconButton(
                tooltip: 'Exit admin portal',
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                      (route) => false,
                ),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            backgroundColor: Colors.white,
            indicatorColor: _gold.withValues(alpha: 0.25),
            onDestinationSelected: _navigateTo,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Books',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
            ],
          ),
        );
      },
    );
  }
}
