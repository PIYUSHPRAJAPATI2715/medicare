class DiseaseModel {
  final String id;
  final String name;
  final String specialty;
  final String symptomCount;

  const DiseaseModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.symptomCount,
  });

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? 'General Physician',
      symptomCount: json['symptomCount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'symptomCount': symptomCount,
    };
  }
}
