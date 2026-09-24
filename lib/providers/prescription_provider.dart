import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';
import '../models/prescription_model.dart';
import 'auth_provider.dart';

class PrescriptionState {
  final List<PrescriptionModel> prescriptions;
  final PrescriptionModel? latestPrescription;
  final Map<String, DoctorModel> pendingDrafts;
  final String? lastNotificationMessage;
  final bool isLoading;

  const PrescriptionState({
    required this.prescriptions,
    this.latestPrescription,
    this.pendingDrafts = const {},
    this.lastNotificationMessage,
    this.isLoading = false,
  });

  PrescriptionState copyWith({
    List<PrescriptionModel>? prescriptions,
    PrescriptionModel? latestPrescription,
    Map<String, DoctorModel>? pendingDrafts,
    String? lastNotificationMessage,
    bool? isLoading,
  }) {
    return PrescriptionState(
      prescriptions: prescriptions ?? this.prescriptions,
      latestPrescription: latestPrescription ?? this.latestPrescription,
      pendingDrafts: pendingDrafts ?? this.pendingDrafts,
      lastNotificationMessage: lastNotificationMessage ?? this.lastNotificationMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrescriptionNotifier extends Notifier<PrescriptionState> {
  @override
  PrescriptionState build() {
    final sample1 = _createSamplePrescription();
    final sample2 = _createPastPrescription();
    return PrescriptionState(
      prescriptions: [sample1, sample2],
      latestPrescription: sample1,
    );
  }

  static PrescriptionModel _createSamplePrescription() {
    const medicines = [
      PrescribedMedicine(
        id: 'med_1',
        name: 'Augmentin 625 Duo',
        genericName: 'Amoxycillin (500mg) + Clavulanic Acid (125mg)',
        dosage: '625 mg',
        frequency: '1 tablet twice daily (Morning & Night)',
        instructions: 'Take strictly after meals with plenty of water',
        durationDays: 5,
        quantity: 10,
        unit: 'Tablets',
        unitPrice: 204.0,
      ),
      PrescribedMedicine(
        id: 'med_2',
        name: 'Dolo 650',
        genericName: 'Paracetamol',
        dosage: '650 mg',
        frequency: '1 tablet SOS (as needed, 6-8 hrs gap)',
        instructions: 'Take only when body temperature exceeds 100°F',
        durationDays: 3,
        quantity: 15,
        unit: 'Tablets',
        unitPrice: 33.5,
      ),
      PrescribedMedicine(
        id: 'med_3',
        name: 'Allegra 120mg',
        genericName: 'Fexofenadine Hydrochloride',
        dosage: '120 mg',
        frequency: '1 tablet once daily at bedtime',
        instructions: 'Take with warm water before sleeping',
        durationDays: 5,
        quantity: 10,
        unit: 'Tablets',
        unitPrice: 198.0,
      ),
      PrescribedMedicine(
        id: 'med_4',
        name: 'Alex Sugar-Free Cough Syrup (100ml)',
        genericName: 'Dextromethorphan + Chlorpheniramine',
        dosage: '10 ml',
        frequency: 'Twice daily after food',
        instructions: 'Use measuring cap provided, do not drink water immediately',
        durationDays: 5,
        quantity: 1,
        unit: 'Bottle',
        unitPrice: 145.0,
      ),
    ];

    double subtotal = 0;
    for (final m in medicines) {
      subtotal += m.unitPrice;
    }
    const discount = 85.0;

    return PrescriptionModel(
      id: 'RX-84920',
      consultationId: 'CONS-9482',
      doctorId: 'doc_001',
      doctorName: 'Dr. Vipin Kumar Jain',
      doctorSpecialty: 'Senior Consultant Physician (MBBS, MD)',
      doctorRegistration: 'RMC-48291',
      doctorAvatar:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
      patientId: 'pat_001',
      patientName: 'Piyush Prajapati',
      patientAgeGender: '30 Y / Male',
      diagnosis: 'Acute Upper Respiratory Tract Infection & Mild Bronchial Congestion',
      clinicalNotes:
          'Patient presented with sore throat, moderate fever, dry cough and nasal congestion for 3 days. Chest clear on auscultation, throat mildly hyperemic. Advised adequate oral hydration, steam inhalation, and 5-day antibiotic coverage.',
      medicines: medicines,
      issuedAt: DateTime.now(),
      followUpDate: DateTime.now().add(const Duration(days: 5)),
      fulfillmentType: OrderFulfillmentType.none,
      pharmacyStatus: PharmacyOrderStatus.none,
      totalMedicineCost: subtotal,
      discountAmount: discount,
      finalAmount: subtotal - discount,
    );
  }

  static PrescriptionModel _createPastPrescription() {
    const medicines = [
      PrescribedMedicine(
        id: 'past_1',
        name: 'Pantocid DSR Capsule',
        genericName: 'Pantoprazole (40mg) + Domperidone (30mg)',
        dosage: '40 mg',
        frequency: '1 capsule daily in the morning',
        instructions: 'Take 30 mins before breakfast on empty stomach',
        durationDays: 10,
        quantity: 10,
        unit: 'Capsules',
        unitPrice: 175.0,
      ),
      PrescribedMedicine(
        id: 'past_2',
        name: 'Gelusil Antacid Syrup (200ml)',
        genericName: 'Aluminium Hydroxide + Magnesium Hydroxide',
        dosage: '10 ml',
        frequency: 'SOS after heavy meals',
        instructions: 'Shake well before use',
        durationDays: 7,
        quantity: 1,
        unit: 'Bottle',
        unitPrice: 110.0,
      ),
    ];

    return PrescriptionModel(
      id: 'RX-79210',
      consultationId: 'CONS-8391',
      doctorId: 'doc_002',
      doctorName: 'Dr. Ananya Verma',
      doctorSpecialty: 'Gastroenterologist & Hepatologist (MD, DM)',
      doctorRegistration: 'RMC-39182',
      doctorAvatar:
          'https://images.unsplash.com/photo-1594824813637-41a4a4087910?w=400&auto=format&fit=crop&q=80',
      patientId: 'pat_001',
      patientName: 'Piyush Prajapati',
      patientAgeGender: '30 Y / Male',
      diagnosis: 'Gastroesophageal Reflux Disease (GERD) & Acid Dyspepsia',
      clinicalNotes:
          'Epigastric burning sensation reported post meals. Abdomen soft, non-tender. Dietary modifications advised (avoid spicy, oily food and caffeine).',
      adviceNotes: 'Eat small frequent meals. Avoid lying down within 2 hours after meals.',
      medicines: medicines,
      issuedAt: DateTime.now().subtract(const Duration(days: 8)),
      followUpDate: DateTime.now().subtract(const Duration(days: 1)),
      fulfillmentType: OrderFulfillmentType.orderedOnline,
      pharmacyStatus: PharmacyOrderStatus.delivered,
      status: PrescriptionLifecycleStatus.completed,
      totalMedicineCost: 285.0,
      discountAmount: 42.0,
      finalAmount: 243.0,
    );
  }


  /// Mark consultation as ended with doctor currently writing the Rx
  void startConsultationPendingRx(DoctorModel doctor, {String? consultationId}) {
    final updated = Map<String, DoctorModel>.from(state.pendingDrafts);
    updated[doctor.id] = doctor;
    state = state.copyWith(
      pendingDrafts: updated,
      lastNotificationMessage: '${doctor.name} is drafting your digital prescription...',
    );
  }


  /// Doctor submits completed and digitally signed prescription
  PrescriptionModel submitDoctorPrescription({
    required DoctorModel doctor,
    required String diagnosis,
    required String clinicalNotes,
    required String adviceNotes,
    required List<PrescribedMedicine> medicines,
    DateTime? followUpDate,
  }) {
    final patient = ref.read(authProvider).user;
    final rxId = 'RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    double subtotal = 0;
    for (final m in medicines) {
      subtotal += m.unitPrice;
    }
    final discount = (subtotal * 0.15).roundToDouble();

    final newRx = PrescriptionModel(
      id: rxId,
      consultationId: 'CONS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorRegistration: 'RMC-${40000 + doctor.experienceYears * 412}',
      doctorAvatar: doctor.imageUrl,
      patientId: patient.id,
      patientName: patient.name,
      patientAgeGender: '${patient.gender ?? "Male"} • 30 Yrs',
      diagnosis: diagnosis,
      clinicalNotes: clinicalNotes,
      adviceNotes: adviceNotes,
      medicines: medicines,
      status: PrescriptionLifecycleStatus.issued,
      issuedAt: DateTime.now(),
      followUpDate: followUpDate ?? DateTime.now().add(const Duration(days: 5)),
      fulfillmentType: OrderFulfillmentType.none,
      pharmacyStatus: PharmacyOrderStatus.none,
      totalMedicineCost: subtotal,
      discountAmount: discount,
      finalAmount: subtotal - discount,
    );

    final updatedDrafts = Map<String, DoctorModel>.from(state.pendingDrafts);
    updatedDrafts.remove(doctor.id);

    final updatedList = [newRx, ...state.prescriptions];
    state = state.copyWith(
      prescriptions: updatedList,
      latestPrescription: newRx,
      pendingDrafts: updatedDrafts,
      lastNotificationMessage: '🔔 ${doctor.name} has issued your official digital prescription!',
    );

    return newRx;
  }

  void clearNotificationMessage() {
    state = state.copyWith(lastNotificationMessage: null);
  }

  /// Create and emit prescription (convenience wrapper)
  PrescriptionModel generatePrescriptionForConsultation({
    required DoctorModel doctor,
    String? customDiagnosis,
  }) {
    final patient = ref.read(authProvider).user;
    final rxId = 'RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final medicines = [
      PrescribedMedicine(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}_1',
        name: 'Augmentin 625 Duo',
        genericName: 'Amoxycillin (500mg) + Clavulanic Acid (125mg)',
        dosage: '625 mg',
        frequency: '1 tablet twice daily',
        instructions: 'After food with full glass of water',
        durationDays: 5,
        quantity: 10,
        unit: 'Tablets',
        unitPrice: 204.0,
      ),
      PrescribedMedicine(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}_2',
        name: 'Dolo 650 Tablets',
        genericName: 'Paracetamol',
        dosage: '650 mg',
        frequency: '1 tablet thrice daily if fever',
        instructions: 'After meals',
        durationDays: 3,
        quantity: 15,
        unit: 'Tablets',
        unitPrice: 33.5,
      ),
      PrescribedMedicine(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}_3',
        name: 'Allegra 120mg',
        genericName: 'Fexofenadine',
        dosage: '120 mg',
        frequency: '1 tablet at bedtime',
        instructions: 'Before sleeping',
        durationDays: 5,
        quantity: 10,
        unit: 'Tablets',
        unitPrice: 198.0,
      ),
    ];

