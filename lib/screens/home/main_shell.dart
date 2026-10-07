import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/app_text_styles.dart';
import '../catalog/browse_screen.dart';
import '../cart/cart_screen.dart';
import '../cart/wishlist_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.selectedTab,
      builder: (context, idx, _) {
        return Scaffold(
          body: _screenFor(idx),
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
                    _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
                    _navItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Browse'),
                    _navItem(2, Icons.favorite_border, Icons.favorite, 'Wishlist'),
                    _navItem(3, Icons.shopping_bag_outlined, Icons.shopping_bag, 'Cart'),
                    _navItem(4, Icons.person_outline, Icons.person, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Rebuild the current screen from scratch on every tab switch.
  Widget _screenFor(int idx) {
    switch (idx) {
      case 0:
        return const HomeScreen();
      case 1:
        return const BrowseScreen();
      case 2:
        return const WishlistScreen();
      case 3:
        return const CartScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _navItem(int idx, IconData icon, IconData activeIcon, String label) {
    final active = AppState.selectedTab.value == idx;
    return GestureDetector(
      onTap: () => AppState.selectedTab.value = idx,
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