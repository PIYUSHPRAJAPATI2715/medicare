import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Appointment Tomorrow at 11:00 AM',
        'desc': 'Your video consultation with Dr. Vipin Kumar Jain is scheduled for tomorrow.',
        'time': '2 hours ago',
        'icon': Icons.videocam_rounded,
        'color': AppColors.primary,
        'unread': true,
      },
      {
        'title': 'Prescription Uploaded',
        'desc': 'Dr. Sandeep Kumar shared an e-prescription following your consultation.',
        'time': 'Yesterday',
        'icon': Icons.description_rounded,
        'color': AppColors.success,
        'unread': false,
      },
      {
        'title': 'Welcome to MediCare+!',
        'desc': 'Your Care Plan is now active with 12 free annual consultations.',
        'time': '3 days ago',
        'icon': Icons.favorite_rounded,
        'color': AppColors.secondary,
        'unread': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Notifications'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final unread = item['unread'] as bool;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                width: unread ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['time'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
