import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';
import 'admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      if (user?.role != 'admin') {
        await _auth.logout();
        _snack('Access denied — staff only');
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } catch (e) {
      if (mounted) _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book,
                        color: AppColors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.heading.copyWith(fontSize: 26),
                      children: const [
                        TextSpan(text: 'leaf '),
                        TextSpan(text: '&',
                            style: TextStyle(color: AppColors.gold)),
                        TextSpan(text: ' lore'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('STAFF PORTAL', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.display,
                    children: const [
                      TextSpan(text: 'Welcome back,\n'),
                      TextSpan(
                        text: 'admin.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Sign in to manage the Leaf & Lore bookstore.',
                    style: AppTextStyles.bodyMuted),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Email address',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                CustomTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  obscure: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                      : const Text('Sign In  →'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined,
                        size: 14, color: AppColors.inkMuted),
                    SizedBox(width: 6),
                    Text('Restricted staff access only',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 12,
                          color: AppColors.inkMuted,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}