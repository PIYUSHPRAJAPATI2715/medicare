import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_verification_provider.dart';

class DoctorVerificationStatusScreen extends ConsumerWidget {
  const DoctorVerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationState = ref.watch(doctorVerificationProvider);
    final app = verificationState.application;
    final isApproved = app.status == DoctorVerificationStatus.approved;
    final submittedFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(app.submittedAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Verification Status',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                size: 20, color: AppColors.textSecondary),
            tooltip: 'Return to Login',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------------
              // 1. HERO STATUS CARD
              // -------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isApproved
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFFDE68A),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isApproved
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706))
                          .withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isApproved
                              ? Icons.verified_user_rounded
                              : Icons.hourglass_top_rounded,
                          color: isApproved
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isApproved
                          ? 'Profile Verified & Active'
                          : 'Profile Under Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isApproved
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB45309),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Application ID: ${app.applicationId}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isApproved
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isApproved
                          ? 'Your medical credentials have been approved by the Credentialing Board. You can now access your doctor dashboard and attend consultations.'
                          : 'Your medical credentials, degree certificates, and council licenses are currently under audit by our medical verification board.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isApproved
                            ? const Color(0xFF166534)
                            : const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 2. SLA NOTICE (24-48 HOURS)
              // -------------------------------------------------------------
              if (!isApproved)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 20, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Standard Verification SLA: 24 to 48 Hours',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'You will receive an SMS and email notification immediately once your registration is approved.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 3. VERIFICATION PROGRESS TIMELINE
              // -------------------------------------------------------------
              const Text(
                'Verification Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildTimelineStep(
                      stepNumber: 1,
                      title: 'Application & Credentials Submitted',
                      subtitle: 'Submitted on $submittedFormatted',
                      isCompleted: true,
                      isActive: false,
                    ),
                    _buildTimelineDivider(isCompleted: true),
                    _buildTimelineStep(
                      stepNumber: 2,
                      title: 'State Medical Council & NMC License Audit',
                      subtitle: isApproved
                          ? 'Registration number verified with NMC database'
                          : 'Validating registration with ${app.councilName}',
                      isCompleted: isApproved,
                      isActive: !isApproved,
                    ),
                    _buildTimelineDivider(isCompleted: isApproved),
                    _buildTimelineStep(
                      stepNumber: 3,
                      title: 'Medical Degree & Identity Proof Inspection',
                      subtitle: isApproved
                          ? '${app.uploadedDocsCount} documents verified and approved'
                          : 'Auditing ${app.uploadedDocsCount} uploaded degree and ID documents',
                      isCompleted: isApproved,
                      isActive: false,
                    ),
                    _buildTimelineDivider(isCompleted: isApproved),
                    _buildTimelineStep(
                      stepNumber: 4,
                      title: 'Telemedicine Practice License Grant',
                      subtitle: isApproved
                          ? 'Active — Ready for consultations & e-prescriptions'
                          : 'Pending final medical superintendent sign-off',
                      isCompleted: isApproved,
                      isActive: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 4. SUBMITTED CREDENTIALS SUMMARY
              // -------------------------------------------------------------
              const Text(
                'Submitted Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Applicant Name', app.fullName),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow('Registered Email', app.email),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow('Contact Phone', app.phone),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow('Medical Council', app.councilName),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow('License Reg. No.', app.licenseNumber),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow('Specialization', app.specialization),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                        'Attached Files', '${app.uploadedDocsCount} Documents'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 5. REGULATORY POLICY NOTE
              // -------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'In compliance with National Medical Commission (NMC) regulations, all practitioner credentials must undergo manual audit before granting digital consultation and prescription access.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // -------------------------------------------------------------
              // 6. ACTION BUTTONS
              // -------------------------------------------------------------
              if (isApproved) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ref.read(authProvider.notifier).loginAsDoctor();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.doctorDashboard,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Enter Doctor Dashboard',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Refresh / Check Status Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: verificationState.isCheckingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh_rounded,
                          size: 19, color: Colors.white),
                  label: Text(
                    verificationState.isCheckingStatus
                        ? 'Checking Credentialing Database...'
                        : 'Check Verification Status',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: verificationState.isCheckingStatus
                      ? null
                      : () async {
                          await ref
                              .read(doctorVerificationProvider.notifier)
                              .refreshStatus();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isApproved
                                    ? 'Your account is approved and active!'
                                    : 'Profile is still undergoing verification. Please check back later.'),
                                backgroundColor: isApproved
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                ),
              ),
              const SizedBox(height: 12),

              // Back to Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 7. TESTING / SIMULATION SHORTCUT (Allows testing approval flow)
              // -------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Audit Simulation',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                          ),
                          Text(
                            isApproved
                                ? 'Currently simulated as Approved'
                                : 'Currently simulated as Under Review',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (isApproved) {
                          ref
                              .read(doctorVerificationProvider.notifier)
                              .resetToUnderReview();
                        } else {
                          ref
                              .read(doctorVerificationProvider.notifier)
                              .simulateAdminApproval();
                        }
                      },
                      child: Text(
                        isApproved ? 'Reset to Review' : 'Simulate Approval',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Support Footer
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.headset_mic_outlined,
                      size: 16, color: AppColors.textSecondary),
                  label: const Text(
                    'Need Help? Contact Credentialing Desk',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Credentialing Support Desk',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email: credentials@medicareplus.com\n'
                              'Toll-Free: 1800-200-MEDICARE\n'
                              'Hours: Monday – Saturday (09:00 AM – 08:00 PM IST)',
                              style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF16A34A)
                : (isActive ? const Color(0xFFD97706) : const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : (isActive
                    ? const Icon(Icons.hourglass_empty_rounded,
                        size: 13, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      )),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCompleted || isActive
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isActive
                      ? const Color(0xFFD97706)
                      : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider({required bool isCompleted}) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      height: 18,
      width: 2,
      color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
    );
  }
}
