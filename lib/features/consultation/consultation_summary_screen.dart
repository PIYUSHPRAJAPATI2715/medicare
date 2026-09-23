import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../models/prescription_model.dart';
import '../../providers/prescription_provider.dart';
import '../doctor_dashboard/doctor_prescription_writer_sheet.dart';
import '../prescription/prescription_detail_screen.dart';

class ConsultationSummaryScreen extends ConsumerStatefulWidget {
  final DoctorModel doctor;
  final int callDurationSeconds;
  final String callType; // 'video' or 'audio'

  const ConsultationSummaryScreen({
    super.key,
    required this.doctor,
    this.callDurationSeconds = 270,
    this.callType = 'video',
  });

  @override
  ConsumerState<ConsultationSummaryScreen> createState() =>
      _ConsultationSummaryScreenState();
}

class _ConsultationSummaryScreenState
    extends ConsumerState<ConsultationSummaryScreen> {
  Timer? _countdownTimer;
  int _secondsWaiting = 0;
  bool _isAutoSimulated = false;

  @override
  void initState() {
    super.initState();
    // Register that this doctor is currently drafting prescription
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(prescriptionProvider.notifier)
          .startConsultationPendingRx(widget.doctor);
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _secondsWaiting++;
        });

        // Auto-deliver after 15 seconds if user stays on this screen to simulate realistic arrival
        if (_secondsWaiting >= 15 && !_isAutoSimulated) {
          _isAutoSimulated = true;
          ref
              .read(prescriptionProvider.notifier)
              .generatePrescriptionForConsultation(doctor: widget.doctor);
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _openDoctorPrescriptionWriter() async {
    final rx = await DoctorPrescriptionWriterSheet.show(
      context,
      doctor: widget.doctor,
    );
    if (rx != null && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final rxState = ref.watch(prescriptionProvider);
    final hasReceivedRx = rxState.latestPrescription != null &&
        rxState.latestPrescription!.doctorId == widget.doctor.id &&
        rxState.latestPrescription!.issuedAt
            .isAfter(DateTime.now().subtract(const Duration(minutes: 5)));

    final currentRx = rxState.latestPrescription;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Consultation Summary',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Close to Home',
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.mainShell,
                (r) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Doctor Card Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.doctor.imageUrl,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.medical_services_rounded,
                              size: 40),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctor.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.doctor.specialty,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.doctor.clinicName,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol('Call Duration',
                          _formatDuration(widget.callDurationSeconds), Icons.timer_outlined),
                      Container(width: 1, height: 28, color: Colors.grey.shade200),
                      _metricCol('Mode',
                          widget.callType == 'video' ? 'HD Video' : 'Agora Voice',
                          widget.callType == 'video'
                              ? Icons.videocam_rounded
                              : Icons.phone_in_talk_rounded),
                      Container(width: 1, height: 28, color: Colors.grey.shade200),
                      _metricCol('Time',
                          DateFormat('hh:mm a').format(DateTime.now()), Icons.access_time_rounded),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Prescription Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: hasReceivedRx
                    ? const LinearGradient(
                        colors: [Color(0xFF0E9F6E), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: (hasReceivedRx
                            ? const Color(0xFF0E9F6E)
                            : const Color(0xFF2563EB))
                        .withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasReceivedRx
                              ? Icons.check_circle_rounded
                              : Icons.edit_note_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasReceivedRx
                                  ? 'Prescription Delivered! 🎉'
                                  : 'Doctor is Preparing Prescription ⏳',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasReceivedRx
                                  ? 'Dr. Vipin Sharma has signed your prescription'
                                  : 'Usually arrives within 2-5 minutes',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: hasReceivedRx
                        ? Row(
                            children: [
                              const Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Diagnosis: ${currentRx?.diagnosis ?? "Prescription Ready"} (${currentRx?.medicines.length ?? 0} medicines prescribed)',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Doctor reviewing call notes & prescribing medicines (${(15 - _secondsWaiting).clamp(0, 15)}s simulated ETA)...',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11.5),
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (hasReceivedRx && currentRx != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0E9F6E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrescriptionDetailScreen(
                                prescription: currentRx,
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication_liquid_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'View Rx & Order Medicines',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interactive Workflow Stepper
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prescription Fulfillment Journey',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  _stepItem(
                    step: 1,
                    title: 'Teleconsultation Completed',
                    subtitle: 'Doctor examined symptoms via Agora RTC session.',
                    isDone: true,
                    isActive: false,
                  ),
                  _stepItem(
                    step: 2,
                    title: 'Doctor Signs Digital Rx',
                    subtitle: hasReceivedRx
                        ? 'Prescription signed with medical registration seal.'
                        : 'Doctor is writing diagnosis, medicines & advice.',
                    isDone: hasReceivedRx,
                    isActive: !hasReceivedRx,
                  ),
                  _stepItem(
                    step: 3,
                    title: 'Medicine Delivery or Chemist Purchase',
                    subtitle: 'Order online with 15% discount or download Rx.',
                    isDone: currentRx?.fulfillmentType != OrderFulfillmentType.none,
                    isActive: hasReceivedRx &&
                        currentRx?.fulfillmentType == OrderFulfillmentType.none,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Doctor Manual Write trigger (for testing / demo experience)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doctor Side Simulation',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12.5)),
                        Text('Open Rx pad to write & deliver as doctor',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _openDoctorPrescriptionWriter,
                    child: const Text('Open Rx Pad',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Go to Home
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.mainShell,
                    (r) => false,
                  );
                },
                child: const Text('Return to Home Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCol(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        Text(title,
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _stepItem({
    required int step,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF0E9F6E)
                    : isActive
                        ? AppColors.primary
                        : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : Text(
                        '$step',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: isDone ? const Color(0xFF0E9F6E) : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDone || isActive
                      ? AppColors.textPrimary
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                ),
              ),
              if (!isLast) const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
