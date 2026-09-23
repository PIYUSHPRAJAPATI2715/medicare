import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_model.dart';
import '../models/prescription_model.dart';
import 'auth_provider.dart';

class PrescriptionState {
  final List<PrescriptionModel> prescriptions;
  final PrescriptionModel? latestPrescription;
  final bool isLoading;

  const PrescriptionState({
    required this.prescriptions,
    this.latestPrescription,
    this.isLoading = false,
  });

  PrescriptionState copyWith({
    List<PrescriptionModel>? prescriptions,
    PrescriptionModel? latestPrescription,
    bool? isLoading,
  }) {
    return PrescriptionState(
      prescriptions: prescriptions ?? this.prescriptions,
      latestPrescription: latestPrescription ?? this.latestPrescription,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrescriptionNotifier extends Notifier<PrescriptionState> {
  @override
  PrescriptionState build() {
    final defaultRx = _createSamplePrescription();
    return PrescriptionState(
      prescriptions: [defaultRx],
      latestPrescription: defaultRx,
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

  /// Create and emit prescription right after call/chat ends
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
      medicines: medicines,
      issuedAt: DateTime.now(),
      followUpDate: DateTime.now().add(const Duration(days: 5)),
      fulfillmentType: OrderFulfillmentType.none,
      pharmacyStatus: PharmacyOrderStatus.none,
      totalMedicineCost: subtotal,
      discountAmount: discount,
      finalAmount: subtotal - discount,
    );

    final updated = [newRx, ...state.prescriptions];
    state = state.copyWith(
      prescriptions: updated,
      latestPrescription: newRx,
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
