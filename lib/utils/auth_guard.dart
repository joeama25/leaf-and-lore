import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class AuthGuard {
  /// Returns true if the user is logged in.
  /// If not, opens the Login screen and waits for the result.
  /// Returns true if they logged in, false if they backed out.
  static Future<bool> requireLogin(BuildContext context) async {
    final loggedIn = await AuthService().isLoggedIn();
    if (loggedIn) return true;

    if (!context.mounted) return false;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    return result == true;
  }
}