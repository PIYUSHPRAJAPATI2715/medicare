import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/hospital_card.dart';

class InPersonScreen extends ConsumerWidget {
  const InPersonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final recommendedDoctors = MockData.doctors.where((d) => d.allowsPhysical).toList();
    final hospitals = MockData.hospitals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'In-Person Consultation',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  authState.currentCity,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
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
            GestureDetector(
              onTap: () {
                ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
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
                        'Search doctors or clinic location...',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Two Quick Cards: "Nearby Doctors (Map view)" & "Top Hospitals (Explore)"
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.near_me_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Nearby Doctors',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'View on map',
                          style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF0284C7), size: 20),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Top Hospitals',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Explore facilities',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recommended for You
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended for You',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
                    Navigator.of(context).pushNamed(AppRoutes.doctorList);
                  },
                  child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            ...recommendedDoctors.take(3).map((doc) => DoctorCard(
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
                )),

            const SizedBox(height: 16),

            // Top Hospitals Section
            const Text(
              'Top Verified Hospitals in Jaipur',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            ...hospitals.map((hosp) => HospitalCard(
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
                )),
          ],
        ),
      ),
    );
  }
}
