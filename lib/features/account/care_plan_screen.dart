import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/subscription_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/api_service.dart';
import '../../services/razorpay_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../subscription/subscription_paywall_dialog.dart';

class CarePlanScreen extends ConsumerStatefulWidget {
  const CarePlanScreen({super.key});

  @override
  ConsumerState<CarePlanScreen> createState() => _CarePlanScreenState();
}

class _CarePlanScreenState extends ConsumerState<CarePlanScreen> {
  late RazorpayService _razorpayService;
  SubscriptionPlanModel? _pendingPlan;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final plan = _pendingPlan;
    if (plan == null) return;
    final currentUser = ref.read(authProvider).user;

    setState(() => _isProcessing = true);

    // 1. Record and verify payment in live admin database
    await ApiService.verifyPaymentSuccess(
      orderId: response.orderId ?? 'ORD-SUB-${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUser.id,
      amount: plan.price,
      paymentId: response.paymentId ?? 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: 'Razorpay UPI',
      purpose: 'Subscription: ${plan.name}',
      planId: plan.id,
      planName: plan.name,
      type: 'subscription',
    );

    // 2. Activate plan in subscription provider
    ref.read(subscriptionProvider.notifier).activatePlan(
      plan,
      paymentMethod: 'Razorpay (${response.paymentId ?? "Live"})',
    );

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _pendingPlan = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0E9F6E),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Payment Verified! ${plan.name} is now Active.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _pendingPlan = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text('Payment cancelled or failed: ${response.message ?? "Unknown error"}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _startRazorpayForPlan(SubscriptionPlanModel plan) {
    final currentUser = ref.read(authProvider).user;
    setState(() {
      _pendingPlan = plan;
      _isProcessing = true;
    });

    _razorpayService.openCheckout(
      amount: plan.price,
      name: plan.name,
      description: 'Care Plan: ${plan.name}',
      userEmail: currentUser.email,
      userPhone: currentUser.phone,
      userName: currentUser.name,
      userId: currentUser.id,
      planId: plan.id,
      planName: plan.name,
      purpose: 'Care Plan Subscription - ${plan.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final activePlan = subState.activePlan;
    final isSubscribed = subState.isSubscribed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'MediCare+ Care Plan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSubscribed && activePlan != null) ...[
              // Active Plan Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ACTIVE: ${activePlan.name.toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activePlan.isUnlimited
                          ? 'Unlimited Doctor Consultations'
                          : '${subState.remainingConsultations} Free Consultations Remaining',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.25),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activePlan.tagline,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Valid: ${activePlan.durationLabel}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        if (subState.expiresAt != null)
                          Text(
                            'Renews on ${DateFormat('dd MMM yyyy').format(subState.expiresAt!)}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Unsubscribed Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF334155), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NO ACTIVE SUBSCRIPTION',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Subscription Required for Consultations',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.25),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Without a subscription, video calls, audio calls, and doctor chat cannot be connected. Activate a plan to consult immediately.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => SubscriptionPaywallDialog(
                              onSubscribed: () {},
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Choose & Activate a Plan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              'Available Care Plans (Admin Managed)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            ...subState.availablePlans.map((plan) {
              final isCurrent = activePlan?.id == plan.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const Spacer(),
                        if (plan.badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plan.badgeText!,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.tagline,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '₹${plan.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${plan.originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Valid for ${plan.durationLabel}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!isCurrent)
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton(
                          onPressed: _isProcessing
                              ? null
                              : () => _startRazorpayForPlan(plan),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isProcessing && _pendingPlan?.id == plan.id
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  'Pay with Razorpay (₹${plan.price.toStringAsFixed(0)})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary),
                                ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF7EC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Current Active Plan',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0E9F6E),
                              fontSize: 13),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            const Text(
              'Care Plan Perks',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _perkTile(
              icon: Icons.video_call_rounded,
              title: 'Free 24/7 Agora HD Teleconsultations',
              subtitle:
                  'Connect with General Physicians and certified specialists at ₹0 additional fee.',
            ),
            _perkTile(
              icon: Icons.medication_rounded,
              title: '15% Off All Prescribed Medicines',
              subtitle:
                  'Order tablets straight to your doorstep with express 60-90 minute delivery.',
            ),
            _perkTile(
              icon: Icons.group_rounded,
              title: 'Family Coverage (Up to 4 Members)',
              subtitle:
                  'Add parents, spouse, or children under the same healthcare subscription.',
            ),
            _perkTile(
              icon: Icons.security_rounded,
              title: 'Free Digital Prescriptions & 7-Day Follow Ups',
              subtitle:
                  'Continue chat and follow-up reviews with your consultation doctor anytime.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _perkTile(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
