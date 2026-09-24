import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../models/doctor_model.dart';
import '../../providers/auth_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../widgets/custom_app_bar.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  late List<DoctorModel> _doctors;

  @override
  void initState() {
    super.initState();
    _doctors = List.from(MockData.doctors);
  }

  void _confirmDeleteDoctor(DoctorModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Doctor Profile?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete ${doc.name}?\n\nThis will remove their credentials, schedule, and patient booking access from MediCare+.',
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _doctors.removeWhere((d) => d.id == doc.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${doc.name} was deleted successfully.'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
            child: const Text('Delete Doctor',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'MediCare+ Admin Console',
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).switchRole(UserRole.patient);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.mainShell, (r) => false);
            },
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Exit Admin',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
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
                  value: '${_doctors.length + 1240}',
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
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
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
                        const SnackBar(
                            content: Text(
                                'Doctor Verification Queue: 12 doctors waiting review.')),
                      );
                    },
                  ),
                  const Divider(
                      height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.category_rounded,
                    title: 'Specialty Catalog Manager',
                    subtitle:
                        'Manage medical disciplines, symptoms & categories',
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.specialties);
                    },
                  ),
                  const Divider(
                      height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Appointment Analytics & Audits',
                    subtitle:
                        'View live teleconsultations, completions & cancellations',
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.appointmentsHistory);
                    },
                  ),
                  const Divider(
                      height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.local_hospital_rounded,
                    title: 'Hospital & Clinic Partners',
                    subtitle: 'Manage partnered medical centers in Jaipur',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Partnered Hospitals: Manipal, Fortis, SDMH Active')),
                      );
                    },
                  ),
                  const Divider(
                      height: 1, indent: 54, color: AppColors.borderLight),
                  _adminModuleTile(
                    icon: Icons.rate_review_rounded,
                    title: 'Patient Reviews & Quality Moderation',
                    subtitle: 'Approve or flag patient feedback & stories',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'All patient reviews are currently moderated and verified.')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Registered Doctors Directory with Delete Option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Doctor Directory & Access Control',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                Text(
                  '${_doctors.length} Doctors',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_doctors.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('No doctors remaining in directory.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ..._doctors.map((doc) {
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
                            Text(doc.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5)),
                            Text(
                              '${doc.specialty} • ${doc.clinicName}',
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Verified',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626), size: 21),
                        tooltip: 'Delete Doctor',
                        onPressed: () => _confirmDeleteDoctor(doc),
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(growth,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: color,
                      fontWeight: FontWeight.w600)),
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: badgeColor ?? AppColors.primary,
                ),
              ),
            ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }
}
