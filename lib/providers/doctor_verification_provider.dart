import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DoctorVerificationStatus {
  underReview,
  approved,
  rejected,
}

class DoctorApplicationModel {
  final String applicationId;
  final String fullName;
  final String email;
  final String phone;
  final String primaryDegree;
  final String? postGradDegree;
  final String councilName;
  final String licenseNumber;
  final String specialization;
  final String? clinicName;
  final int uploadedDocsCount;
  final DateTime submittedAt;
  final DoctorVerificationStatus status;
  final String? rejectionReason;
  final int estimatedHours;

  const DoctorApplicationModel({
    required this.applicationId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.primaryDegree,
    this.postGradDegree,
    required this.councilName,
    required this.licenseNumber,
    required this.specialization,
    this.clinicName,
    required this.uploadedDocsCount,
    required this.submittedAt,
    this.status = DoctorVerificationStatus.underReview,
    this.rejectionReason,
    this.estimatedHours = 24,
  });

  DoctorApplicationModel copyWith({
    String? applicationId,
    String? fullName,
    String? email,
    String? phone,
    String? primaryDegree,
    String? postGradDegree,
    String? councilName,
    String? licenseNumber,
    String? specialization,
    String? clinicName,
    int? uploadedDocsCount,
    DateTime? submittedAt,
    DoctorVerificationStatus? status,
    String? rejectionReason,
    int? estimatedHours,
  }) {
    return DoctorApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      primaryDegree: primaryDegree ?? this.primaryDegree,
      postGradDegree: postGradDegree ?? this.postGradDegree,
      councilName: councilName ?? this.councilName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
      clinicName: clinicName ?? this.clinicName,
      uploadedDocsCount: uploadedDocsCount ?? this.uploadedDocsCount,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      estimatedHours: estimatedHours ?? this.estimatedHours,
    );
  }
}

class DoctorVerificationState {
  final DoctorApplicationModel application;
  final bool isUnderReview;
  final bool isCheckingStatus;
  final DateTime? lastCheckedAt;

  const DoctorVerificationState({
    required this.application,
    this.isUnderReview = true,
    this.isCheckingStatus = false,
    this.lastCheckedAt,
  });

  DoctorVerificationState copyWith({
    DoctorApplicationModel? application,
    bool? isUnderReview,
    bool? isCheckingStatus,
    DateTime? lastCheckedAt,
  }) {
    return DoctorVerificationState(
      application: application ?? this.application,
      isUnderReview: isUnderReview ?? this.isUnderReview,
      isCheckingStatus: isCheckingStatus ?? this.isCheckingStatus,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

class DoctorVerificationNotifier extends Notifier<DoctorVerificationState> {
  @override
  DoctorVerificationState build() {
    // Default initial application in pending review
    return DoctorVerificationState(
      application: DoctorApplicationModel(
        applicationId: 'MED-DOC-77321',
        fullName: 'Dr. Vikramaditya Rathore',
        email: 'dr.rathore@medicareplus.com',
        phone: '+91 98290 12345',
        primaryDegree: 'MBBS (SMS Medical College)',
        postGradDegree: 'MD Internal Medicine',
        councilName: 'Rajasthan Medical Council',
        licenseNumber: 'RMC/2014/77321',
        specialization: 'General Physician',
        clinicName: 'Rathore Super-Specialty Clinic',
        uploadedDocsCount: 6,
        submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
        status: DoctorVerificationStatus.underReview,
      ),
      isUnderReview: true,
      lastCheckedAt: DateTime.now(),
    );
  }

  void submitApplication({
    required String applicationId,
    required String fullName,
    required String email,
    required String phone,
    required String primaryDegree,
    String? postGradDegree,
    required String councilName,
    required String licenseNumber,
    required String specialization,
    String? clinicName,
    required int uploadedDocsCount,
  }) {
    state = state.copyWith(
      application: DoctorApplicationModel(
        applicationId: applicationId,
        fullName: fullName,
        email: email,
        phone: phone,
        primaryDegree: primaryDegree,
        postGradDegree: postGradDegree,
        councilName: councilName,
        licenseNumber: licenseNumber,
        specialization: specialization,
        clinicName: clinicName,
        uploadedDocsCount: uploadedDocsCount,
        submittedAt: DateTime.now(),
        status: DoctorVerificationStatus.underReview,
      ),
      isUnderReview: true,
      lastCheckedAt: DateTime.now(),
    );
  }

  Future<void> refreshStatus() async {
    state = state.copyWith(isCheckingStatus: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(
      isCheckingStatus: false,
      lastCheckedAt: DateTime.now(),
    );
  }

  void simulateAdminApproval() {
    state = state.copyWith(
      application: state.application.copyWith(
        status: DoctorVerificationStatus.approved,
      ),
      isUnderReview: false,
      lastCheckedAt: DateTime.now(),
    );
  }

  void resetToUnderReview() {
    state = state.copyWith(
      application: state.application.copyWith(
        status: DoctorVerificationStatus.underReview,
      ),
      isUnderReview: true,
      lastCheckedAt: DateTime.now(),
    );
  }
}

final doctorVerificationProvider =
    NotifierProvider<DoctorVerificationNotifier, DoctorVerificationState>(
        DoctorVerificationNotifier.new);
