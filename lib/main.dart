import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';

void main() => runApp(const LeafAndLoreApp());

class LeafAndLoreApp extends StatelessWidget {
  const LeafAndLoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'leaf & lore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}