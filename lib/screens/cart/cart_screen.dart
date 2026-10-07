import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/auth_guard.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _checking = true;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final id = await AuthService().currentUserId();
    if (!mounted) return;
    setState(() {
      _signedIn = id != null;
      _checking = false;
    });
  }

  Future<void> _signIn() async {
    final ok = await AuthGuard.requireLogin(context);
    if (ok) _check();   // login succeeded → re-check
    // if false (user tapped back) → do nothing, cart stays in guest view
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_signedIn) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.sage,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        color: AppColors.forest, size: 32),
                  ),
                  const SizedBox(height: 24),
                  const Text('Your cart is waiting',
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to save books and pick up where you left off.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign in  →'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: Text('Cart — coming soon', style: AppTextStyles.body),
      ),
    );
  }
}