    double subtotal = 0;
    for (final m in medicines) {
      subtotal += m.unitPrice;
    }
    final discount = (subtotal * 0.15).roundToDouble();

    final newRx = PrescriptionModel(
      id: rxId,
      consultationId: 'CONS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorRegistration: 'RMC-${40000 + doctor.experienceYears * 412}',
      doctorAvatar: doctor.imageUrl,
      patientId: patient.id,
      patientName: patient.name,
      patientAgeGender: '${patient.gender ?? "Male"} • 30 Yrs',
      diagnosis: customDiagnosis ?? 'Upper Respiratory Tract Infection with Fever & Pharyngitis',
      clinicalNotes:
          'Consultation conducted via MediCare+ HD Agora Room. Vital signs reviewed. Complete course of medicines recommended. Rest, hydrate well and follow up in 5 days if symptoms persist.',
      adviceNotes: 'Adequate hydration, steam inhalation, and 5-day antibiotic coverage.',
      medicines: medicines,
      status: PrescriptionLifecycleStatus.issued,
      issuedAt: DateTime.now(),
      followUpDate: DateTime.now().add(const Duration(days: 5)),
      fulfillmentType: OrderFulfillmentType.none,
      pharmacyStatus: PharmacyOrderStatus.none,
      totalMedicineCost: subtotal,
      discountAmount: discount,
      finalAmount: subtotal - discount,
    );

