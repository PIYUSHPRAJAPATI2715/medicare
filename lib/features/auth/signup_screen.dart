import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_app_bar.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const SignupScreen({
    super.key,
    this.initialRole = UserRole.patient,
  });

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late UserRole _role;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Patient specific
  String _selectedGender = 'Male';
  final _dobController = TextEditingController(text: '15/08/1995');

  // Doctor specific
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _registrationController = TextEditingController();
  final _clinicController = TextEditingController();

  bool _agreedToTerms = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _registrationController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_role == UserRole.patient) {
      ref.read(authProvider.notifier).loginAsPatient();
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.mainShell, (route) => false);
    } else {
      ref.read(authProvider.notifier).loginAsDoctor();
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.doctorDashboard, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _role == UserRole.patient ? 'Patient Registration' : 'Doctor Registration',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _role == UserRole.patient ? 'Create Patient Account' : 'Join as a Healthcare Provider',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in the details below to complete your registration.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              if (_role == UserRole.doctor) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Complete 7-Step Doctor Registration',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Healthcare regulations require verified medical credentials, state council certificates, clinic details, and document upload.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text(
                            'Open 7-Step Registration Wizard',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(AppRoutes.doctorRegister);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              AppTextField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: _role == UserRole.patient ? 'Enter your full name' : 'Dr. Full Name',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _phoneController,
                labelText: 'Mobile Number',
                hintText: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Create a secure password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),

              if (_role == UserRole.patient) ...[
                // Gender Selection
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
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
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _selectedGender = g),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _dobController,
                  labelText: 'Date of Birth',
                  hintText: 'DD/MM/YYYY',
                  prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textTertiary),
                ),
              ] else ...[
                // Doctor Fields
                AppTextField(
                  controller: _specializationController,
                  labelText: 'Specialization',
                  hintText: 'e.g., General Physician, Dermatologist',
                  prefixIcon: const Icon(Icons.medical_information_outlined, size: 20, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _experienceController,
                  labelText: 'Years of Experience',
                  hintText: 'e.g., 10',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.history_edu_rounded, size: 20, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _registrationController,
                  labelText: 'Medical Council Registration Number',
                  hintText: 'e.g., MCI-84920',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _clinicController,
                  labelText: 'Hospital / Clinic Information',
                  hintText: 'e.g., Manipal Hospitals, Jaipur',
                  prefixIcon: const Icon(Icons.apartment_rounded, size: 20, color: AppColors.textTertiary),
                ),
              ],

              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the MediCare+ Terms of Service & Privacy Policy',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              AppButton(
                text: 'Create Account',
                isLoading: _isLoading,
                onPressed: _agreedToTerms ? _handleSignup : null,
                width: double.infinity,
                height: 52,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
