import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message_model.dart';
import '../../models/doctor_model.dart';
import '../../models/prescription_model.dart';

class ChatState {
  final String? activeDoctorId;
  final List<ChatMessageModel> messages;
  final bool isDoctorTyping;

  const ChatState({
    this.activeDoctorId,
    required this.messages,
    this.isDoctorTyping = false,
  });

  ChatState copyWith({
    String? activeDoctorId,
    List<ChatMessageModel>? messages,
    bool? isDoctorTyping,
  }) {
    return ChatState(
      activeDoctorId: activeDoctorId ?? this.activeDoctorId,
      messages: messages ?? this.messages,
      isDoctorTyping: isDoctorTyping ?? this.isDoctorTyping,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState(
      messages: [],
      isDoctorTyping: false,
    );
  }

  /// Initialize real consultation chat for a specific doctor
  void initializeChatForDoctor(DoctorModel doctor) {
    if (state.activeDoctorId == doctor.id && state.messages.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final timeStr = _formatTime(now);

    final welcomeMsg = ChatMessageModel(
      id: 'msg_welcome_${now.millisecondsSinceEpoch}',
      text:
          'Hello, I am ${doctor.name}, ${doctor.specialty} at ${doctor.clinicName}. I am reviewing your consultation file. How are you feeling today? Please describe your symptoms in detail.',
      time: timeStr,
      isDoctor: true,
    );

    state = ChatState(
      activeDoctorId: doctor.id,
      messages: [welcomeMsg],
      isDoctorTyping: false,
    );
  }

  /// Send patient message and receive realistic doctor clinical guidance
  void sendMessage(String text, {DoctorModel? doctor}) {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final timeStr = _formatTime(now);

    final userMsg = ChatMessageModel(
      id: 'msg_${now.millisecondsSinceEpoch}',
      text: text.trim(),
      time: timeStr,
      isDoctor: false,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isDoctorTyping: true,
    );

    // Realistic doctor evaluation delay (1.2 seconds)
    Timer(const Duration(milliseconds: 1200), () {
      final docReply = _generateClinicalReply(text.trim(), doctor);
      final docMsg = ChatMessageModel(
        id: 'msg_doc_${DateTime.now().millisecondsSinceEpoch}',
        text: docReply,
        time: _formatTime(DateTime.now()),
        isDoctor: true,
      );

      state = state.copyWith(
        messages: [...state.messages, docMsg],
        isDoctorTyping: false,
      );
    });
  }

  /// Attach a medical document, report, or image
  void sendAttachment(String name, String size, {String type = 'PDF Document'}) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    final userMsg = ChatMessageModel(
      id: 'msg_${now.millisecondsSinceEpoch}',
      text: 'Uploaded medical file: $name',
      time: timeStr,
      isDoctor: false,
      attachmentName: name,
      attachmentSize: size,
      attachmentType: type,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isDoctorTyping: true,
    );

    Timer(const Duration(milliseconds: 1400), () {
      final docMsg = ChatMessageModel(
        id: 'msg_doc_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Received and verified "$name" ($size). All vital markers noted. I am drafting your official medical prescription now.',
        time: _formatTime(DateTime.now()),
        isDoctor: true,
      );

      state = state.copyWith(
        messages: [...state.messages, docMsg],
        isDoctorTyping: false,
      );
    });
  }

  /// Doctor sends an electronic prescription directly into the chat
  void sendPrescription(PrescriptionModel rx) {
    final now = DateTime.now();
    final timeStr = _formatTime(now);

    final rxMsg = ChatMessageModel(
      id: 'msg_rx_${now.millisecondsSinceEpoch}',
      text: 'Digital Prescription #${rx.id} issued for "${rx.diagnosis}". Includes ${rx.medicines.length} prescribed medications.',
      time: timeStr,
      isDoctor: true,
      attachmentName: 'Official_Rx_${rx.id}.pdf',
      attachmentSize: 'Digitally Verified',
      attachmentType: 'prescription',
    );

    state = state.copyWith(
      messages: [...state.messages, rxMsg],
      isDoctorTyping: false,
    );
  }

  void clearChat() {
    state = const ChatState(messages: []);
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _generateClinicalReply(String userText, DoctorModel? doctor) {
    final lower = userText.toLowerCase();

    if (lower.contains('fever') || lower.contains('temperature') || lower.contains('chills')) {
      return 'Please monitor your temperature with a digital thermometer every 6 hours. Take Paracetamol 650mg only if temperature is above 100°F. Ensure adequate hydration with warm fluids and ORS.';
    } else if (lower.contains('cough') || lower.contains('throat') || lower.contains('cold')) {
      return 'For the throat irritation and cough, do warm salt-water gargles 3 times a day. Avoid cold drinks. I recommend taking an anti-allergic antihistamine and prescribed expectorant syrup after meals.';
    } else if (lower.contains('stomach') || lower.contains('pain') || lower.contains('vomit') || lower.contains('nausea')) {
      return 'For abdominal discomfort, maintain a light bland diet (khichdi, curd, toast). Avoid spicy, oily food or dairy. Take an antacid / PPI 30 minutes before breakfast.';
    } else if (lower.contains('headache') || lower.contains('migraine') || lower.contains('stress')) {
      return 'Rest in a quiet, dimly lit room. Avoid prolonged screen time and ensure adequate sleep. If the headache is severe or accompanied by nausea, let me know right away.';
    } else if (lower.contains('prescription') || lower.contains('medicine') || lower.contains('tablet') || lower.contains('rx')) {
      return 'I have documented your symptoms and generated your official electronic prescription. You can view the prescribed medicines, download the Rx, or order tablets directly with home delivery.';
    } else {
      return 'Noted. Based on your symptoms, I have updated your consultation chart. Please follow the prescribed medication course and let me know if any symptoms worsen.';
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
