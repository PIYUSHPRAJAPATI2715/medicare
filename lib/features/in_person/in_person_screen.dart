import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/animation/animation_utils.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/hospital_card.dart';

class InPersonScreen extends ConsumerWidget {
  const InPersonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final asyncDoctors = ref.watch(allDoctorsProvider);
    final allDocs = asyncDoctors.value ?? MockData.doctors;
    final recommendedDoctors = allDocs.where((d) => d.allowsPhysical).toList();
    final asyncHospitals = ref.watch(allHospitalsProvider);
    final hospitals = asyncHospitals.value ?? MockData.hospitals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBack: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'In-Person Consultation',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  authState.currentCity,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search doctors or location
            StaggeredFadeSlide(
              index: 0,
              child: AppBouncyTouch(
                scaleFactor: 0.98,
                onTap: () {
                  ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
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
                          'Search doctors or clinic location...',
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

            const SizedBox(height: 18),

            // Two Quick Cards: "Nearby Doctors (Map view)" & "Top Hospitals (Explore)"
            StaggeredFadeSlide(
              index: 1,
              child: Row(
                children: [
                  Expanded(
                    child: AppBouncyTouch(
                      scaleFactor: 0.95,
                      onTap: () {
                        ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
                        Navigator.of(context).pushNamed(AppRoutes.doctorList);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.near_me_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nearby Doctors',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'View on map',
                              style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppBouncyTouch(
                      scaleFactor: 0.95,
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0F2FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF0284C7), size: 20),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Top Hospitals',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Explore facilities',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF0284C7), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommended for You Header
            StaggeredFadeSlide(
              index: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  AppBouncyTouch(
                    onTap: () {
                      ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
                      Navigator.of(context).pushNamed(AppRoutes.doctorList);
                    },
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            ...recommendedDoctors.take(3).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final doc = entry.value;
              return StaggeredFadeSlide(
                index: 3 + idx,
                child: DoctorCard(
                  doctor: doc,
                  isPhysicalMode: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.doctorDetail, arguments: doc.id);
                  },
                  onConsultNow: () {
                    ref.read(appointmentProvider.notifier).startBooking(
                          doc,
                          type: ConsultationType.inPerson,
                        );
                    Navigator.of(context).pushNamed(AppRoutes.booking);
                  },
                  onCallClinic: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${doc.clinicName}...')),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Top Hospitals Section
            StaggeredFadeSlide(
              index: 6,
              child: Text(
                'Top Verified Hospitals in ${authState.currentCity}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...hospitals.asMap().entries.map((entry) {
              final idx = entry.key;
              final hosp = entry.value;
              return StaggeredFadeSlide(
                index: 7 + idx,
                child: HospitalCard(
                  hospital: hosp,
                  onTap: () {},
                  onCall: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${hosp.name}: ${hosp.phone}')),
                    );
                  },
                  onBook: () {
                    ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
                    Navigator.of(context).pushNamed(AppRoutes.doctorList);
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
