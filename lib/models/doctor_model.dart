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
}
