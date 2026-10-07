import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';
import 'screens/home/main_shell.dart';


void main() => runApp(const LeafAndLoreApp());

class LeafAndLoreApp extends StatelessWidget {
  const LeafAndLoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'leaf & lore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/home',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainShell(),
      },
    );
  }
}