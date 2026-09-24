enum UserRole {
  patient,
  doctor,
  admin,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String avatarUrl;
  final String? gender;
  final String? dob;
  final bool hasActiveCarePlan;
  
  // Doctor specific fields
  final String? specialization;
  final int? experienceYears;
  final String? clinicName;
  final String? registrationNumber;
  final bool isDoctorAvailable;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    this.gender = 'Male',
    this.dob = '15 Aug 1994',
    this.hasActiveCarePlan = false,
    this.specialization,
    this.experienceYears,
    this.clinicName,
    this.registrationNumber,
    this.isDoctorAvailable = true,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? gender,
    String? dob,
    bool? hasActiveCarePlan,
    String? specialization,
    int? experienceYears,
    String? clinicName,
    String? registrationNumber,
    bool? isDoctorAvailable,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      hasActiveCarePlan: hasActiveCarePlan ?? this.hasActiveCarePlan,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      clinicName: clinicName ?? this.clinicName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isDoctorAvailable: isDoctorAvailable ?? this.isDoctorAvailable,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.patient;
    final r = json['role']?.toString().toLowerCase();
    if (r == 'doctor') {
      parsedRole = UserRole.doctor;
    } else if (r == 'admin') {
      parsedRole = UserRole.admin;
    }

    return UserModel(
      id: json['id']?.toString() ?? 'u1',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: parsedRole,
      avatarUrl: json['avatarUrl']?.toString() ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      gender: json['gender']?.toString() ?? 'Male',
      dob: json['dob']?.toString() ?? '15 Aug 1994',
      hasActiveCarePlan: json['hasActiveCarePlan'] == true,
      specialization: json['specialization']?.toString() ?? json['specialty']?.toString(),
      experienceYears: json['experienceYears'] is num ? (json['experienceYears'] as num).toInt() : null,
      clinicName: json['clinicName']?.toString(),
      registrationNumber: json['registrationNumber']?.toString() ?? json['medicalLicenseNo']?.toString(),
      isDoctorAvailable: json['isDoctorAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'dob': dob,
      'hasActiveCarePlan': hasActiveCarePlan,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'clinicName': clinicName,
      'registrationNumber': registrationNumber,
      'isDoctorAvailable': isDoctorAvailable,
    };
  }
}
