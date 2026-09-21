import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../data/mock/mock_data.dart';

class BookingDraft {
  final DoctorModel? doctor;
  final ConsultationType type;
  final DateTime selectedDate;
  final String selectedSlot;
  final String selectedLanguage;
  final String? appliedCoupon;
  final double discountAmount;
  final String patientNotes;

  BookingDraft({
    this.doctor,
    this.type = ConsultationType.video,
    DateTime? selectedDate,
    this.selectedSlot = '10:30 AM',
    this.selectedLanguage = 'English',
    this.appliedCoupon,
    this.discountAmount = 0.0,
    this.patientNotes = '',
  }) : selectedDate = selectedDate ?? DateTime.now().add(const Duration(days: 1));

  double get consultationFee => doctor?.consultationFee ?? 500.0;
  double get platformFee => 49.0;
  double get taxes => 18.0; // GST approx
  double get totalAmount {
    final subtotal = consultationFee + platformFee + taxes;
    final total = subtotal - discountAmount;
    return total > 0 ? total : 0.0;
  }

  BookingDraft copyWith({
    DoctorModel? doctor,
    ConsultationType? type,
    DateTime? selectedDate,
    String? selectedSlot,
    String? selectedLanguage,
    String? appliedCoupon,
    bool clearCoupon = false,
    double? discountAmount,
    String? patientNotes,
  }) {
    return BookingDraft(
      doctor: doctor ?? this.doctor,
      type: type ?? this.type,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: clearCoupon ? 0.0 : (discountAmount ?? this.discountAmount),
      patientNotes: patientNotes ?? this.patientNotes,
    );
  }
}

class AppointmentState {
  final List<AppointmentModel> appointments;
  final BookingDraft draft;
  final AppointmentModel? lastConfirmedAppointment;

  const AppointmentState({
    required this.appointments,
    required this.draft,
    this.lastConfirmedAppointment,
  });

  List<AppointmentModel> get upcomingAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.upcoming).toList();

  List<AppointmentModel> get pastAppointments =>
      appointments.where((a) => a.status != AppointmentStatus.upcoming).toList();

  AppointmentState copyWith({
    List<AppointmentModel>? appointments,
    BookingDraft? draft,
    AppointmentModel? lastConfirmedAppointment,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      draft: draft ?? this.draft,
      lastConfirmedAppointment: lastConfirmedAppointment ?? this.lastConfirmedAppointment,
    );
  }
}

class AppointmentNotifier extends Notifier<AppointmentState> {
  @override
  AppointmentState build() {
    return AppointmentState(
      appointments: List.from(MockData.initialAppointments),
      draft: BookingDraft(doctor: MockData.doctors[0]),
    );
  }

  void startBooking(DoctorModel doctor, {ConsultationType type = ConsultationType.video}) {
    state = state.copyWith(
      draft: BookingDraft(
        doctor: doctor,
        type: type,
        selectedDate: DateTime.now().add(const Duration(days: 1)),
        selectedSlot: '10:30 AM',
        selectedLanguage: 'English',
      ),
    );
  }

  void updateDraftType(ConsultationType type) {
    state = state.copyWith(draft: state.draft.copyWith(type: type));
  }

  void updateDraftDate(DateTime date) {
    state = state.copyWith(draft: state.draft.copyWith(selectedDate: date));
  }

  void updateDraftSlot(String slot) {
    state = state.copyWith(draft: state.draft.copyWith(selectedSlot: slot));
  }

  void updateDraftLanguage(String lang) {
    state = state.copyWith(draft: state.draft.copyWith(selectedLanguage: lang));
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'HEALTH50') {
      state = state.copyWith(
        draft: state.draft.copyWith(
          appliedCoupon: cleanCode,
          discountAmount: 50.0,
        ),
      );
      return true;
    } else if (cleanCode == 'MEDICARE100') {
      state = state.copyWith(
        draft: state.draft.copyWith(
          appliedCoupon: cleanCode,
          discountAmount: 100.0,
        ),
      );
      return true;
    } else if (cleanCode == 'FIRSTFREE') {
      state = state.copyWith(
        draft: state.draft.copyWith(
          appliedCoupon: cleanCode,
          discountAmount: 200.0,
        ),
      );
      return true;
    }
    return false;
  }

  void removeCoupon() {
    state = state.copyWith(
      draft: state.draft.copyWith(clearCoupon: true),
    );
  }

  AppointmentModel confirmBooking() {
    final d = state.draft;
    final doctor = d.doctor ?? MockData.doctors[0];
    final newAppointment = AppointmentModel(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      doctor: doctor,
      patientName: 'Piyush Prajapati',
      type: d.type,
      date: d.selectedDate,
      timeSlot: d.selectedSlot,
      status: AppointmentStatus.upcoming,
      fee: d.totalAmount,
      preferredLanguage: d.selectedLanguage,
      clinicName: d.type == ConsultationType.inPerson ? doctor.clinicName : null,
      meetingLink: d.type == ConsultationType.video ? 'https://medicare.plus/meet/${DateTime.now().millisecondsSinceEpoch}' : null,
    );

    final updated = [newAppointment, ...state.appointments];
    state = state.copyWith(
      appointments: updated,
      lastConfirmedAppointment: newAppointment,
    );
    return newAppointment;
  }

  void cancelAppointment(String id) {
    final updated = state.appointments.map((a) {
      if (a.id == id) {
        return AppointmentModel(
          id: a.id,
          doctor: a.doctor,
          patientName: a.patientName,
          type: a.type,
          date: a.date,
          timeSlot: a.timeSlot,
          status: AppointmentStatus.cancelled,
          fee: a.fee,
          preferredLanguage: a.preferredLanguage,
          meetingLink: a.meetingLink,
          clinicName: a.clinicName,
        );
      }
      return a;
    }).toList();

    state = state.copyWith(appointments: updated);
  }
}

final appointmentProvider = NotifierProvider<AppointmentNotifier, AppointmentState>(AppointmentNotifier.new);
