import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
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
                const SizedBox(height: 12),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 8),

                // Logo mark
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book,
                        color: AppColors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 20),

                // Wordmark
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
                const SizedBox(height: 32),

                // Eyebrow
                const Text(
                  'WELCOME TO LEAF & LORE',
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: 10),

                // Display heading
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.display,
                    children: const [
                      TextSpan(text: 'Your next chapter\n'),
                      TextSpan(
                        text: 'starts here.',
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
                  'Create an account to save favorites and find your next great read.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 32),

                // Fields
                CustomTextField(
                  label: 'Full name',
                  controller: _nameCtrl,
                  icon: Icons.person,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                CustomTextField(
                  label: 'Email address',
                  controller: _emailCtrl,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                CustomTextField(
                  label: 'Phone (optional)',
                  controller: _phoneCtrl,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  icon: Icons.lock,
                  obscure: true,
                  validator: Validators.password,
                ),

                const SizedBox(height: 20),

                // Create button
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2,
                    ),
                  )
                      : const Text('Create account  →'),
                ),
                const SizedBox(height: 20),

                // Link to Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMuted,
                        children: const [
                          TextSpan(text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Sign in',
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