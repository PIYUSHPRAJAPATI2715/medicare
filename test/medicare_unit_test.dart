import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_plus/models/user_model.dart';
import 'package:medicare_plus/models/appointment_model.dart';
import 'package:medicare_plus/providers/auth_provider.dart';
import 'package:medicare_plus/providers/doctor_provider.dart';
import 'package:medicare_plus/providers/appointment_provider.dart';
import 'package:medicare_plus/providers/chat_provider.dart';
import 'package:medicare_plus/providers/wallet_provider.dart';
import 'package:medicare_plus/providers/prescription_provider.dart';
import 'package:medicare_plus/providers/doctor_verification_provider.dart';
import 'package:medicare_plus/models/wallet_model.dart';
import 'package:medicare_plus/models/prescription_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:medicare_plus/widgets/floating_bottom_nav.dart';
import 'package:medicare_plus/data/mock/mock_data.dart';
import 'package:medicare_plus/services/api_service.dart';

class _AllowRealHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _AllowRealHttpOverrides();
  });
  group('Auth & Role Switcher Tests', () {
    test('Default user starts as patient', () {
      final container = ProviderContainer();
      final auth = container.read(authProvider);
      expect(auth.user.role, UserRole.patient);
      expect(auth.user.name, 'Piyush Prajapati');
    });

    test('Can switch role to Doctor and Admin', () {
      final container = ProviderContainer();
      container.read(authProvider.notifier).switchRole(UserRole.doctor);
      expect(container.read(authProvider).user.role, UserRole.doctor);

      container.read(authProvider.notifier).switchRole(UserRole.admin);
      expect(container.read(authProvider).user.role, UserRole.admin);
    });

    test('Doctor availability can be toggled', () {
      final container = ProviderContainer();
      container.read(authProvider.notifier).switchRole(UserRole.doctor);
      final initial = container.read(authProvider).user.isDoctorAvailable;

      container.read(authProvider.notifier).toggleDoctorAvailability();
      expect(container.read(authProvider).user.isDoctorAvailable, !initial);
    });
  });

  group('Doctor Filtering Tests', () {
    test('Initial filtered list returns doctors', () {
      final container = ProviderContainer();
      final doctors = container.read(filteredDoctorsProvider);
      expect(doctors.isNotEmpty, true);
    });

    test('Filtering by specialty works', () {
      final container = ProviderContainer();
      container.read(doctorFilterProvider.notifier).setSpecialty('General Physician');
      final doctors = container.read(filteredDoctorsProvider);
      expect(doctors.every((d) => d.specialty.contains('General Physician')), true);
    });

    test('Instant vs Later separation works', () {
      final container = ProviderContainer();
      final instant = container.read(instantDoctorsProvider);
      final later = container.read(laterDoctorsProvider);
      expect(instant.every((d) => d.isOnline), true);
      expect(later.every((d) => !d.isOnline), true);
    });

    test('Search query filters doctors by name or symptoms', () {
      final container = ProviderContainer();
      container.read(doctorFilterProvider.notifier).setSearchQuery('Vipin');
      final doctors = container.read(filteredDoctorsProvider);
      expect(doctors.length, 1);
      expect(doctors.first.name.contains('Vipin'), true);
    });
  });

  group('Appointment Booking & Coupons Tests', () {
    test('Calculates booking total correctly with discount', () {
      final container = ProviderContainer();
      final doctor = MockData.doctors[0]; // Fee = 649

      container.read(appointmentProvider.notifier).startBooking(doctor, type: ConsultationType.video);
      final initialTotal = container.read(appointmentProvider).draft.totalAmount;
      expect(initialTotal, 649.0 + 49.0 + 18.0);

      // Apply coupon HEALTH50
      final applied = container.read(appointmentProvider.notifier).applyCoupon('HEALTH50');
      expect(applied, true);

      final discountedTotal = container.read(appointmentProvider).draft.totalAmount;
      expect(discountedTotal, initialTotal - 50.0);
    });

    test('Confirm booking adds to appointment list', () {
      final container = ProviderContainer();
      final initialCount = container.read(appointmentProvider).appointments.length;

      final confirmed = container.read(appointmentProvider.notifier).confirmBooking();
      expect(confirmed.status, AppointmentStatus.upcoming);
      expect(container.read(appointmentProvider).appointments.length, initialCount + 1);
    });
  });

  group('Chat Provider Tests', () {
    test('Can send message and appends to chat list', () {
      final container = ProviderContainer();
      final initialCount = container.read(chatProvider).messages.length;

      container.read(chatProvider.notifier).sendMessage('I need medical advice');
      final updatedMessages = container.read(chatProvider).messages;

      expect(updatedMessages.length, initialCount + 1);
      expect(updatedMessages.last.text, 'I need medical advice');
      expect(updatedMessages.last.isDoctor, false);
    });
  });

  group('FloatingBottomNav Widget Tests', () {
    testWidgets('Displays all 4 labels in column layout and supports switching', (tester) async {
      int selectedIndex = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return FloatingBottomNav(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // All 4 labels must always show simultaneously
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('In-Person'), findsOneWidget);
      expect(find.text('Video Consult'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      // Tap on Video Consult
      await tester.tap(find.text('Video Consult'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 2);

      // All 4 labels still show simultaneously after switching
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('In-Person'), findsOneWidget);
      expect(find.text('Video Consult'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });
  });

  group('HealthPay Wallet Tests', () {
    test('Initial wallet balance and details are configured', () {
      final container = ProviderContainer();
      final wallet = container.read(walletProvider);
      expect(wallet.balance > 0, true);
      expect(wallet.healthCashback > 0, true);
      expect(wallet.transactions.isNotEmpty, true);
    });

    test('addMoney loads funds and records transaction', () {
      final container = ProviderContainer();
      final initialBalance = container.read(walletProvider).balance;

      container.read(walletProvider.notifier).addMoney(500.0, 'UPI');
      final updated = container.read(walletProvider);

      expect(updated.balance, initialBalance + 500.0);
      expect(updated.transactions.first.amount, 500.0);
      expect(updated.transactions.first.isCredit, true);
    });

    test('payWithWallet deducts balance, awards 5% cashback, and checks insufficient balance', () {
      final container = ProviderContainer();
      final initialBalance = container.read(walletProvider).balance;

      // 1. Successful payment
      final success = container.read(walletProvider.notifier).payWithWallet(
            200.0,
            'Dr. Consultation',
            category: WalletTransactionCategory.consultation,
          );
      expect(success, true);

      // Cashback is 5% of 200 = 10. Net balance change = -200 + 10 = -190
      final currentBalance = container.read(walletProvider).balance;
      expect(currentBalance, initialBalance - 200.0 + 10.0);

      // 2. Failed payment with excess amount
      final failed = container.read(walletProvider.notifier).payWithWallet(
            999999.0,
            'Excessive charge',
            category: WalletTransactionCategory.consultation,
          );
      expect(failed, false);
    });
  });

  group('Prescription Lifecycle & Doctor Rx Writer Tests', () {
    test('Prescription provider contains default prescriptions', () {
      final container = ProviderContainer();
      final rxList = container.read(prescriptionProvider).prescriptions;
      expect(rxList.isNotEmpty, true);
    });

    test('Start consultation pending Rx registers drafting status', () {
      final container = ProviderContainer();
      final doctor = MockData.doctors.first;

      container.read(prescriptionProvider.notifier).startConsultationPendingRx(doctor);

      final state = container.read(prescriptionProvider);
      expect(state.pendingDrafts.containsKey(doctor.id), true);
      expect(state.lastNotificationMessage?.contains('drafting'), true);
    });

    test('Doctor submits prescription, moving lifecycle to issued with medicines and token', () {
      final container = ProviderContainer();
      final doctor = MockData.doctors.first;

      container.read(prescriptionProvider.notifier).startConsultationPendingRx(doctor);

      final issuedRx = container.read(prescriptionProvider.notifier).submitDoctorPrescription(
            doctor: doctor,
            diagnosis: 'Acute Bronchitis',
            clinicalNotes: 'Patient exhibits wheezing and mild cough.',
            adviceNotes: 'Hydration and rest.',
            followUpDate: DateTime.now().add(const Duration(days: 7)),
            medicines: [
              const PrescribedMedicine(
                id: 'med_test_1',
                name: 'Amoxicillin 500mg',
                genericName: 'Amoxicillin Trihydrate',
                dosage: '1 capsule',
                frequency: 'Thrice a day',
                instructions: 'After meals',
                durationDays: 5,
                unitPrice: 12.0,
                quantity: 15,
              ),
            ],
          );

      expect(issuedRx.status, PrescriptionLifecycleStatus.issued);
      expect(issuedRx.diagnosis, 'Acute Bronchitis');
      expect(issuedRx.medicines.length, 1);
      expect(issuedRx.digitalSignatureToken.isNotEmpty, true);

      // Verify it is in state.prescriptions
      final state = container.read(prescriptionProvider);
      expect(state.prescriptions.any((rx) => rx.id == issuedRx.id), true);
    });

    test('placePharmacyOrder updates fulfillment type and pharmacy order status', () {
      final container = ProviderContainer();
      final rxList = container.read(prescriptionProvider).prescriptions;
      final targetRx = rxList.first;

      container.read(prescriptionProvider.notifier).placePharmacyOrder(
            targetRx.id,
            address: 'Flat 402, Sunshine Heights, Mumbai',
          );

      final updatedRx = container.read(prescriptionProvider).prescriptions.firstWhere((p) => p.id == targetRx.id);
      expect(updatedRx.fulfillmentType, OrderFulfillmentType.orderedOnline);
      expect(updatedRx.pharmacyStatus, PharmacyOrderStatus.placed);
      expect(updatedRx.deliveryAddress, 'Flat 402, Sunshine Heights, Mumbai');
    });
  });

  group('Doctor Verification & Review Lifecycle Tests', () {
    test('Default doctor state is under review with initial application', () {
      final container = ProviderContainer();
      final state = container.read(doctorVerificationProvider);
      expect(state.isUnderReview, true);
      expect(state.application.status, DoctorVerificationStatus.underReview);
      expect(state.application.applicationId.isNotEmpty, true);
    });

    test('Submitting application sets details and maintains under review state', () {
      final container = ProviderContainer();
      container.read(doctorVerificationProvider.notifier).submitApplication(
            applicationId: 'MED-DOC-99881',
            fullName: 'Dr. Ananya Roy',
            email: 'ananya@medicare.com',
            phone: '+91 91234 56789',
            primaryDegree: 'MBBS (AIIMS New Delhi)',
            postGradDegree: 'MD Cardiology',
            councilName: 'Delhi Medical Council',
            licenseNumber: 'DMC/2016/54321',
            specialization: 'Cardiologist',
            clinicName: 'Heart Health Clinic',
            uploadedDocsCount: 6,
          );

      final state = container.read(doctorVerificationProvider);
      expect(state.isUnderReview, true);
      expect(state.application.applicationId, 'MED-DOC-99881');
      expect(state.application.fullName, 'Dr. Ananya Roy');
      expect(state.application.licenseNumber, 'DMC/2016/54321');
      expect(state.application.uploadedDocsCount, 6);
      expect(state.application.status, DoctorVerificationStatus.underReview);
    });

    test('Simulating admin approval marks doctor approved and enables dashboard access', () {
      final container = ProviderContainer();
      container.read(doctorVerificationProvider.notifier).simulateAdminApproval();

      final state = container.read(doctorVerificationProvider);
      expect(state.isUnderReview, false);
      expect(state.application.status, DoctorVerificationStatus.approved);

      // Can reset back to review
      container.read(doctorVerificationProvider.notifier).resetToUnderReview();
      final resetState = container.read(doctorVerificationProvider);
      expect(resetState.isUnderReview, true);
      expect(resetState.application.status, DoctorVerificationStatus.underReview);
    });
  });

  group('Dynamic REST API Integration Tests', () {
    test('Plans API returns active subscription models', () async {
      final plans = await ApiService.fetchPlans();
      expect(plans.isNotEmpty, true);
      expect(plans.any((p) => p.name.contains('Care')), true);
    });

    test('Diseases API returns health conditions mapped to specialties', () async {
      final diseases = await ApiService.fetchDiseases();
      expect(diseases.isNotEmpty, true);
      expect(diseases.any((d) => d.specialty.isNotEmpty), true);
    });

    test('Doctor Status API returns verification details', () async {
      final status = await ApiService.getDoctorStatus('d1');
      expect(status['success'], true);
      expect(status['data']['isVerified'], true);
    });

    test('Pending Doctor verification API flags under review', () async {
      final status = await ApiService.getDoctorStatus('d5');
      expect(status['success'], true);
      expect(status['data']['status'], 'pending');
    });

    test('Auth provider delete account completes', () async {
      final container = ProviderContainer();
      final deleted = await container.read(authProvider.notifier).deleteAccount();
      expect(deleted, true);
      expect(container.read(authProvider).isAuthenticated, false);
    });
  });
}

