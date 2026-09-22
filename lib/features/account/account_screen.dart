import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/animation/animation_utils.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showRoleSwitchDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Switch Application Role',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explore the complete role-based experience built in MediCare+.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18),
              AppBouncyTouch(
                onTap: () {
                  ref.read(authProvider.notifier).switchRole(UserRole.patient);
                  Navigator.pop(context);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Patient Mode', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Book doctor visits, video consults & history'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              ),
              const SizedBox(height: 10),
              AppBouncyTouch(
                onTap: () {
                  ref.read(authProvider.notifier).switchRole(UserRole.doctor);
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(AppRoutes.doctorDashboard);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                    child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0284C7)),
                  ),
                  title: const Text('Doctor Mode (Provider Portal)', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Manage patient appointments, earnings & video calls'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              ),
              const SizedBox(height: 10),
              AppBouncyTouch(
                onTap: () {
                  ref.read(authProvider.notifier).switchRole(UserRole.admin);
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(AppRoutes.adminDashboard);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD97706)),
                  ),
                  title: const Text('Admin Panel UI', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('System analytics, doctor verification & metrics'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBack: false,
        title: 'Account',
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account_rounded, color: AppColors.primary),
            tooltip: 'Switch Role',
            onPressed: () => _showRoleSwitchDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Card
            StaggeredFadeSlide(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        user.avatarUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person, size: 36, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.phone,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppBouncyTouch(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.editProfile);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'EDIT',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Care Plan Banner
            StaggeredFadeSlide(
              index: 1,
              child: AppBouncyTouch(
                scaleFactor: 0.97,
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.carePlan);
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.bannerGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Care Plan Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '12 FREE Appointments for a Year',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. My History Section
            StaggeredFadeSlide(
              index: 2,
              child: const Text(
                'My History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            StaggeredFadeSlide(
              index: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _accountNavTile(
                      icon: Icons.apartment_rounded,
                      title: 'In-Person Appointments',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.appointmentsHistory);
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.videocam_rounded,
                      title: 'Video Consultations',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.appointmentsHistory);
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.people_outline_rounded,
                      title: 'My Doctors',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.doctorList);
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.folder_shared_outlined,
                      title: 'Medical Records & Prescriptions',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.chat);
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.payment_rounded,
                      title: 'Payments & HealthCash',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('HealthCash Balance: ₹450 available')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Settings Section
            StaggeredFadeSlide(
              index: 5,
              child: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            StaggeredFadeSlide(
              index: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _accountNavTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'English (Default)',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Language set to English')),
                        );
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.notifications);
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.helpSupport);
                      },
                    ),
                    _divider(),
                    _accountNavTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About MediCare+',
                      subtitle: 'v1.0.0 (Production Build)',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'MediCare+',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 MediCare+ Technologies Pvt Ltd.\nYour Health, Our Priority.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            StaggeredFadeSlide(
              index: 7,
              child: AppBouncyTouch(
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return AppBouncyTouch(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary, fontWeight: FontWeight.w500))
            : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 56, color: AppColors.borderLight);
  }
}
