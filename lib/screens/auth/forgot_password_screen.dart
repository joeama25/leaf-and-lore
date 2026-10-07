import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    _showSuccessModal();
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.sage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book,
                    color: AppColors.forest, size: 28),
              ),
              const SizedBox(height: 20),
              const Text(
                'Check your inbox',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 10),
              Text(
                'Password reset instructions have been sent. '
                    'Check your email for the next steps.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // back to login
                  },
                  child: const Text('Back to sign in'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
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

                // Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 8),

                // Logo
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

                const Text(
                  'WELCOME TO LEAF & LORE',
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: 10),

                RichText(
                  text: TextSpan(
                    style: AppTextStyles.display,
                    children: const [
                      TextSpan(text: "Let's find your "),
                      TextSpan(
                        text: 'way\nback.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Enter your email and we\'ll send you password '
                      'reset instructions.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Email address',
                  controller: _emailCtrl,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _loading ? null : _sendReset,
                  child: _loading
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2,
                    ),
                  )
                      : const Text('Send reset link  →'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}