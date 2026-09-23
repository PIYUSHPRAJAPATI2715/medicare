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
}
