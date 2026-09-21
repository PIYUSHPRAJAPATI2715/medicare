import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/animation/animation_utils.dart';
import '../../models/appointment_model.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/custom_app_bar.dart';
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
      appBar: const CustomAppBar(
        showBack: false,
        title: 'Video Consultation',
        subtitle: 'Connect with doctors online in 60s',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner: "Consult qualified doctors from anywhere"
            StaggeredFadeSlide(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF1A56DB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 16,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PulsingDot(size: 5, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'TELEHEALTH 24/7',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Consult qualified\ndoctors from anywhere',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Audio, video & chat with certified specialists in 60s.',
                            style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.videocam_rounded, size: 36, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Search symptoms or specialty
            StaggeredFadeSlide(
              index: 1,
              child: AppBouncyTouch(
                scaleFactor: 0.98,
                onTap: () {
                  ref.read(doctorFilterProvider.notifier).setConsultationMode('video');
                  Navigator.of(context).pushNamed(AppRoutes.doctorList);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search symptoms or specialty...',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Common symptoms quick chips
            StaggeredFadeSlide(
              index: 2,
              child: const Text(
                'Common Health Concerns',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            StaggeredFadeSlide(
              index: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: symptoms.map((sym) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: AppBouncyTouch(
                        onTap: () {
                          ref.read(doctorFilterProvider.notifier).setSearchQuery(sym['label'] as String);
                          Navigator.of(context).pushNamed(AppRoutes.doctorList);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(sym['icon'] as IconData, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                sym['label'] as String,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // Doctors Available Instantly
            StaggeredFadeSlide(
              index: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      PulsingDot(size: 7, color: AppColors.success),
                      SizedBox(width: 8),
                      Text(
                        'Doctors Available Instantly',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${instantDoctors.length} Online',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            ...instantDoctors.asMap().entries.map((entry) {
              final idx = entry.key;
              final doc = entry.value;
              return StaggeredFadeSlide(
                index: 5 + idx,
                child: DoctorCard(
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
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
