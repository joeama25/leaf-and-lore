import 'package:flutter/material.dart';
import '../../utils/app_text_styles.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Wishlist — coming soon', style: AppTextStyles.body)),
    );
  }
}