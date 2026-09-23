import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart';
import '../../models/doctor_model.dart';
import '../../providers/prescription_provider.dart';
import '../../services/agora_service.dart';
import '../prescription/prescription_detail_screen.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final DoctorModel? doctor;

  const VideoCallScreen({super.key, this.doctor});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  final AgoraService _agora = AgoraService();
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;
  int _seconds = 32;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final doc = widget.doctor ?? MockData.doctors[0];
    _agora.joinConsultation(
      doctorId: doc.id,
      patientId: MockData.currentPatient.id,
      callType: AgoraCallType.video,
      customChannel: AppConstants.agoraDefaultChannel,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _agora.endCall();
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

    // Doctor generates digital prescription automatically on consultation end
    final newRx = ref
        .read(prescriptionProvider.notifier)
        .generatePrescriptionForConsultation(doctor: doc);

    // Show quick alert and navigate directly to prescription screen
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
              'Consultation Ended',
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
                  Navigator.pop(ctx); // Close dialog
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Doctor Video Stream (Simulated Agora HD Video Feed)
          Positioned.fill(
            child: Image.network(
              doc.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1E293B),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_rounded,
                          color: Colors.white54, size: 64),
                      const SizedBox(height: 12),
                      Text(doc.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dark subtle gradient overlay at top and bottom
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // 2. Top Bar (Agora RTC Channel, Doctor Name, timer, status)
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agora Room Credentials Header Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Agora RTC • Room: ${AppConstants.agoraDefaultChannel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_agora.latencyMs} ms',
                          style: const TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 6)
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
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
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(_seconds),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hd_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Agora 1080p',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. PIP Floating Patient Video (Bottom Right)
          Positioned(
            bottom: 120,
            right: 20,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.network(
                      MockData.currentPatient.avatarUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child:
                            Icon(Icons.person, color: Colors.white, size: 36),
                      ),
                    ),
                    if (_isVideoOff)
                      Container(
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(Icons.videocam_off_rounded,
                              color: Colors.white54, size: 28),
                        ),
                      ),
                    Positioned(
                      bottom: 4,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('You (Agora)',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Controls Bar Pill
          Positioned(
            bottom: 36,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute toggle
                  _callControlButton(
                    icon: _isMuted
                        ? Icons.mic_off_rounded
                        : Icons.mic_rounded,
                    label: 'Mute',
                    isActive: _isMuted,
                    onTap: () {
                      _agora.toggleMute();
                      setState(() => _isMuted = !_isMuted);
                    },
                  ),
                  // Video toggle
                  _callControlButton(
                    icon: _isVideoOff
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    label: 'Video',
                    isActive: _isVideoOff,
                    onTap: () {
                      _agora.toggleVideo();
                      setState(() => _isVideoOff = !_isVideoOff);
                    },
                  ),
                  // End Call (Red button -> Triggers Doctor Prescription Flow)
                  GestureDetector(
                    onTap: () => _handleEndCall(doc),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                  // Chat shortcut
                  _callControlButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat',
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.chat);
                    },
                  ),
                  // Flip camera
                  _callControlButton(
                    icon: Icons.flip_camera_ios_rounded,
                    label: 'Flip',
                    onTap: () {
                      _agora.switchCamera();
                      setState(() => _isFrontCamera = !_isFrontCamera);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(_isFrontCamera
                                ? 'Agora: Front Camera active'
                                : 'Agora: Rear Camera active')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
