import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How does a video consultation work?',
        'a': 'After booking a video consultation slot, you will receive an in-app reminder. Tap "Join Consultation" from your Appointments screen to connect directly with the doctor via encrypted HD video stream.'
      },
      {
        'q': 'What happens if a doctor misses my appointment?',
        'a': 'In the rare event a doctor is delayed or unavailable, you will receive an automatic 100% refund to your original payment method or free immediate rescheduling.'
      },
      {
        'q': 'Are prescriptions from MediCare+ valid at local clinics?',
        'a': 'Yes, all digital prescriptions issued by licensed doctors on MediCare+ are legally valid across India in compliance with the Telemedicine Practice Guidelines.'
      },
      {
        'q': 'Can I consult in Hindi or regional languages?',
        'a': 'Yes, you can choose your preferred language during slot booking (English, Hindi, Marathi, Gujarati, etc.).'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Help & Support'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent_rounded, size: 36, color: AppColors.primary),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('24/7 Patient Helpdesk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryDark)),
                        SizedBox(height: 2),
                        Text('support@medicare.plus • 1800-200-8899', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            ...faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ExpansionTile(
                    title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['a']!, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
