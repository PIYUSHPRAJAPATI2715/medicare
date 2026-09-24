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

  // Medical Registration & Verification Details
  final String email;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final String collegeName;
  final String graduationYear;
  final String postGradDegree;
  final String postGradCollege;
  final String postGradYear;
  final String medicalLicenseNo;
  final String stateMedicalCouncil;
  final String registrationYear;
  final String licenseExpiryYear;
  final String subSpecialty;
  final double videoConsultationFee;
  final bool isVerified;
  final String verificationStatus; // 'approved', 'pending', 'rejected', 'resubmit_requested'
  final String? rejectionRemarks;
  final String medicalCouncilCertUrl;
  final String primaryDegreeCertUrl;
  final String postGradCertUrl;
  final String idProofUrl;
  final String clinicAddressProofUrl;
  final String doctorSignatureUrl;
  final String? submittedAt;

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
    this.email = 'doctor@medicare.com',
    this.phone = '+91 98000 00000',
    this.gender = 'Male',
    this.dateOfBirth = '1985-05-15',
    this.collegeName = 'All India Institute of Medical Sciences (AIIMS)',
    this.graduationYear = '2012',
    this.postGradDegree = 'MD (General Medicine)',
    this.postGradCollege = 'PGIMER Chandigarh',
    this.postGradYear = '2016',
    this.medicalLicenseNo = 'MCI/2012/88412',
    this.stateMedicalCouncil = 'Medical Council of India',
    this.registrationYear = '2012',
    this.licenseExpiryYear = '2032',
    this.subSpecialty = 'Internal Medicine',
    this.videoConsultationFee = 499.0,
    this.isVerified = true,
    this.verificationStatus = 'approved',
    this.rejectionRemarks,
    this.medicalCouncilCertUrl = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
    this.primaryDegreeCertUrl = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
    this.postGradCertUrl = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
    this.idProofUrl = 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600',
    this.clinicAddressProofUrl = 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
    this.doctorSignatureUrl = 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600',
    this.submittedAt,
  });

  String get formattedFee => '₹${consultationFee.toInt()}';
  String get formattedVideoFee => '₹${videoConsultationFee.toInt()}';
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
      email: json['email']?.toString() ?? 'doctor@medicare.com',
      phone: json['phone']?.toString() ?? '+91 98000 00000',
      gender: json['gender']?.toString() ?? 'Male',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '1985-05-15',
      collegeName: json['collegeName']?.toString() ?? 'AIIMS New Delhi',
      graduationYear: json['graduationYear']?.toString() ?? '2012',
      postGradDegree: json['postGradDegree']?.toString() ?? 'MD',
      postGradCollege: json['postGradCollege']?.toString() ?? 'PGIMER',
      postGradYear: json['postGradYear']?.toString() ?? '2016',
      medicalLicenseNo: json['medicalLicenseNo']?.toString() ?? 'MCI/2012/88412',
      stateMedicalCouncil: json['stateMedicalCouncil']?.toString() ?? 'Medical Council of India',
      registrationYear: json['registrationYear']?.toString() ?? '2012',
      licenseExpiryYear: json['licenseExpiryYear']?.toString() ?? '2032',
      subSpecialty: json['subSpecialty']?.toString() ?? '',
      videoConsultationFee: (json['videoConsultationFee'] as num?)?.toDouble() ?? (json['consultationFee'] as num?)?.toDouble() ?? 499.0,
      isVerified: json['isVerified'] == true,
      verificationStatus: json['verificationStatus']?.toString() ?? (json['isVerified'] == true ? 'approved' : 'pending'),
      rejectionRemarks: json['rejectionRemarks']?.toString(),
      medicalCouncilCertUrl: json['medicalCouncilCertUrl']?.toString() ?? json['qualificationCertUrl']?.toString() ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      primaryDegreeCertUrl: json['primaryDegreeCertUrl']?.toString() ?? json['qualificationCertUrl']?.toString() ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      postGradCertUrl: json['postGradCertUrl']?.toString() ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      idProofUrl: json['idProofUrl']?.toString() ?? 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600',
      clinicAddressProofUrl: json['clinicAddressProofUrl']?.toString() ?? 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
      doctorSignatureUrl: json['doctorSignatureUrl']?.toString() ?? 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600',
      submittedAt: json['submittedAt']?.toString(),
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
      'email': email,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'collegeName': collegeName,
      'graduationYear': graduationYear,
      'postGradDegree': postGradDegree,
      'postGradCollege': postGradCollege,
      'postGradYear': postGradYear,
      'medicalLicenseNo': medicalLicenseNo,
      'stateMedicalCouncil': stateMedicalCouncil,
      'registrationYear': registrationYear,
      'licenseExpiryYear': licenseExpiryYear,
      'subSpecialty': subSpecialty,
      'videoConsultationFee': videoConsultationFee,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'rejectionRemarks': rejectionRemarks,
      'medicalCouncilCertUrl': medicalCouncilCertUrl,
      'primaryDegreeCertUrl': primaryDegreeCertUrl,
      'postGradCertUrl': postGradCertUrl,
      'idProofUrl': idProofUrl,
      'clinicAddressProofUrl': clinicAddressProofUrl,
      'doctorSignatureUrl': doctorSignatureUrl,
      'submittedAt': submittedAt,
    };
  }
}
