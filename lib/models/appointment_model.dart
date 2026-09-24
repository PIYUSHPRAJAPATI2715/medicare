import 'doctor_model.dart';

enum ConsultationType {
  inPerson,
  video,
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
}

class AppointmentModel {
  final String id;
  final DoctorModel doctor;
  final String patientName;
  final ConsultationType type;
  final DateTime date;
  final String timeSlot;
  final AppointmentStatus status;
  final double fee;
  final String preferredLanguage;
  final String? meetingLink;
  final String? clinicName;

  const AppointmentModel({
    required this.id,
    required this.doctor,
    required this.patientName,
    required this.type,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.fee,
    this.preferredLanguage = 'English',
    this.meetingLink,
    this.clinicName,
  });

  String get typeLabel => type == ConsultationType.inPerson ? 'Hospital Visit' : 'Video Consultation';

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DoctorModel doc;
    if (json['doctor'] is Map<String, dynamic>) {
      doc = DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>);
    } else {
      doc = DoctorModel.fromJson({
        'id': json['doctorId'] ?? 'd1',
        'name': 'Dr. Rajesh Sharma',
        'specialty': 'General Physician',
        'qualification': 'MBBS, MD',
        'experienceYears': 14,
        'consultationFee': 499.0,
      });
    }

    ConsultationType type = ConsultationType.video;
    if (json['type'] == 'inPerson') {
      type = ConsultationType.inPerson;
    }

    AppointmentStatus status = AppointmentStatus.upcoming;
    if (json['status'] == 'completed') {
      status = AppointmentStatus.completed;
    } else if (json['status'] == 'cancelled') {
      status = AppointmentStatus.cancelled;
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] as String);
    } catch (_) {
      parsedDate = DateTime.now().add(const Duration(days: 1));
    }

    return AppointmentModel(
      id: json['id']?.toString() ?? 'apt_${DateTime.now().millisecondsSinceEpoch}',
      doctor: doc,
      patientName: json['patientName']?.toString() ?? 'Patient',
      type: type,
      date: parsedDate,
      timeSlot: json['timeSlot']?.toString() ?? '10:30 AM',
      status: status,
      fee: (json['fee'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 499.0,
      preferredLanguage: json['selectedLanguage']?.toString() ?? json['preferredLanguage']?.toString() ?? 'English',
      meetingLink: json['meetingLink']?.toString() ?? (type == ConsultationType.video ? 'https://medicare.plus/meet/${json['agoraChannelName'] ?? json['id']}' : null),
      clinicName: json['clinicName']?.toString() ?? doc.clinicName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctor.id,
      'patientName': patientName,
      'type': type == ConsultationType.inPerson ? 'inPerson' : 'video',
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status.name,
      'fee': fee,
      'preferredLanguage': preferredLanguage,
      'meetingLink': meetingLink,
      'clinicName': clinicName,
    };
  }
}
