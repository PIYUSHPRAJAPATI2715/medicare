class ChatMessageModel {
  final String id;
  final String text;
  final String time;
  final bool isDoctor;
  final String? attachmentName;
  final String? attachmentSize;
  final String? attachmentType;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isDoctor,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentType,
  });

  bool get hasAttachment => attachmentName != null;
}
