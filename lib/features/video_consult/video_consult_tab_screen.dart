import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/appointment_model.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/doctor_card.dart';

class VideoConsultTabScreen extends ConsumerWidget {
  const VideoConsultTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instantDoctors = ref.watch(instantDoctorsProvider);

    final symptoms = [
      {'label': 'Fever', 'icon': Icons.thermostat_rounded},
      {'label': 'Cold & Cough', 'icon': Icons.coronavirus_outlined},
      {'label': 'Skin Rash', 'icon': Icons.face_retouching_natural_rounded},
      {'label': 'Stress', 'icon': Icons.psychology_rounded},
      {'label': 'Headache', 'icon': Icons.sick_rounded},
      {'label': 'Stomach Pain', 'icon': Icons.healing_rounded},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Consult a Doctor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner: "Consult qualified doctors from anywhere"
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF1A56DB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TELEHEALTH 24/7',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Consult qualified\ndoctors from anywhere',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Audio, video & chat with certified specialists in 60s.',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.videocam_rounded, size: 36, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Search symptoms or specialty
            GestureDetector(
              onTap: () {
                ref.read(doctorFilterProvider.notifier).setConsultationMode('video');
                Navigator.of(context).pushNamed(AppRoutes.doctorList);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search symptoms or specialty...',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Common symptoms quick chips
            const Text(
              'Common Health Concerns',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: symptoms.map((sym) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(sym['icon'] as IconData, size: 16, color: AppColors.primary),
                      label: Text(sym['label'] as String, style: const TextStyle(fontSize: 12.5)),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      onPressed: () {
                        ref.read(doctorFilterProvider.notifier).setSearchQuery(sym['label'] as String);
                        Navigator.of(context).pushNamed(AppRoutes.doctorList);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Doctors Available Instantly
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Doctors Available Instantly',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Text(
                  '${instantDoctors.length} Online',
                  style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...instantDoctors.map((doc) => DoctorCard(
                  doctor: doc,
                  isPhysicalMode: false,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.doctorDetail, arguments: doc.id);
                  },
                  onConsultNow: () {
                    ref.read(appointmentProvider.notifier).startBooking(
                          doc,
                          type: ConsultationType.video,
                        );
                    Navigator.of(context).pushNamed(AppRoutes.booking);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