    final updatedDrafts = Map<String, DoctorModel>.from(state.pendingDrafts);
    updatedDrafts.remove(doctor.id);

    final updated = [newRx, ...state.prescriptions];
    state = state.copyWith(
      prescriptions: updated,
      latestPrescription: newRx,
      pendingDrafts: updatedDrafts,
      lastNotificationMessage: '🔔 ${doctor.name} has issued your official digital prescription!',
    );
    return newRx;
  }

  /// Order tablets online through MediCare Partner Pharmacy
  void placePharmacyOrder(String prescriptionId, {required String address}) {
    final updatedList = state.prescriptions.map((rx) {
      if (rx.id == prescriptionId) {
        return rx.copyWith(
          fulfillmentType: OrderFulfillmentType.orderedOnline,
          pharmacyStatus: PharmacyOrderStatus.placed,
          deliveryAddress: address,
        );
      }
      return rx;
    }).toList();

    PrescriptionModel? updatedLatest = state.latestPrescription;
    if (updatedLatest != null && updatedLatest.id == prescriptionId) {
      updatedLatest = updatedLatest.copyWith(
        fulfillmentType: OrderFulfillmentType.orderedOnline,
        pharmacyStatus: PharmacyOrderStatus.placed,
        deliveryAddress: address,
      );
    }

    state = state.copyWith(
      prescriptions: updatedList,
      latestPrescription: updatedLatest,
    );
  }

  /// Mark prescription as user buying themselves
  void markAsBuySelf(String prescriptionId) {
    final updatedList = state.prescriptions.map((rx) {
      if (rx.id == prescriptionId) {
        return rx.copyWith(
          fulfillmentType: OrderFulfillmentType.buySelf,
          pharmacyStatus: PharmacyOrderStatus.none,
        );
      }
      return rx;
    }).toList();

    PrescriptionModel? updatedLatest = state.latestPrescription;
    if (updatedLatest != null && updatedLatest.id == prescriptionId) {
      updatedLatest = updatedLatest.copyWith(
        fulfillmentType: OrderFulfillmentType.buySelf,
      );
    }

    state = state.copyWith(
      prescriptions: updatedList,
      latestPrescription: updatedLatest,
    );
  }
}

final prescriptionProvider =
    NotifierProvider<PrescriptionNotifier, PrescriptionState>(
        PrescriptionNotifier.new);
