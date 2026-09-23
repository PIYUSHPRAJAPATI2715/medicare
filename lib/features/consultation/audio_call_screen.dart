import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart';
import '../../models/doctor_model.dart';
import '../../services/agora_service.dart';
import 'consultation_summary_screen.dart';

class AudioCallScreen extends ConsumerStatefulWidget {
  final DoctorModel? doctor;

  const AudioCallScreen({super.key, this.doctor});

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen>
    with SingleTickerProviderStateMixin {
  final AgoraService _agora = AgoraService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _agora.addListener(_onAgoraUpdate);
    final doc = widget.doctor ?? MockData.doctors[0];
    _agora.joinAudioCall(
      channel: '${AppConstants.agoraDefaultChannel}-${doc.id}',
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _onAgoraUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _agora.removeListener(_onAgoraUpdate);
    _pulseController.dispose();
    _agora.leaveChannel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleEndCall(DoctorModel doc) async {
    final duration = _agora.callDurationSeconds;
    await _agora.leaveChannel();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationSummaryScreen(
          doctor: doc,
          callDurationSeconds: duration > 0 ? duration : 180,
          callType: 'audio',
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
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _agora.isLocalJoined
                          ? const Color(0xFF10B981)
                          : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Agora Voice • Room: ${_agora.channelName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.3),
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
              '${doc.specialty} • ${_formatDuration(_agora.callDurationSeconds)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),

            // Pulsing Avatar for Audio Stream
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(24 * _pulseController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary
                          .withValues(alpha: 0.15 * (1 - _pulseController.value)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.3),
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

            const SizedBox(height: 24),
            Text(
              _agora.remoteUid != null
                  ? 'Doctor Connected (Agora UID: ${_agora.remoteUid})'
                  : 'Channel Connected • Waiting for doctor audio...',
              style: TextStyle(
                fontSize: 12,
                color: _agora.remoteUid != null
                    ? const Color(0xFF34D399)
                    : Colors.white60,
                fontWeight: FontWeight.w600,
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
                    onPressed: () => _agora.toggleMute(),
                    iconSize: 50,
                    icon: CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          _agora.isMuted ? Colors.white : Colors.white24,
                      child: Icon(
                        _agora.isMuted
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        color: _agora.isMuted ? Colors.black : Colors.white,
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
                    onPressed: () => _agora.toggleSpeaker(),
                    iconSize: 50,
                    icon: CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          _agora.isSpeaker ? Colors.white : Colors.white24,
                      child: Icon(
                        _agora.isSpeaker
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        color: _agora.isSpeaker ? Colors.black : Colors.white,
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
