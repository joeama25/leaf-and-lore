import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';

class AddAddressScreen extends StatefulWidget {
  final int userId;
  const AddAddressScreen({super.key, required this.userId});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Nigeria');
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AddressService.instance.add(AddressModel(
        userId: widget.userId,
        label: _labelCtrl.text.trim().isEmpty
            ? null
            : _labelCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        zip: _zipCtrl.text.trim().isEmpty ? null : _zipCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add address', style: AppTextStyles.heading),
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
                  label: 'Label (e.g. Home, Work)',
                  controller: _labelCtrl,
                ),
                CustomTextField(
                  label: 'Street address',
                  controller: _streetCtrl,
                  validator: (v) => Validators.required(v, 'Street'),
                ),
                CustomTextField(
                  label: 'City',
                  controller: _cityCtrl,
                  validator: (v) => Validators.required(v, 'City'),
                ),
                CustomTextField(
                  label: 'State',
                  controller: _stateCtrl,
                  validator: (v) => Validators.required(v, 'State'),
                ),
                CustomTextField(
                  label: 'ZIP / Postal code',
                  controller: _zipCtrl,
                ),
                CustomTextField(
                  label: 'Country',
                  controller: _countryCtrl,
                  validator: (v) => Validators.required(v, 'Country'),
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
                      : const Text('Save address'),
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