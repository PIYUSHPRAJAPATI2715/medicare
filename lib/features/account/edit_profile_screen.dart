import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String _selectedGender = 'Male';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _dobController = TextEditingController(text: user.dob ?? '15 Aug 1994');
    _selectedGender = user.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _selectedGender,
          dob: _dobController.text.trim(),
        );

    setState(() => _isSaving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            AppTextField(
              controller: _nameController,
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _dobController,
              labelText: 'Date of Birth',
              prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['Male', 'Female', 'Other'].map((g) {
                    final isSel = _selectedGender == g;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(g),
                        selected: isSel,
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _selectedGender = g),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 36),

            AppButton(
              text: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _saveProfile,
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
