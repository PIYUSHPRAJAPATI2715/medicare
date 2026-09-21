import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../models/appointment_model.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(doctorFilterProvider);
    _searchController = TextEditingController(text: filter.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final filter = ref.watch(doctorFilterProvider);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Doctors',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(doctorFilterProvider.notifier).resetFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Online Now (Instant Consult)'),
                    value: filter.onlineOnly,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (_) => ref.read(doctorFilterProvider.notifier).toggleOnlineOnly(),
                  ),
                  SwitchListTile(
                    title: const Text('High Patient Rating (90%+)'),
                    value: filter.highRatingOnly,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (_) => ref.read(doctorFilterProvider.notifier).toggleHighRating(),
                  ),
                  SwitchListTile(
                    title: const Text('Experienced (10+ Years)'),
                    value: filter.experience10Plus,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (_) => ref.read(doctorFilterProvider.notifier).toggleExperience10Plus(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Consultation Language', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.consultationLanguages.map((l) {
                      final isSel = filter.selectedLanguage == l;
                      return ChoiceChip(
                        label: Text(l),
                        selected: isSel,
                        onSelected: (_) => ref.read(doctorFilterProvider.notifier).setLanguage(l),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(doctorFilterProvider);
    final instantDocs = ref.watch(instantDoctorsProvider);
    final laterDocs = ref.watch(laterDoctorsProvider);
    final allFiltered = ref.watch(filteredDoctorsProvider);
    final isPhysical = filter.consultationMode == 'inPerson';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: filter.selectedSpecialty != null && filter.selectedSpecialty!.isNotEmpty
            ? '${filter.selectedSpecialty} in Jaipur'
            : 'Find Doctors in Jaipur',
      ),
      body: Column(
        children: [
          // Search + Toggle + Filters Bar Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(doctorFilterProvider.notifier).setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by doctor or specialty...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(doctorFilterProvider.notifier).setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Toggle: [ Physical Appointment ] [ Video Consult ]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(doctorFilterProvider.notifier).setConsultationMode('inPerson');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isPhysical ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: isPhysical
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apartment_rounded,
                                    size: 16,
                                    color: isPhysical ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Physical Appointment',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isPhysical ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref.read(doctorFilterProvider.notifier).setConsultationMode('video');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !isPhysical ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: !isPhysical
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_rounded,
                                    size: 16,
                                    color: !isPhysical ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Video Consult',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: !isPhysical ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Horizontal Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter icon button
                      ActionChip(
                        avatar: const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                        label: const Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        onPressed: _showFilterBottomSheet,
                      ),
                      const SizedBox(width: 8),
                      // Instant Online Chip
                      FilterChip(
                        label: const Text('Now or Later', style: TextStyle(fontSize: 12)),
                        selected: filter.onlineOnly,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        onSelected: (_) => ref.read(doctorFilterProvider.notifier).toggleOnlineOnly(),
                      ),
                      const SizedBox(width: 8),
                      // High Rating
                      FilterChip(
                        label: const Text('Rating 90%+', style: TextStyle(fontSize: 12)),
                        selected: filter.highRatingOnly,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        onSelected: (_) => ref.read(doctorFilterProvider.notifier).toggleHighRating(),
                      ),
                      const SizedBox(width: 8),
                      // Experience
                      FilterChip(
                        label: const Text('Experience 10+ Yrs', style: TextStyle(fontSize: 12)),
                        selected: filter.experience10Plus,
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                        onSelected: (_) => ref.read(doctorFilterProvider.notifier).toggleExperience10Plus(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Doctor List View
          Expanded(
            child: allFiltered.isEmpty
                ? EmptyStateView(
                    icon: Icons.person_search_rounded,
                    title: 'No Doctors Found',
                    message: 'We could not find any doctors matching your selected filters. Please adjust or reset filters.',
                    actionText: 'Reset Filters',
                    onAction: () {
                      ref.read(doctorFilterProvider.notifier).resetFilters();
                      _searchController.clear();
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    children: [
                      // Section 1: Doctors Available Instantly (if any)
                      if (instantDocs.isNotEmpty && !isPhysical) ...[
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            const Text(
                              'Doctors Available Instantly',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Online from all over India',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...instantDocs.map((doc) => DoctorCard(
                              doctor: doc,
                              isPhysicalMode: isPhysical,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.doctorDetail,
                                  arguments: doc.id,
                                );
                              },
                              onConsultNow: () {
                                ref.read(appointmentProvider.notifier).startBooking(
                                      doc,
                                      type: ConsultationType.video,
                                    );
                                Navigator.of(context).pushNamed(AppRoutes.booking);
                              },
                            )),
                        const SizedBox(height: 16),
                      ],

                      // Section 2: Doctors Available Later
                      if (laterDocs.isNotEmpty || isPhysical) ...[
                        if (!isPhysical && instantDocs.isNotEmpty) ...[
                          const Text(
                            'Doctors Available Later',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ...(isPhysical ? allFiltered : laterDocs).map((doc) => DoctorCard(
                              doctor: doc,
                              isPhysicalMode: isPhysical,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.doctorDetail,
                                  arguments: doc.id,
                                );
                              },
                              onConsultNow: () {
                                ref.read(appointmentProvider.notifier).startBooking(
                                      doc,
                                      type: isPhysical
                                          ? ConsultationType.inPerson
                                          : ConsultationType.video,
                                    );
                                Navigator.of(context).pushNamed(AppRoutes.booking);
                              },
                              onCallClinic: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling ${doc.clinicName}...')),
                                );
                              },
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
