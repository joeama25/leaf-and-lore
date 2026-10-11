import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/app_text_styles.dart';
import 'admin_dashboard_screen.dart';
import 'manage_books_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.adminTab,
      builder: (context, idx, _) {
        return Scaffold(
          body: IndexedStack(
            index: idx,
            children: const [
              AdminDashboardScreen(),
              ManageBooksScreen(),
              ManageUsersScreen(),
              ManageOrdersScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.cream,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navItem(0, Icons.dashboard_outlined,
                        Icons.dashboard, 'Dashboard'),
                    _navItem(1, Icons.menu_book_outlined,
                        Icons.menu_book, 'Books'),
                    _navItem(2, Icons.people_outline, Icons.people, 'Users'),
                    _navItem(3, Icons.receipt_long_outlined,
                        Icons.receipt_long, 'Orders'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(int idx, IconData icon, IconData activeIcon, String label) {
    final active = AppState.adminTab.value == idx;
    return GestureDetector(
      onTap: () => AppState.adminTab.value = idx,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? AppColors.forest : AppColors.inkMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: active ? AppColors.forest : AppColors.inkMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}