import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_plus/models/user_model.dart';
import 'package:medicare_plus/models/appointment_model.dart';
import 'package:medicare_plus/providers/auth_provider.dart';
import 'package:medicare_plus/providers/doctor_provider.dart';
import 'package:medicare_plus/providers/appointment_provider.dart';
import 'package:medicare_plus/providers/chat_provider.dart';
import 'package:medicare_plus/data/mock/mock_data.dart';

void main() {
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
}
