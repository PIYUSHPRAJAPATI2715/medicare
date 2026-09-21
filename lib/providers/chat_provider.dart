import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message_model.dart';
import '../../data/mock/mock_data.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isDoctorTyping;

  const ChatState({
    required this.messages,
    this.isDoctorTyping = false,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isDoctorTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isDoctorTyping: isDoctorTyping ?? this.isDoctorTyping,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(
      messages: List.from(MockData.initialChatMessages),
    );
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final userMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      time: timeStr,
      isDoctor: false,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isDoctorTyping: true,
    );

    Timer(const Duration(milliseconds: 1500), () {
      final docMsg = ChatMessageModel(
        id: 'msg_doc_${DateTime.now().millisecondsSinceEpoch}',
        text: _generateDoctorResponse(text),
        time: timeStr,
        isDoctor: true,
      );

      state = state.copyWith(
        messages: [...state.messages, docMsg],
        isDoctorTyping: false,
      );
    });
  }

  void sendAttachment(String name, String size) {
    final now = DateTime.now();
    final timeStr = '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final userMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Uploaded medical document: $name',
      time: timeStr,
      isDoctor: false,
      attachmentName: name,
      attachmentSize: size,
      attachmentType: 'PDF Document',
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isDoctorTyping: true,
    );

    Timer(const Duration(milliseconds: 1600), () {
      final docMsg = ChatMessageModel(
        id: 'msg_doc_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Thank you for sharing $name. I am reviewing the parameters now.',
        time: timeStr,
        isDoctor: true,
      );

      state = state.copyWith(
        messages: [...state.messages, docMsg],
        isDoctorTyping: false,
      );
    });
  }

  String _generateDoctorResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('fever') || q.contains('temp')) {
      return 'Please record your body temperature every 4 hours and take Paracetamol 650mg if fever crosses 100°F. Keep sponge towels handy.';
    } else if (q.contains('pain') || q.contains('headache')) {
      return 'Make sure to stay in a quiet, dimly lit room. Avoid screen time for the next 2 hours and drink at least 500ml of electrolytes.';
    } else if (q.contains('medicine') || q.contains('prescription')) {
      return 'I have forwarded the e-prescription with dosages to your MediCare+ account under Medical Records.';
    } else {
      return 'Understood. Please keep monitoring how you feel over the next 12 hours. If discomfort persists, we can connect on an instant video call.';
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
