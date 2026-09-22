class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String qualification;
  final int experienceYears;
  final double ratingPercentage;
  final int patientStoriesCount;
  final double consultationFee;
  final List<String> languages;
  final bool isOnline;
  final String imageUrl;
  final String clinicName;
  final String clinicAddress;
  final double distanceKm;
  final String nextAvailableSlot;
  final String aboutText;
  final List<String> services;
  final List<String> education;
  final List<String> experienceHistory;
  final bool allowsPhysical;
  final bool allowsVideo;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.experienceYears,
    required this.ratingPercentage,
    required this.patientStoriesCount,
    required this.consultationFee,
    required this.languages,
    required this.isOnline,
    required this.imageUrl,
    required this.clinicName,
    required this.clinicAddress,
    required this.distanceKm,
    required this.nextAvailableSlot,
    required this.aboutText,
    required this.services,
    required this.education,
    required this.experienceHistory,
    this.allowsPhysical = true,
    this.allowsVideo = true,
  });

  String get formattedFee => '₹${consultationFee.toInt()}';
  String get experienceText => '$experienceYears Years Experience';
  String get ratingText => '${ratingPercentage.toStringAsFixed(0)}% ($patientStoriesCount Patient Stories)';
  String get languagesText => languages.join(', ');

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? 'General Physician',
      qualification: json['qualification']?.toString() ?? 'MBBS',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 5,
      ratingPercentage: (json['ratingPercentage'] as num?)?.toDouble() ?? 95.0,
      patientStoriesCount: (json['patientStoriesCount'] as num?)?.toInt() ?? 10,
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 500.0,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : ['English', 'Hindi'],
      isOnline: json['isOnline'] == true,
      imageUrl: json['imageUrl']?.toString() ??
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
      clinicName: json['clinicName']?.toString() ?? 'Medicare Clinic',
      clinicAddress: json['clinicAddress']?.toString() ?? 'City Center',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.5,
      nextAvailableSlot: json['nextAvailableSlot']?.toString() ?? 'Today, 04:00 PM',
      aboutText: json['aboutText']?.toString() ??
          'Experienced medical professional committed to providing compassionate patient care.',
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : ['General Consultation', 'Routine Checkup'],
      education: json['education'] != null
          ? List<String>.from(json['education'])
          : ['MBBS - Medical College'],
      experienceHistory: json['experienceHistory'] != null
          ? List<String>.from(json['experienceHistory'])
          : ['5+ years clinical practice'],
      allowsPhysical: json['allowsPhysical'] != false,
      allowsVideo: json['allowsVideo'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'ratingPercentage': ratingPercentage,
      'patientStoriesCount': patientStoriesCount,
      'consultationFee': consultationFee,
      'languages': languages,
      'isOnline': isOnline,
      'imageUrl': imageUrl,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'distanceKm': distanceKm,
      'nextAvailableSlot': nextAvailableSlot,
      'aboutText': aboutText,
      'services': services,
      'education': education,
      'experienceHistory': experienceHistory,
      'allowsPhysical': allowsPhysical,
      'allowsVideo': allowsVideo,
    };
  }
}
