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
}
