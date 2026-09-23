import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/prescription_model.dart';
import '../../models/wallet_model.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/wallet_provider.dart';

class PharmacyCheckoutScreen extends ConsumerStatefulWidget {
  final PrescriptionModel prescription;

  const PharmacyCheckoutScreen({
    super.key,
    required this.prescription,
  });

  @override
  ConsumerState<PharmacyCheckoutScreen> createState() =>
      _PharmacyCheckoutScreenState();
}

class _PharmacyCheckoutScreenState
    extends ConsumerState<PharmacyCheckoutScreen> {
  final TextEditingController _addressController = TextEditingController(
    text: 'Flat 402, Sunshine Heights, Malviya Nagar, Jaipur, Rajasthan - 302017',
  );
  int _selectedPaymentMethod = 0; // 0: UPI, 1: Cash on Delivery, 2: Cards
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rx = widget.prescription;
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Pharmacy Checkout',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Express delivery header banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFFBBF24), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Express Doorstep Delivery (60-90 Mins)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dispatched from Apollo / Fortis Partner Pharmacy',
                          style: TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Delivery Address card
            _sectionHeader(Icons.location_on_rounded, 'Delivery Address'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      labelText: 'House / Street / Area / Pincode',
                    ),
                  ),
                  const Divider(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Deliver to Piyush Prajapati (+91 98765 43210)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Medicines in order
            _sectionHeader(Icons.medication_rounded, 'Prescribed Tablets & Medicines'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ...rx.medicines.map((med) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${med.quantity} ${med.unit} • ${med.dosage}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${med.unitPrice.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment method selection
            _sectionHeader(Icons.payment_rounded, 'Payment Option'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _paymentTile(
                      0,
                      'MediCare+ HealthPay Wallet (₹${wallet.balance.toStringAsFixed(0)} available)',
                      Icons.account_balance_wallet_rounded),
                  const Divider(height: 1),
                  _paymentTile(1, 'UPI (Google Pay, PhonePe, Paytm)',
                      Icons.qr_code_rounded),
                  const Divider(height: 1),
                  _paymentTile(
                      2, 'Cash on Delivery (Pay at Doorstep)', Icons.money_rounded),
                  const Divider(height: 1),
                  _paymentTile(3, 'Credit / Debit Cards & Netbanking',
                      Icons.credit_card_rounded),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bill Breakdown
            _sectionHeader(Icons.receipt_long_rounded, 'Bill Summary'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _priceRow('Medicines Total',
                      '₹${rx.totalMedicineCost.toStringAsFixed(1)}'),
                  const SizedBox(height: 6),
                  _priceRow(
                    'MediCare Care Plan Discount (15%)',
                    '-₹${rx.discountAmount.toStringAsFixed(1)}',
                    textColor: const Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 6),
                  _priceRow(
                    'Express Delivery Charges',
                    'FREE',
                    textColor: const Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                  ),
                  const Divider(height: 16),
                  _priceRow(
                    'Total Payable',
                    '₹${rx.finalAmount.toStringAsFixed(1)}',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isPlacingOrder
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() {
                          _isPlacingOrder = true;
                        });

                        await Future.delayed(
                            const Duration(milliseconds: 700));

                        if (!mounted) return;

                        if (_selectedPaymentMethod == 0) {
                          final paid = ref.read(walletProvider.notifier).payWithWallet(
                                rx.finalAmount,
                                'Medicines Order: ${rx.id}',
                                category: WalletTransactionCategory.pharmacy,
                                referenceId: rx.id,
                              );
                          if (!paid) {
                            setState(() => _isPlacingOrder = false);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Insufficient Wallet balance. Please add money or choose another payment method.'),
                              ),
                            );
                            return;
                          }
                        }

                        ref
                            .read(prescriptionProvider.notifier)
                            .placePharmacyOrder(
                              rx.id,
                              address: _addressController.text.trim(),
                            );

                        if (!mounted) return;
                        setState(() {
                          _isPlacingOrder = false;
                        });

                        if (mounted) {
                          _showOrderSuccessSheet(rx);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Place Pharmacy Order (₹${rx.finalAmount.toStringAsFixed(0)})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text(
                '100% Genuine Medicines • Sealed Packets with Batch Expiry Verification',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _paymentTile(int index, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == index;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    Color? textColor,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showOrderSuccessSheet(PrescriptionModel rx) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFDEF7EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF0E9F6E),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pharmacy Order Confirmed!',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Order ID: MED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your prescribed tablets are being packed by partner pharmacy and will arrive in 60-90 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close sheet
                    Navigator.pop(context); // Close checkout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Track Order in Prescriptions',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
