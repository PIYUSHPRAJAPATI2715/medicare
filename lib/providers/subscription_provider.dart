import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_plan_model.dart';
import 'auth_provider.dart';

class SubscriptionState {
  final List<SubscriptionPlanModel> availablePlans;
  final SubscriptionPlanModel? activePlan;
  final DateTime? subscribedAt;
  final DateTime? expiresAt;
  final int remainingConsultations;
  final bool isLoading;

  const SubscriptionState({
    required this.availablePlans,
    this.activePlan,
    this.subscribedAt,
    this.expiresAt,
    this.remainingConsultations = 0,
    this.isLoading = false,
  });

  bool get isSubscribed {
    if (activePlan == null) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    return true;
  }

  SubscriptionState copyWith({
    List<SubscriptionPlanModel>? availablePlans,
    SubscriptionPlanModel? activePlan,
    bool clearActivePlan = false,
    DateTime? subscribedAt,
    DateTime? expiresAt,
    int? remainingConsultations,
    bool? isLoading,
  }) {
    return SubscriptionState(
      availablePlans: availablePlans ?? this.availablePlans,
      activePlan: clearActivePlan ? null : (activePlan ?? this.activePlan),
      subscribedAt: clearActivePlan ? null : (subscribedAt ?? this.subscribedAt),
      expiresAt: clearActivePlan ? null : (expiresAt ?? this.expiresAt),
      remainingConsultations:
          remainingConsultations ?? this.remainingConsultations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const List<SubscriptionPlanModel> defaultAdminPlans = [
    SubscriptionPlanModel(
      id: 'plan_starter',
      name: 'Starter Care Pass',
      tagline: 'Ideal for immediate doctor consultation & quick recovery',
      price: 199.0,
      originalPrice: 499.0,
      durationDays: 30,
      durationLabel: '1 Month',
      consultationLimit: 3,
      isPopular: false,
      badgeText: 'AFFORDABLE',
      colorHex: 0xFF2B5B84,
      features: [
        '3 Video or Audio Consultations with top doctors',
        '24/7 Unlimited Doctor Chat & Follow-ups',
        'Official Digital Prescriptions with instant download',
        '10% Flat Discount on all pharmacy tablet orders',
        'Free home medicine delivery on orders above ₹199',
      ],
    ),
    SubscriptionPlanModel(
      id: 'plan_gold',
      name: 'Gold Family Shield',
      tagline: 'Complete year-round coverage for up to 4 family members',
      price: 699.0,
      originalPrice: 1999.0,
      durationDays: 180,
      durationLabel: '6 Months',
      consultationLimit: -1, // Unlimited
      isPopular: true,
      badgeText: 'MOST POPULAR',
      colorHex: 0xFFD97706, // Amber/Gold
      features: [
        'Unlimited 24/7 Video & Audio Consultations',
        'Direct connection to MD Specialists & Super-specialists',
        'Family coverage for up to 4 family profiles',
        'Instant Electronic Rx with Priority Pharmacy Dispatch',
        '20% Off all prescribed tablets & medicines',
        'Priority 2-hour doorstep tablet delivery',
        '₹0 Convenience fees on all appointments',
      ],
    ),
    SubscriptionPlanModel(
      id: 'plan_platinum',
      name: 'Platinum 365 SuperCare',
      tagline: 'Premium VIP medical access, full health checkups & 1-year coverage',
      price: 1299.0,
      originalPrice: 3499.0,
      durationDays: 365,
      durationLabel: '1 Year',
      consultationLimit: -1, // Unlimited
      isPopular: false,
      badgeText: 'BEST VALUE',
      colorHex: 0xFF0D9488, // Teal
      features: [
        'Unlimited Consultations for the entire year (365 Days)',
        'Full Comprehensive Annual Health Checkup Included (62 Tests)',
        'VIP Priority Doctor Routing within 60 seconds',
        'Dedicated Personal Health Care Manager',
        '25% Off on all prescribed medicines & diagnostic tests',
        'Free doorstep sample collection & free express delivery',
      ],
    ),
  ];

  @override
  SubscriptionState build() {
    return const SubscriptionState(
      availablePlans: defaultAdminPlans,
      activePlan: null, // Unsubscribed by default as requested
      remainingConsultations: 0,
    );
  }

  /// Activate a subscription plan for the patient
  void activatePlan(SubscriptionPlanModel plan) {
    final now = DateTime.now();
    final expiry = now.add(Duration(days: plan.durationDays));
    
    state = state.copyWith(
      activePlan: plan,
      subscribedAt: now,
      expiresAt: expiry,
      remainingConsultations: plan.isUnlimited ? 9999 : plan.consultationLimit,
    );

    // Also sync with AuthState so UserModel hasActiveCarePlan becomes true
    final authNotifier = ref.read(authProvider.notifier);
    final currentUser = ref.read(authProvider).user;
    authNotifier.updateProfile(
      name: currentUser.name,
      phone: currentUser.phone,
    );
  }

  /// Use a consultation credit if limited
  void useConsultation() {
    if (state.activePlan != null && !state.activePlan!.isUnlimited) {
      if (state.remainingConsultations > 0) {
        state = state.copyWith(
          remainingConsultations: state.remainingConsultations - 1,
        );
      }
    }
  }

  /// Update admin configured plans
  void updatePlans(List<SubscriptionPlanModel> plans) {
    state = state.copyWith(availablePlans: plans);
  }

  /// Cancel current plan
  void cancelSubscription() {
    state = state.copyWith(clearActivePlan: true);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
        SubscriptionNotifier.new);
