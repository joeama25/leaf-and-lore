import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'add_address_screen.dart';
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  int? _userId;
  List<AddressModel> _items = [];
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
      final items = await AddressService.instance.getForUser(id);
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
        builder: (_) => AddAddressScreen(userId: _userId!),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(AddressModel a) async {
    await AddressService.instance.remove(a.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My addresses', style: AppTextStyles.heading),
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
            Text(
              'Where your books find you',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 20),
            if (_items.isEmpty) _emptyState(),
            for (final a in _items) _addressTile(a),
            const SizedBox(height: 12),
            _addButton(),
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
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.sage,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.forest, size: 32),
          ),
          const SizedBox(height: 20),
          const Text('No addresses yet',
              style: AppTextStyles.heading, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Add your first address to get books delivered.',
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
              'Add new address',
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

  Widget _addressTile(AddressModel a) {
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
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.forest),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a.label ?? 'Address',
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (a.label != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.sage,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.forest,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(a.oneLine, style: AppTextStyles.bodyMuted),
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
                onTap: () => _delete(a),
                child: Text('Delete',
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
}