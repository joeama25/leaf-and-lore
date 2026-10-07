import 'package:flutter/material.dart';
import '../../models/payment_method_model.dart';
import '../../services/auth_service.dart';
import '../../services/payment_method_services.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'add_payment_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int? _userId;
  List<PaymentMethodModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await AuthService().currentUserId();
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final items = await PaymentMethodService.instance.getForUser(id);
      if (!mounted) return;
      setState(() {
        _userId = id;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _addNew() async {
    if (_userId == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPaymentScreen(userId: _userId!),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(PaymentMethodModel p) async {
    await PaymentMethodService.instance.remove(p.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment methods', style: AppTextStyles.heading),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your saved ways to pay',
                style: AppTextStyles.bodyMuted),
            const SizedBox(height: 20),
            if (_items.isEmpty)
              _emptyState()
            else
              for (final p in _items) _card(p),
            const SizedBox(height: 12),
            _addButton(),
            const SizedBox(height: 20),
            _securityNote(),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              color: AppColors.sage, shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card_outlined,
                color: AppColors.forest, size: 32),
          ),
          const SizedBox(height: 20),
          const Text('No payment methods',
              style: AppTextStyles.heading, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Add a card to speed up checkout.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: _addNew,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.forest),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.forest, size: 18),
            SizedBox(width: 8),
            Text(
              'Add payment method',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(PaymentMethodModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card,
                  size: 18, color: AppColors.forest),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.masked,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Expires ${p.expiry}', style: AppTextStyles.small),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Text('Edit',
                    style: AppTextStyles.small
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _delete(p),
                child: Text('Remove',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _securityNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined,
            size: 16, color: AppColors.inkMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Only the last four digits are shown. '
                'Never share your full card information.',
            style: AppTextStyles.small,
          ),
        ),
      ],
    );
  }
}