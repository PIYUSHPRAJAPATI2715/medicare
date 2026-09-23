class PrescribedMedicine {
  final String id;
  final String name;
  final String genericName;
  final String dosage;
  final String frequency; // e.g., '1-0-1' or 'Twice daily'
  final String instructions; // 'After food', 'Before food'
  final int durationDays;
  final int quantity;
  final String unit; // 'Tablets', 'Capsules', 'Syrup'
  final double unitPrice;

  const PrescribedMedicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.durationDays,
    required this.quantity,
    this.unit = 'Tablets',
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * (quantity > 0 ? 1 : 1);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'durationDays': durationDays,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }

  factory PrescribedMedicine.fromJson(Map<String, dynamic> json) {
    return PrescribedMedicine(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String? ?? '',
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      instructions: json['instructions'] as String? ?? 'After food',
      durationDays: json['durationDays'] as int? ?? 5,
      quantity: json['quantity'] as int? ?? 10,
      unit: json['unit'] as String? ?? 'Tablets',
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}

enum OrderFulfillmentType {
  none,
  orderedOnline,
  buySelf,
}

enum PharmacyOrderStatus {
  none,
  placed,
  confirmed,
  packed,
  outForDelivery,
  delivered,
}

class PrescriptionModel {
  final String id;
  final String consultationId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorRegistration;
  final String doctorAvatar;
  final String patientId;
  final String patientName;
  final String patientAgeGender;
  final String diagnosis;
  final String clinicalNotes;
  final List<PrescribedMedicine> medicines;
  final DateTime issuedAt;
  final DateTime? followUpDate;
  final OrderFulfillmentType fulfillmentType;
  final PharmacyOrderStatus pharmacyStatus;
  final String? deliveryAddress;
  final double totalMedicineCost;
  final double discountAmount;
  final double finalAmount;

  const PrescriptionModel({
    required this.id,
    required this.consultationId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorRegistration,
    required this.doctorAvatar,
    required this.patientId,
    required this.patientName,
    this.patientAgeGender = '30 Y / Male',
    required this.diagnosis,
    required this.clinicalNotes,
    required this.medicines,
    required this.issuedAt,
    this.followUpDate,
    this.fulfillmentType = OrderFulfillmentType.none,
    this.pharmacyStatus = PharmacyOrderStatus.none,
    this.deliveryAddress,
    required this.totalMedicineCost,
    this.discountAmount = 0.0,
    required this.finalAmount,
  });

  PrescriptionModel copyWith({
    OrderFulfillmentType? fulfillmentType,
    PharmacyOrderStatus? pharmacyStatus,
    String? deliveryAddress,
  }) {
    return PrescriptionModel(
      id: id,
      consultationId: consultationId,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      doctorRegistration: doctorRegistration,
      doctorAvatar: doctorAvatar,
      patientId: patientId,
      patientName: patientName,
      patientAgeGender: patientAgeGender,
      diagnosis: diagnosis,
      clinicalNotes: clinicalNotes,
      medicines: medicines,
      issuedAt: issuedAt,
      followUpDate: followUpDate,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      pharmacyStatus: pharmacyStatus ?? this.pharmacyStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalMedicineCost: totalMedicineCost,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
    );
  }
}
