import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  // Mock patients queue for the doctor
  final List<Map<String, dynamic>> _patientQueue = [
    {
      'id': 'p1',
      'name': 'Piyush Prajapati',
      'age': 30,
      'gender': 'Male',
      'time': '11:00 AM',
      'type': 'Video Consultation',
      'reason': 'Persistent Migraine & Headache',
      'status': 'Waiting in Lobby',
      'fee': '₹500',
    },
    {
      'id': 'p2',
      'name': 'Sunita Devi',
      'age': 48,
      'gender': 'Female',
      'time': '11:30 AM',
      'type': 'Hospital Clinic Visit',
      'reason': 'Hypertension & Regular Checkup',
      'status': 'Confirmed',
      'fee': '₹500',
    },
    {
      'id': 'p3',
      'name': 'Aman Singhania',
      'age': 24,
      'gender': 'Male',
      'time': '12:00 PM',
      'type': 'Video Consultation',
      'reason': 'Seasonal Viral Fever & Cough',
      'status': 'Confirmed',
      'fee': '₹500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isOnline = user.isDoctorAvailable;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  user.specialization ?? 'General Physician',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Switch to Patient button
          TextButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).switchRole(UserRole.patient);
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.mainShell, (r) => false);
            },
            icon: const Icon(Icons.person, size: 16),
            label: const Text('Patient Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Online / Offline Toggle Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.successLight : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOnline ? AppColors.success.withValues(alpha: 0.3) : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.success : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Online & Accepting Patients' : 'Offline / On Break',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: isOnline ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            isOnline
                                ? 'Patients can request instant teleconsultation'
                                : 'Toggle on to receive instant calls',
                            style: TextStyle(
                              fontSize: 11,
                              color: isOnline ? AppColors.success.withValues(alpha: 0.8) : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: isOnline,
                    activeThumbColor: AppColors.success,
                    onChanged: (_) {
                      ref.read(authProvider.notifier).toggleDoctorAvailability();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    title: "Today's Consults",
                    value: '8',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricCard(
                    title: "Today's Earnings",
                    value: '₹4,200',
                    icon: Icons.currency_rupee_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricCard(
                    title: 'Doctor Rating',
                    value: '4.9 ★',
                    icon: Icons.star_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Quick Actions
            const Text(
              'Doctor Quick Tools',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _quickToolTile(
                  icon: Icons.videocam_rounded,
                  label: 'Instant Call',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.videoCall),
                ),
                const SizedBox(width: 10),
                _quickToolTile(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Patient Chats',
                  color: const Color(0xFF0284C7),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.chat),
                ),
                const SizedBox(width: 10),
                _quickToolTile(
                  icon: Icons.calendar_month_rounded,
                  label: 'Schedule',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Doctor Schedule & Slots configured.')),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _quickToolTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Fee Settings',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Current consultation fee: ₹500/session')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Today's Patient Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Patient Queue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_patientQueue.length} Patients Waiting',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._patientQueue.map((patient) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                (patient['name'] as String)[0],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                                ),
                                Text(
                                  '${patient['age']} Yrs • ${patient['gender']}',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: patient['status'] == 'Waiting in Lobby'
                                ? AppColors.warningLight
                                : AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            patient['status'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: patient['status'] == 'Waiting in Lobby'
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medical_information_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reason: ${patient['reason']}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              patient['time'] as String,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              patient['fee'] as String,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.chat);
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                              tooltip: 'Chat with Patient',
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.videoCall);
                              },
                              icon: const Icon(Icons.videocam_rounded, size: 16),
                              label: const Text('Start Call', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _quickToolTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
