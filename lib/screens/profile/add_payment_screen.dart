import 'package:flutter/material.dart';
import '../../models/payment_method_model.dart';
import '../../services/payment_method_services.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';

class AddPaymentScreen extends StatefulWidget {
  final int userId;
  const AddPaymentScreen({super.key, required this.userId});
  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await PaymentMethodService.instance.add(PaymentMethodModel(
        userId: widget.userId,
        cardHolder: _holderCtrl.text.trim(),
        cardNumber: _numberCtrl.text.trim(),
        expiry: _expiryCtrl.text.trim(),
        brand: _detectBrand(_numberCtrl.text.trim()),
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5') || number.startsWith('2')) return 'Mastercard';
    if (number.startsWith('3')) return 'Amex';
    if (number.startsWith('6')) return 'Discover';
    return 'Card';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add payment', style: AppTextStyles.heading),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  label: 'Cardholder name',
                  controller: _holderCtrl,
                  validator: (v) =>
                      Validators.required(v, 'Cardholder name'),
                ),
                CustomTextField(
                  label: 'Card number',
                  controller: _numberCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    if (val.length < 12) return 'Enter a valid card number';
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Expiry (MM/YY)',
                  controller: _expiryCtrl,
                  keyboardType: TextInputType.datetime,
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    final regex = RegExp(r'^\d{2}/\d{2}$');
                    if (!regex.hasMatch(val)) return 'Use MM/YY format';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save card'),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}