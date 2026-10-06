import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                const SizedBox(height: 24),

                // Logo mark
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Wordmark "leaf & lore"
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.heading.copyWith(fontSize: 26),
                      children: const [
                        TextSpan(text: 'leaf '),
                        TextSpan(
                          text: '&',
                          style: TextStyle(color: AppColors.gold),
                        ),
                        TextSpan(text: ' lore'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Eyebrow
                const Text(
                  'WELCOME TO LEAF & LORE',
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: 10),

                // Display heading with italic accent
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.display,
                    children: const [
                      TextSpan(text: 'Welcome back,\n'),
                      TextSpan(
                        text: 'reader.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Your bookshelf is right where you left it.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 36),

                // Email field
                CustomTextField(
                  label: 'Email address',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                // Password field
                CustomTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  obscure: true,
                  validator: Validators.password,
                ),

                const SizedBox(height: 4),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 12),

                // Sign in button
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Sign In  →'),
                ),
                const SizedBox(height: 24),

                // Register link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMuted,
                        children: const [
                          TextSpan(text: 'New to leaf & lore?  '),
                          TextSpan(
                            text: 'Create an account',
                            style: TextStyle(
                              color: AppColors.forest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}