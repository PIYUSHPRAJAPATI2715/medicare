import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/empty_state_view.dart';

class AppointmentsHistoryScreen extends ConsumerStatefulWidget {
  const AppointmentsHistoryScreen({super.key});

  @override
  ConsumerState<AppointmentsHistoryScreen> createState() => _AppointmentsHistoryScreenState();
}

class _AppointmentsHistoryScreenState extends ConsumerState<AppointmentsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCancelDialog(AppointmentModel apt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Appointment?'),
        content: Text('Are you sure you want to cancel the appointment with ${apt.doctor.name}? Full refund will be credited to your HealthCash wallet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(appointmentProvider.notifier).cancelAppointment(apt.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);
    final upcomingList = appointmentState.upcomingAppointments;
    final pastList = appointmentState.pastAppointments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Appointments',
      ),
      body: Column(
        children: [
          // Tabs Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Appointments Tab
                upcomingList.isEmpty
                    ? EmptyStateView(
                        icon: Icons.event_busy_rounded,
                        title: 'No Upcoming Appointments',
                        message: 'You have no scheduled consultations. Book a doctor visit or video consult now.',
                        actionText: 'Find Doctors',
                        onAction: () => Navigator.of(context).pushNamed(AppRoutes.doctorList),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: upcomingList.length,
                        itemBuilder: (context, index) {
                          final apt = upcomingList[index];
                          return AppointmentCard(
                            appointment: apt,
                            onJoinConsultation: () {
                              if (apt.type == ConsultationType.video) {
                                Navigator.of(context).pushNamed(AppRoutes.videoCall);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Hospital directions opened: ${apt.clinicName}')),
                                );
                              }
                            },
                            onReschedule: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.doctorDetail,
                                arguments: apt.doctor.id,
                              );
                            },
                            onCancel: () => _showCancelDialog(apt),
                          );
                        },
                      ),

                // Past Appointments Tab
                pastList.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.history_rounded,
                        title: 'No Past Appointments',
                        message: 'Your completed and past consultation history will show up here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pastList.length,
                        itemBuilder: (context, index) {
                          final apt = pastList[index];
                          return AppointmentCard(
                            appointment: apt,
                            onViewDetails: () {
                              Navigator.of(context).pushNamed(AppRoutes.chat);
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
