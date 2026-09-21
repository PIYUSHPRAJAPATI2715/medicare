import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onJoinConsultation;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onJoinConsultation,
    this.onReschedule,
    this.onCancel,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final doc = appointment.doctor;
    final dateStr = DateFormat('dd MMM yyyy').format(appointment.date);
    final isUpcoming = appointment.status == AppointmentStatus.upcoming;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    Color statusColor;
    Color statusBgColor;
    String statusLabel;

    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        statusColor = AppColors.primary;
        statusBgColor = AppColors.primaryLight;
        statusLabel = 'Upcoming';
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.success;
        statusBgColor = AppColors.successLight;
        statusLabel = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.error;
        statusBgColor = AppColors.errorLight;
        statusLabel = 'Cancelled';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    doc.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doc.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            appointment.type == ConsultationType.video
                                ? Icons.videocam_rounded
                                : Icons.apartment_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.typeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        appointment.timeSlot,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${appointment.fee.toInt()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            if (isUpcoming) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  if (appointment.type == ConsultationType.video && onJoinConsultation != null) ...[
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: onJoinConsultation,
                        icon: const Icon(Icons.videocam_rounded, size: 18),
                        label: const Text('Join Consultation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onReschedule != null)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: onReschedule,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Reschedule', style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                  if (onCancel != null && !isCancelled) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                      tooltip: 'Cancel Appointment',
                    ),
                  ],
                ],
              ),
            ] else if (onViewDetails != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('View Summary & Prescription', style: TextStyle(fontSize: 12.5)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
