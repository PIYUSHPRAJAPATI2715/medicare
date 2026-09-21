import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../widgets/custom_app_bar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'MediCare+ Admin Console',
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).switchRole(UserRole.patient);
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.mainShell, (r) => false);
            },
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Exit Admin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Header
            const Text(
              'System Overview & Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Metrics 2x2 Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _kpiCard(
                  title: 'Total Doctors',
                  value: '1,248',
                  growth: '+14% this month',
                  icon: Icons.medical_services_rounded,
                  color: AppColors.primary,
                ),
                _kpiCard(
                  title: 'Registered Patients',
                  value: '48,200',
                  growth: '+22% this month',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF0284C7),
                ),
                _kpiCard(
                  title: 'Total Consultations',
                  value: '15,420',
                  growth: '+18% growth',
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.success,
                ),
                _kpiCard(
                  title: 'Total Revenue',
                  value: '₹18.4 Lakh',
                  growth: 'FY 2026-27',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Management Modules
            const Text(
              'Platform Management',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _adminModuleTile(
                    icon: Icons.verified_user_rounded,
                    title: 'Doctor Verification & KYC',
                    subtitle: '12 new doctor applications pending approval',
                    badge: '12 Pending',
                    badgeColor: AppColors.warning,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Doctor Verification Queue: 12 doctors waiting review.')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.category_rounded,
                    title: 'Specialty Catalog Manager',
                    subtitle: 'Manage medical disciplines, symptoms & categories',
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.specialties);
                    },
                  ),
                  const Divider(height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Appointment Analytics & Audits',
                    subtitle: 'View live teleconsultations, completions & cancellations',
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.appointmentsHistory);
                    },
                  ),
                  const Divider(height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.local_hospital_rounded,
                    title: 'Hospital & Clinic Partners',
                    subtitle: 'Manage partnered medical centers in Jaipur',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Partnered Hospitals: Manipal, Fortis, SDMH Active')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.rate_review_rounded,
                    title: 'Patient Reviews & Quality Moderation',
                    subtitle: 'Approve or flag patient feedback & stories',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All patient reviews are currently moderated and verified.')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Registered Doctors List Preview
            const Text(
              'Recent Doctor Onboarding',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            ...MockData.doctors.take(3).map((doc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(doc.imageUrl),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          Text('${doc.specialty} • ${doc.clinicName}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Verified', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String growth,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(growth, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adminModuleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor ?? AppColors.primary),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textTertiary),
    );
  }
}
