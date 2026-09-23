import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/wallet_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/app_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'wallet';
  bool _isProcessing = false;

  void _handlePayment() async {
    final appointmentState = ref.read(appointmentProvider);
    final draft = appointmentState.draft;
    final doctor = draft.doctor;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    if (_selectedMethod == 'wallet') {
      final success = ref.read(walletProvider.notifier).payWithWallet(
        draft.totalAmount,
        'Consultation: ${doctor?.name ?? "Doctor"}',
        category: WalletTransactionCategory.consultation,
        referenceId: 'APPT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      );
      if (!success) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient Wallet balance. Please top up or choose another payment method.')),
        );
        return;
      }
    }

    setState(() => _isProcessing = false);

    ref.read(appointmentProvider.notifier).confirmBooking();
    Navigator.of(context).pushReplacementNamed(AppRoutes.appointmentConfirmation);
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);
    final wallet = ref.watch(walletProvider);
    final draft = appointmentState.draft;
    final doctor = draft.doctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Payment Summary'),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: AppButton(
          text: 'Pay ₹${draft.totalAmount.toStringAsFixed(2)} & Book',
          isLoading: _isProcessing,
          onPressed: _handlePayment,
          height: 50,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Summary',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Doctor', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(doctor?.name ?? 'Dr. Specialist', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Slot', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(draft.selectedSlot, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(draft.type.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _paymentOptionTile(
              id: 'wallet',
              title: 'MediCare+ HealthPay Wallet',
              subtitle: 'Balance: ₹${wallet.balance.toStringAsFixed(0)} • Instant 1-Tap Pay',
              icon: Icons.account_balance_wallet_rounded,
              isRecommended: true,
            ),
            _paymentOptionTile(
              id: 'upi_gpay',
              title: 'Google Pay / PhonePe / BHIM UPI',
              subtitle: 'Pay directly using any installed UPI App',
              icon: Icons.qr_code_rounded,
            ),
            _paymentOptionTile(
              id: 'card',
              title: 'Credit / Debit Cards',
              subtitle: 'Visa, MasterCard, RuPay, Maestro',
              icon: Icons.credit_card_rounded,
            ),
            _paymentOptionTile(
              id: 'netbanking',
              title: 'Net Banking',
              subtitle: 'All Indian major banks supported',
              icon: Icons.account_balance_rounded,
            ),
            _paymentOptionTile(
              id: 'careplan',
              title: 'MediCare+ Care Plan',
              subtitle: '12 Free Annual Consultations (Active)',
              icon: Icons.health_and_safety_rounded,
              isRecommended: true,
            ),

            const SizedBox(height: 20),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  const Text(
                    '256-Bit SSL Encrypted & RBI Compliant Gateway',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRecommended) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('FREE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                ),
              ],
            ],
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary)),
          trailing: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 6 : 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
