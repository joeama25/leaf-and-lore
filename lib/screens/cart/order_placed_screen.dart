import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_state.dart';
import '../../utils/app_text_styles.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderNumber;
  final double total;

  const OrderPlacedScreen({
    super.key,
    required this.orderNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.sage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: AppColors.forest, size: 48),
              ),
              const SizedBox(height: 32),
              const Text('A NEW CHAPTER BEGINS',
                  style: AppTextStyles.eyebrow),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.display,
                  children: const [
                    TextSpan(text: 'Order placed\n'),
                    TextSpan(
                      text: 'successfully.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.forest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for shopping with us. '
                    'Your next great read is on its way.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.border),
              const SizedBox(height: 20),
              _row('Order number', orderNumber),
              const SizedBox(height: 10),
              _row('Order date', _today()),
              const SizedBox(height: 10),
              _row('Total paid', '\$${total.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              _row('Estimated delivery', '5–7 business days'),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppState.selectedTab.value = 4; // Profile tab
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  child: const Text('Track your order  →'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    AppState.selectedTab.value = 4;
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.forest),
                    foregroundColor: AppColors.forest,
                  ),
                  child: const Text('View order details'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  AppState.selectedTab.value = 0; // Home tab
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                child: const Text('Continue shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.small),
        const Spacer(),
        Text(value, style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
        )),
      ],
    );
  }

  String _today() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}