import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showRoleSwitchDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Application Role',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explore the complete role-based experience built in MediCare+.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                title: const Text('Patient Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Book doctor visits, video consults & history'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  ref.read(authProvider.notifier).switchRole(UserRole.patient);
                  Navigator.pop(context);
                },
              ),
              const Divider(color: AppColors.borderLight),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                  child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0284C7)),
                ),
                title: const Text('Doctor Mode (Provider Portal)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Manage patient appointments, earnings & video calls'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  ref.read(authProvider.notifier).switchRole(UserRole.doctor);
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(AppRoutes.doctorDashboard);
                },
              ),
              const Divider(color: AppColors.borderLight),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD97706)),
                ),
                title: const Text('Admin Panel UI', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('System analytics, doctor verification & metrics'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  ref.read(authProvider.notifier).switchRole(UserRole.admin);
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(AppRoutes.adminDashboard);
                },
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Account',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account_rounded, color: AppColors.primary),
            tooltip: 'Switch Role',
            onPressed: () => _showRoleSwitchDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      user.avatarUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                        radius: 29,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.editProfile);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      'EDIT',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Care Plan Banner
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.carePlan);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
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
                              fontSize: 14.5,
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

            const SizedBox(height: 24),

            // 3. My History Section
            const Text(
              'My History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
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

            const SizedBox(height: 24),

            // 4. Role Switch Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch to Doctor or Admin',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.primaryDark),
                        ),
                        Text(
                          'Test doctor consultation portal and admin analytics',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showRoleSwitchDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Switch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Settings Section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
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

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    return ListTile(
      onTap: onTap,
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
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textTertiary),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 56, color: AppColors.borderLight);
  }
}
