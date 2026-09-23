import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart';
import '../../models/doctor_model.dart';
import '../../providers/prescription_provider.dart';
import '../../services/agora_service.dart';
import '../prescription/prescription_detail_screen.dart';

class AudioCallScreen extends ConsumerStatefulWidget {
  final DoctorModel? doctor;

  const AudioCallScreen({super.key, this.doctor});

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen>
    with SingleTickerProviderStateMixin {
  final AgoraService _agora = AgoraService();
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _seconds = 45;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final doc = widget.doctor ?? MockData.doctors[0];
    _agora.joinConsultation(
      doctorId: doc.id,
      patientId: MockData.currentPatient.id,
      callType: AgoraCallType.audio,
      customChannel: AppConstants.agoraDefaultChannel,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _agora.endCall();
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleEndCall(DoctorModel doc) async {
    _timer?.cancel();
    await _agora.endCall();

    if (!mounted) return;

    final newRx = ref
        .read(prescriptionProvider.notifier)
        .generatePrescriptionForConsultation(doctor: doc);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFDEF7EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_rounded,
                  color: Color(0xFF0E9F6E), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Call Completed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${doc.name} has issued your official digital prescription.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (c) => PrescriptionDetailScreen(prescription: newRx),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Prescription & Order Tablets',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor ?? MockData.doctors[0];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Agora Connection Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Agora Voice • Room: ${AppConstants.agoraDefaultChannel}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_agora.latencyMs}ms',
                      style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              doc.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${doc.specialty} • ${_formatDuration(_seconds)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),

            // Pulsing Avatar
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(20 * _pulseController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary
                          .withOpacity(0.15 * (1 - _pulseController.value)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.network(
                          doc.imageUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person,
                                  size: 80, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // Audio Call Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      _agora.toggleMute();
                      setState(() => _isMuted = !_isMuted);
                    },
                    iconSize: 50,
                    icon: CircleAvatar(
                      radius: 26,
                      backgroundColor: _isMuted ? Colors.white : Colors.white24,
                      child: Icon(
                        _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMuted ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleEndCall(doc),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _agora.toggleSpeaker();
                      setState(() => _isSpeaker = !_isSpeaker);
                    },
                    iconSize: 50,
                    icon: CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          _isSpeaker ? Colors.white : Colors.white24,
                      child: Icon(
                        _isSpeaker
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        color: _isSpeaker ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
