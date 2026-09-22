import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/medicare_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneOrEmailController = TextEditingController(text: '+91 98765 43210');
  final _passwordController = TextEditingController(text: 'medicare123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.patient;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_selectedRole == UserRole.patient) {
      ref.read(authProvider.notifier).loginAsPatient();
      Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
    } else {
      ref.read(authProvider.notifier).loginAsDoctor();
      Navigator.of(context).pushReplacementNamed(AppRoutes.doctorDashboard);
    }
  }

  void _quickLoginAsPatient() {
    ref.read(authProvider.notifier).loginAsPatient();
    Navigator.of(context).pushReplacementNamed(AppRoutes.mainShell);
  }

  void _quickLoginAsDoctor() {
    ref.read(authProvider.notifier).loginAsDoctor();
    Navigator.of(context).pushReplacementNamed(AppRoutes.doctorDashboard);
  }

  void _quickAdminPreview() {
    ref.read(authProvider.notifier).switchRole(UserRole.admin);
    Navigator.of(context).pushNamed(AppRoutes.adminDashboard);
  }

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Center(child: MedicareLogo(size: 42, showTagline: true)),
              const SizedBox(height: 32),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Good to see you again! Please sign in to continue.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Role Selector Tabs (Patient vs Doctor)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = UserRole.patient),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.patient ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedRole == UserRole.patient
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: _selectedRole == UserRole.patient
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Patient',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: _selectedRole == UserRole.patient
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = UserRole.doctor),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.doctor ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedRole == UserRole.doctor
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 18,
                                  color: _selectedRole == UserRole.doctor
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Doctor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: _selectedRole == UserRole.doctor
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Inputs
              AppTextField(
                controller: _phoneOrEmailController,
                labelText: _selectedRole == UserRole.patient
                    ? 'Mobile Number / Email'
                    : 'Registered Doctor Email / Mobile',
                hintText: 'Enter your phone or email',
                prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textTertiary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link sent to registered email.')),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Login Button
              AppButton(
                text: _selectedRole == UserRole.patient ? 'Login as Patient' : 'Login as Doctor',
                isLoading: _isLoading,
                onPressed: _handleLogin,
                width: double.infinity,
                height: 52,
              ),

              const SizedBox(height: 24),

              // Social divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 18),

              // Social Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    icon: Icons.g_mobiledata_rounded,
                    iconColor: Colors.red,
                    label: 'Google',
                    onTap: _quickLoginAsPatient,
                  ),
                  const SizedBox(width: 14),
                  _socialButton(
                    icon: Icons.apple_rounded,
                    iconColor: Colors.black,
                    label: 'Apple',
                    onTap: _quickLoginAsPatient,
                  ),
                  const SizedBox(width: 14),
                  _socialButton(
                    icon: Icons.facebook_rounded,
                    iconColor: const Color(0xFF1877F2),
                    label: 'Facebook',
                    onTap: _quickLoginAsPatient,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign up link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.signup,
                          arguments: _selectedRole,
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 12),

              // Fast Switch Demo Helpers

            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: 28),
        ),
      ),
    );
  }
}
