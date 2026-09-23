import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/animation/animation_utils.dart';
import '../../models/appointment_model.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/rating_badge.dart';
import '../../widgets/time_slot_chip.dart';
import '../subscription/subscription_paywall_dialog.dart';

class DoctorDetailScreen extends ConsumerStatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({
    super.key,
    required this.doctorId,
  });

  @override
  ConsumerState<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  ConsultationType _selectedType = ConsultationType.video;
  int _selectedDateIndex = 1; // Tomorrow
  String _selectedSlot = '10:30 AM';

  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _availableDates = [
      now,
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
      now.add(const Duration(days: 3)),
      now.add(const Duration(days: 4)),
    ];
  }

  void _proceedToBooking() {
    final doctor = ref.read(doctorByIdProvider(widget.doctorId)) ?? MockData.doctors[0];
    final selectedDate = _availableDates[_selectedDateIndex];

    if (_selectedType == ConsultationType.online || _selectedType == ConsultationType.video) {
      SubscriptionPaywallDialog.checkAndProceed(
        context,
        ref,
        doctorName: doctor.name,
        onProceed: () {
          final aptNotifier = ref.read(appointmentProvider.notifier);
          aptNotifier.startBooking(doctor, type: _selectedType);
          aptNotifier.updateDraftDate(selectedDate);
          aptNotifier.updateDraftSlot(_selectedSlot);
          Navigator.of(context).pushNamed(AppRoutes.booking);
        },
      );
      return;
    }

    final aptNotifier = ref.read(appointmentProvider.notifier);
    aptNotifier.startBooking(doctor, type: _selectedType);
    aptNotifier.updateDraftDate(selectedDate);
    aptNotifier.updateDraftSlot(_selectedSlot);

    Navigator.of(context).pushNamed(AppRoutes.booking);
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorByIdProvider(widget.doctorId)) ?? MockData.doctors[0];
    final filterState = ref.watch(doctorFilterProvider);
    final isFavorite = filterState.favoriteDoctorIds.contains(doctor.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Doctor Profile',
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : AppColors.textSecondary,
            ),
            onPressed: () {
              ref.read(doctorFilterProvider.notifier).toggleFavorite(doctor.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Doctor profile link copied: ${doctor.name}')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_selectedType == ConsultationType.inPerson) ...[
                  Expanded(
                    child: AppBouncyTouch(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Connecting to ${doctor.clinicName}...')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_outlined, size: 16, color: AppColors.textPrimary),
                            SizedBox(width: 6),
                            Text('Call Clinic', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: AppBouncyTouch(
                    onTap: _proceedToBooking,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _selectedType == ConsultationType.inPerson ? 'Book Clinic Visit' : 'Book Video Consult',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Doctor Profile Header Card
            StaggeredFadeSlide(
              index: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'doctor-avatar-${doctor.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              doctor.imageUrl,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 88,
                                height: 88,
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: const TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                doctor.specialty,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor.qualification,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor.experienceText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RatingBadge(
                                ratingPercentage: doctor.ratingPercentage,
                                storiesCount: doctor.patientStoriesCount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Consultation Type Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppBouncyTouch(
                              onTap: () => setState(() => _selectedType = ConsultationType.inPerson),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _selectedType == ConsultationType.inPerson
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedType == ConsultationType.inPerson
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apartment_rounded,
                                      size: 16,
                                      color: _selectedType == ConsultationType.inPerson
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'In-Person Visit',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: _selectedType == ConsultationType.inPerson
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: AppBouncyTouch(
                              onTap: () => setState(() => _selectedType = ConsultationType.video),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _selectedType == ConsultationType.video
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedType == ConsultationType.video
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam_rounded,
                                      size: 16,
                                      color: _selectedType == ConsultationType.video
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Video Consult',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: _selectedType == ConsultationType.video
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Clinic / Fee info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.clinicName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor.clinicAddress,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            doctor.formattedFee,
                            style: const TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. Select Date & Slot Section
            StaggeredFadeSlide(
              index: 1,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date & Time Slot',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Horizontal Date Picker
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_availableDates.length, (index) {
                          final date = _availableDates[index];
                          final isSelected = _selectedDateIndex == index;
                          final isToday = index == 0;
                          final isTomorrow = index == 1;

                          String label = isToday
                              ? 'Today'
                              : isTomorrow
                                  ? 'Tomorrow'
                                  : DateFormat('dd MMM').format(date);
                          String slotCount = isToday ? 'No Slots' : '${12 + index} Slots';

                          return AppBouncyTouch(
                            scaleFactor: 0.94,
                            onTap: () => setState(() => _selectedDateIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLight : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slotCount,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isToday
                                          ? AppColors.textTertiary
                                          : (isSelected ? AppColors.primary : AppColors.success),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Morning Slots
                    const Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text('Morning Slots', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MockData.morningSlots.take(4).map((slot) {
                        return TimeSlotChip(
                          slot: slot,
                          isSelected: _selectedSlot == slot,
                          onTap: () => setState(() => _selectedSlot = slot),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Afternoon Slots
                    const Row(
                      children: [
                        Icon(Icons.wb_twilight_rounded, size: 16, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Text('Afternoon Slots', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MockData.afternoonSlots.take(3).map((slot) {
                        return TimeSlotChip(
                          slot: slot,
                          isSelected: _selectedSlot == slot,
                          onTap: () => setState(() => _selectedSlot = slot),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Select slot to request for an appointment. We might call to confirm.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. About & Credentials
            StaggeredFadeSlide(
              index: 2,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Doctor',
                      style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doctor.aboutText,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.55),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Services Offered',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.services.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 4. Patient Stories (Reviews)
            StaggeredFadeSlide(
              index: 3,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${doctor.patientStoriesCount} Patient Stories',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Verified Reviews',
                          style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...MockData.patientReviews.map((rev) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rev.patientName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                ),
                                Text(
                                  rev.timeAgo,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (i) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rev.comment,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
