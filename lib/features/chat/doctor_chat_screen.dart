import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart';
import '../../models/chat_message_model.dart';
import '../../models/doctor_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/prescription_provider.dart';
import '../prescription/prescription_detail_screen.dart';
import '../subscription/subscription_paywall_dialog.dart';

class DoctorChatScreen extends ConsumerStatefulWidget {
  final DoctorModel? doctor;

  const DoctorChatScreen({super.key, this.doctor});

  @override
  ConsumerState<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends ConsumerState<DoctorChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickSymptoms = [
    'High fever & body chills',
    'Severe sore throat & cough',
    'Headache & nasal blockage',
    'Stomach ache after dinner',
    'Need prescription refill',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doc = widget.doctor ?? MockData.doctors[0];
      ref.read(chatProvider.notifier).initializeChatForDoctor(doc);
    });
  }

  void _sendMessage([String? quickText]) {
    final doc = widget.doctor ?? MockData.doctors[0];
    final text = quickText ?? _messageController.text;
    if (text.trim().isEmpty) return;

    SubscriptionPaywallDialog.checkAndProceed(
      context,
      ref,
      doctorName: doc.name,
      onProceed: () {
        ref.read(chatProvider.notifier).sendMessage(text.trim(), doctor: doc);
        if (quickText == null) {
          _messageController.clear();
        }
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    final doc = widget.doctor ?? MockData.doctors[0];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share Medical Records with Doctor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachmentTile(
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.red,
                    label: 'Blood Report',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(chatProvider.notifier).sendAttachment(
                            'CBC_Blood_Test_Report.pdf',
                            '1.8 MB',
                            type: 'Lab Report',
                          );
                      _scrollToBottom();
                    },
                  ),
                  _attachmentTile(
                    icon: Icons.medication_rounded,
                    color: AppColors.primary,
                    label: 'Issue Rx',
                    onTap: () {
                      Navigator.pop(context);
                      final newRx = ref
                          .read(prescriptionProvider.notifier)
                          .generatePrescriptionForConsultation(doctor: doc);
                      ref.read(chatProvider.notifier).sendPrescription(newRx);
                      _scrollToBottom();
                    },
                  ),
                  _attachmentTile(
                    icon: Icons.photo_library_rounded,
                    color: Colors.purple,
                    label: 'Symptom Photo',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(chatProvider.notifier).sendAttachment(
                            'throat_rash_image.jpg',
                            '2.4 MB',
                            type: 'Image',
                          );
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor ?? MockData.doctors[0];
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    doc.imageUrl,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 30),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Online • Real Agora Consultation',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Audio Call button with Paywall Guard
          IconButton(
            tooltip: 'Agora Audio Call',
            icon: const Icon(Icons.phone_rounded,
                color: AppColors.primary, size: 22),
            onPressed: () {
              SubscriptionPaywallDialog.checkAndProceed(
                context,
                ref,
                doctorName: doc.name,
                onProceed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.audioCall,
                    arguments: doc,
                  );
                },
              );
            },
          ),
          // Video Call button with Paywall Guard
          IconButton(
            tooltip: 'Agora Video Call',
            icon: const Icon(Icons.videocam_rounded,
                color: AppColors.primary, size: 24),
            onPressed: () {
              SubscriptionPaywallDialog.checkAndProceed(
                context,
                ref,
                doctorName: doc.name,
                onProceed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.videoCall,
                    arguments: doc,
                  );
                },
              );
            },
          ),
          // Issue Rx button
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDEF7EC),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final newRx = ref
                    .read(prescriptionProvider.notifier)
                    .generatePrescriptionForConsultation(doctor: doc);
                ref.read(chatProvider.notifier).sendPrescription(newRx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        PrescriptionDetailScreen(prescription: newRx),
                  ),
                );
              },
              icon: const Icon(Icons.medication_rounded,
                  size: 15, color: Color(0xFF0E9F6E)),
              label: const Text(
                'Rx',
                style: TextStyle(
                  color: Color(0xFF0E9F6E),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Symptoms Chips Bar
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickSymptoms.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final sym = _quickSymptoms[idx];
                return ActionChip(
                  label: Text(sym,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: () => _sendMessage(sym),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Real Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return _buildChatBubble(msg, doc);
              },
            ),
          ),

          // Live Typing Indicator
          if (chatState.isDoctorTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${doc.name} is typing clinical notes...',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Composer Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.textSecondary),
                    onPressed: _showAttachmentOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Describe your symptoms...',
                        hintStyle: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 14),
                        filled: true,
                        fillColor:
                            AppColors.surfaceVariant.withValues(alpha: 0.6),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, DoctorModel doc) {
    final isDoctor = msg.isDoctor;
    final isPrescription = msg.attachmentType == 'prescription';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isDoctor ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isDoctor) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  doc.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.medical_services_rounded,
                      size: 14,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDoctor ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isDoctor ? 4 : 16),
                  bottomRight: Radius.circular(isDoctor ? 16 : 4),
                ),
                border:
                    isDoctor ? Border.all(color: AppColors.borderLight) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isDoctor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  if (msg.hasAttachment) ...[
                    GestureDetector(
                      onTap: () {
                        final rx = ref.read(prescriptionProvider).latestPrescription;
                        if (rx != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  PrescriptionDetailScreen(prescription: rx),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isPrescription
                              ? const Color(0xFFDEF7EC)
                              : (isDoctor
                                  ? AppColors.surfaceVariant
                                  : Colors.white.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(12),
                          border: isPrescription
                              ? Border.all(color: const Color(0xFF31C48D))
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPrescription
                                  ? Icons.medication_rounded
                                  : Icons.picture_as_pdf_rounded,
                              color: isPrescription
                                  ? const Color(0xFF0E9F6E)
                                  : (isDoctor ? Colors.red : Colors.white),
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.attachmentName ?? 'Document.pdf',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                      color: isPrescription
                                          ? const Color(0xFF03543F)
                                          : (isDoctor
                                              ? AppColors.textPrimary
                                              : Colors.white),
                                    ),
                                  ),
                                  Text(
                                    isPrescription
                                        ? '👉 Tap to Order Tablets / Home Delivery'
                                        : 'Tap to view file',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isPrescription
                                          ? const Color(0xFF046C4E)
                                          : (isDoctor
                                              ? AppColors.primary
                                              : Colors.white70),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDoctor ? AppColors.textPrimary : Colors.white,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDoctor
                              ? AppColors.textTertiary
                              : Colors.white70,
                        ),
                      ),
                      if (!isDoctor) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded,
                            size: 13, color: Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!isDoctor) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
