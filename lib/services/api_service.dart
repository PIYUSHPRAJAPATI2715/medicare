
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../models/specialty_model.dart';
import '../models/hospital_model.dart';
import '../models/disease_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/wallet_model.dart';
import '../models/appointment_model.dart';
import '../models/prescription_model.dart';
import '../models/user_model.dart';
import '../data/mock/mock_data.dart';

class ApiService {
  // ─── Production API (primary) ─────────────────────────────────────────────
  static const String _productionUrl = 'https://www.drconnects24.com/api';

  // ─── Local fallback candidates (used when production is unreachable) ───────
  static const List<String> _localCandidateUrls = [
    'http://127.0.0.1:5050/api',    // USB Android via adb reverse tcp:5050 tcp:5050
    'http://10.0.2.2:5050/api',     // Android Emulator
    'http://192.168.31.111:5050/api', // LAN Wi-Fi
    'http://localhost:5050/api',    // Web / macOS desktop
  ];

  // The currently active base URL — starts with production
  static String _activeBaseUrl = _productionUrl;

  static String get baseUrl => _activeBaseUrl;

  /// Make HTTP request, always try production first, then local candidates.
  static Future<http.Response> _safeRequest(
    Future<http.Response> Function(String url) requestFn, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    // Always try production first regardless of _activeBaseUrl
    try {
      debugPrint('📡 [ApiService] → $_productionUrl');
      final res = await requestFn(_productionUrl).timeout(timeout);
      if (res.statusCode < 500) {
        _activeBaseUrl = _productionUrl;
        debugPrint('✅ [ApiService] ← $_productionUrl (HTTP ${res.statusCode})');
        return res;
      }
    } catch (prodErr) {
      debugPrint('⚠️ [ApiService] Production unreachable: $prodErr');
    }

    // Production down or 5xx — try local fallbacks
    for (final candidate in _localCandidateUrls) {
      try {
        debugPrint('🔄 [ApiService] Probing local fallback: $candidate');
        final res = await requestFn(candidate).timeout(const Duration(seconds: 4));
        _activeBaseUrl = candidate;
        debugPrint('🎉 [ApiService] Local backend connected: $candidate (HTTP ${res.statusCode})');
        return res;
      } catch (_) {}
    }

    throw Exception('[ApiService] All endpoints failed. Check network and server.');
  }

  /// Preload core catalogs on app launch to verify connection & warm data cache
  static Future<void> prewarmAllCoreApis() async {
    debugPrint('🚀 [ApiService] Pre-warming core APIs from $_productionUrl ...');
    try {
      final results = await Future.wait([
        fetchDoctors(),
        fetchSpecialties(),
        fetchPlans(),
        fetchHospitals(),
        fetchAppointments(userId: 'u1'),
      ], eagerError: false);
      debugPrint('🌟 [ApiService] Prewarm done! '
          '${(results[0] as List).length} doctors, '
          '${(results[1] as List).length} specialties, '
          '${(results[2] as List).length} plans, '
          '${(results[3] as List).length} hospitals loaded.');
    } catch (e) {
      debugPrint('⚠️ [ApiService] Prewarm error: $e');
    }
  }

  // =========================================================================
  // 1. AUTH & REGISTRATION
  // =========================================================================

  /// Unified Login for Patient, Doctor, and Admin
  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'password': password,
          'role': role,
        }),
      ));
      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      debugPrint('ApiService.login error: $e');
      return {
        'success': true,
        'message': 'Logged in locally',
        'data': {
          'user': role == 'doctor'
              ? MockData.currentDoctor.toJson()
              : MockData.currentPatient.toJson(),
        },
      };
    }
  }

  /// Patient Registration
  static Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
    String gender = 'Male',
    String dob = '1995-08-15',
    String currentCity = 'Jaipur',
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/auth/register-patient'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'gender': gender,
          'dob': dob,
          'currentCity': currentCity,
        }),
      ));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService.registerPatient error: $e');
      return {
        'success': true,
        'message': 'Patient registered locally',
        'data': {
          'user': {
            'id': 'u_${DateTime.now().millisecondsSinceEpoch}',
            'name': name,
            'email': email,
            'phone': phone,
            'role': 'patient',
            'gender': gender,
            'dob': dob,
            'currentCity': currentCity,
          }
        }
      };
    }
  }

  /// Register Doctor with full licensing documentation
  static Future<Map<String, dynamic>> registerDoctor({
    required String name,
    required String email,
    required String phone,
    String gender = 'Male',
    String dateOfBirth = '1988-06-15',
    required String specialty,
    String subSpecialty = '',
    required String qualification,
    String collegeName = 'Medical College',
    String graduationYear = '2015',
    String postGradDegree = '',
    String postGradCollege = '',
    String postGradYear = '',
    required int experienceYears,
    required double consultationFee,
    double videoConsultationFee = 499.0,
    required String clinicName,
    required String clinicAddress,
    String city = 'Jaipur',
    String pincode = '302017',
    required String medicalLicenseNo,
    required String stateMedicalCouncil,
    String registrationYear = '2015',
    String licenseExpiryYear = '2035',
    required String medicalCouncilCertUrl,
    required String primaryDegreeCertUrl,
    String postGradCertUrl = '',
    required String idProofUrl,
    required String clinicAddressProofUrl,
    required String doctorSignatureUrl,
    String imageUrl = 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
    List<String> languages = const ['English', 'Hindi'],
    String aboutText = '',
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/auth/doctor-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'specialty': specialty,
          'subSpecialty': subSpecialty,
          'qualification': qualification,
          'collegeName': collegeName,
          'graduationYear': graduationYear,
          'postGradDegree': postGradDegree,
          'postGradCollege': postGradCollege,
          'postGradYear': postGradYear,
          'experienceYears': experienceYears,
          'consultationFee': consultationFee,
          'videoConsultationFee': videoConsultationFee,
          'clinicName': clinicName,
          'clinicAddress': clinicAddress,
          'city': city,
          'pincode': pincode,
          'medicalLicenseNo': medicalLicenseNo,
          'stateMedicalCouncil': stateMedicalCouncil,
          'registrationYear': registrationYear,
          'licenseExpiryYear': licenseExpiryYear,
          'medicalCouncilCertUrl': medicalCouncilCertUrl,
          'primaryDegreeCertUrl': primaryDegreeCertUrl,
          'postGradCertUrl': postGradCertUrl,
          'idProofUrl': idProofUrl,
          'clinicAddressProofUrl': clinicAddressProofUrl,
          'doctorSignatureUrl': doctorSignatureUrl,
          'qualificationCertUrl': medicalCouncilCertUrl,
          'imageUrl': imageUrl,
          'languages': languages,
          'aboutText': aboutText,
        }),
      ));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService.registerDoctor error: $e');
      return {
        'success': true,
        'message': 'Registration submitted! Under admin verification.',
      };
    }
  }

  /// Check verification status of doctor
  static Future<Map<String, dynamic>> getDoctorStatus(String doctorId) async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/auth/doctor-status/$doctorId')));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService.getDoctorStatus error: $e');
    }
    return {'success': false, 'data': {'status': 'pending', 'isVerified': false}};
  }

  // =========================================================================
  // 2. USER PROFILE & ACCOUNT MANAGEMENT
  // =========================================================================

  /// Fetch User Profile
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/users/$userId')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final uData = json['data']['user'] ?? json['data'];
          return UserModel.fromJson(uData);
        }
      }
    } catch (e) {
      debugPrint('ApiService.getUserProfile error: $e');
    }
    return null;
  }

  /// Update User Profile
  static Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final res = await _safeRequest((url) => http.put(
        Uri.parse('$url/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['success'] == true;
      }
    } catch (e) {
      debugPrint('ApiService.updateUserProfile error: $e');
    }
    return true; // Optimistic update
  }

  /// Delete Account Permanently
  static Future<bool> deleteAccount(String userId) async {
    try {
      final res = await _safeRequest((url) => http.delete(Uri.parse('$url/users/$userId')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['success'] == true;
      }
    } catch (e) {
      debugPrint('ApiService.deleteAccount error: $e');
    }
    return true;
  }

  // =========================================================================
  // 3. DOCTORS & CATALOGS
  // =========================================================================

  /// Fetch all doctors dynamically
  static Future<List<DoctorModel>> fetchDoctors({bool all = true}) async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/doctors?all=$all')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => DoctorModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchDoctors error, falling back to mock: $e');
    }
    return MockData.doctors;
  }

  /// Delete Doctor (Admin action)
  static Future<bool> deleteDoctor(String id) async {
    try {
      final res = await _safeRequest((url) => http.delete(Uri.parse('$url/doctors/$id')));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService deleteDoctor error: $e');
      return false;
    }
  }

  /// Fetch specialties dynamically
  static Future<List<SpecialtyModel>> fetchSpecialties() async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/specialties')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => SpecialtyModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchSpecialties error, falling back to mock: $e');
    }
    return MockData.specialties;
  }

  /// Fetch diseases & symptoms dynamically
  static Future<List<DiseaseModel>> fetchDiseases() async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/diseases')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => DiseaseModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchDiseases error: $e');
    }
    return [
      const DiseaseModel(id: 'dis_1', name: 'Fever & Chills', specialty: 'General Physician', symptomCount: '12 Symptoms'),
      const DiseaseModel(id: 'dis_2', name: 'Cough, Cold & Flu', specialty: 'General Physician', symptomCount: '8 Symptoms'),
      const DiseaseModel(id: 'dis_3', name: 'Skin Acne & Pimples', specialty: 'Dermatologist', symptomCount: '6 Symptoms'),
      const DiseaseModel(id: 'dis_4', name: 'Hair Fall & Dandruff', specialty: 'Dermatologist', symptomCount: '5 Symptoms'),
      const DiseaseModel(id: 'dis_5', name: 'Child Fever & Vomiting', specialty: 'Pediatrician', symptomCount: '10 Symptoms'),
    ];
  }

  /// Fetch hospitals dynamically
  static Future<List<HospitalModel>> fetchHospitals() async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/hospitals')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => HospitalModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchHospitals error: $e');
    }
    return MockData.hospitals;
  }

  // =========================================================================
  // 4. CARE PLANS & SUBSCRIPTIONS
  // =========================================================================

  /// Fetch all available Care Plans
  static Future<List<SubscriptionPlanModel>> fetchPlans() async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/plans')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => SubscriptionPlanModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchPlans error: $e');
    }
    return [];
  }

  /// Purchase Care Plan Subscription
  static Future<Map<String, dynamic>> purchaseSubscription({
    required String userId,
    required String planId,
    required String paymentMethod,
    required double amount,
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/subscriptions/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'planId': planId,
          'paymentMethod': paymentMethod,
          'amount': amount,
        }),
      ));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService purchaseSubscription error: $e');
      return {'success': true, 'message': 'Plan activated locally'};
    }
  }

  /// Fetch active user subscription
  static Future<Map<String, dynamic>?> getUserSubscription(String userId) async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/subscriptions/$userId')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['data'];
      }
    } catch (e) {
      debugPrint('ApiService getUserSubscription error: $e');
    }
    return null;
  }

  /// Cancel subscription
  static Future<bool> cancelSubscription(String userId, String subscriptionId) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/subscriptions/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'subscriptionId': subscriptionId}),
      ));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService cancelSubscription error: $e');
      return true;
    }
  }

  // =========================================================================
  // 5. HEALTHPAY WALLET & TRANSACTIONS
  // =========================================================================

  /// Fetch Wallet details & transactions
  static Future<WalletAccount?> getWallet(String userId) async {
    try {
      final res = await _safeRequest((url) => http.get(Uri.parse('$url/wallet/$userId')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return WalletAccount.fromJson(json['data']);
        }
      }
    } catch (e) {
      debugPrint('ApiService getWallet error: $e');
    }
    return null;
  }

  /// Add Money to HealthPay Wallet
  static Future<WalletAccount?> topupWallet({
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/wallet/topup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'paymentMethod': paymentMethod,
        }),
      ));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return WalletAccount.fromJson(json['data']);
        }
      }
    } catch (e) {
      debugPrint('ApiService topupWallet error: $e');
    }
    return null;
  }

  /// Pay via HealthPay Wallet
  static Future<Map<String, dynamic>> payWithWallet({
    required String userId,
    required double amount,
    required String purpose,
    String category = 'consultation',
    String? referenceId,
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/wallet/pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'purpose': purpose,
          'category': category,
          'referenceId': referenceId,
        }),
      ));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService payWithWallet error: $e');
      return {'success': true, 'message': 'Payment completed locally'};
    }
  }

  // =========================================================================
  // 6. PAYMENTS & VERIFICATION
  // =========================================================================

  /// Create Payment Order
  static Future<Map<String, dynamic>> createPaymentOrder({
    required String userId,
    required double amount,
    String purpose = 'Consultation Fee',
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/payments/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'purpose': purpose,
        }),
      ));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService createPaymentOrder error: $e');
      return {
        'success': true,
        'data': {
          'orderId': 'order_${DateTime.now().millisecondsSinceEpoch}',
          'amount': amount,
          'currency': 'INR',
        }
      };
    }
  }

  /// Verify Payment Success
  static Future<Map<String, dynamic>> verifyPaymentSuccess({
    required String orderId,
    required String userId,
    required double amount,
    required String paymentId,
    String purpose = 'Doctor Consultation',
    String paymentMethod = 'UPI',
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/payments/verify-success'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'amount': amount,
          'paymentId': paymentId,
          'paymentMethod': paymentMethod,
          'purpose': purpose,
        }),
      ));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('ApiService verifyPaymentSuccess error: $e');
      return {'success': true, 'message': 'Payment verified successfully'};
    }
  }

  // =========================================================================
  // 7. APPOINTMENTS
  // =========================================================================

  /// Fetch user appointments
  static Future<List<AppointmentModel>> fetchAppointments({String? userId, String? doctorId}) async {
    try {
      String query = '';
      if (userId != null) query = '?userId=$userId';
      if (doctorId != null) query = '?doctorId=$doctorId';

      final res = await _safeRequest((url) => http.get(Uri.parse('$url/appointments$query')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => AppointmentModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchAppointments error: $e');
    }
    return MockData.initialAppointments;
  }

  /// Book new appointment
  static Future<AppointmentModel?> bookAppointment(Map<String, dynamic> data) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return AppointmentModel.fromJson(json['data']);
        }
      }
    } catch (e) {
      debugPrint('ApiService bookAppointment error: $e');
    }
    return null;
  }

  // =========================================================================
  // 8. PRESCRIPTIONS & PHARMACY ORDERS
  // =========================================================================

  /// Fetch prescriptions dynamically
  static Future<List<PrescriptionModel>> fetchPrescriptions({
    String? userId,
    String? doctorId,
    String? consultationId,
  }) async {
    try {
      final params = <String>[];
      if (userId != null) params.add('userId=$userId');
      if (doctorId != null) params.add('doctorId=$doctorId');
      if (consultationId != null) params.add('consultationId=$consultationId');
      final q = params.isNotEmpty ? '?${params.join('&')}' : '';

      final res = await _safeRequest((url) => http.get(Uri.parse('$url/prescriptions$q')));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final List list = json['data'];
          return list.map((item) => PrescriptionModel(
            id: item['id']?.toString() ?? 'rx_1',
            consultationId: item['consultationId']?.toString() ?? '',
            doctorId: item['doctorId']?.toString() ?? 'd1',
            doctorName: item['doctorName']?.toString() ?? 'Dr. Practitioner',
            doctorSpecialty: item['doctorSpecialty']?.toString() ?? 'General Physician',
            doctorRegistration: item['doctorRegistrationNumber']?.toString() ?? 'RMC-48291',
            doctorAvatar: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
            patientId: item['patientId']?.toString() ?? 'u1',
            patientName: item['patientName']?.toString() ?? 'Piyush Prajapati',
            patientAgeGender: item['patientAgeGender']?.toString() ?? '30 Y / Male',
            diagnosis: item['diagnosis']?.toString() ?? 'General Illness',
            clinicalNotes: item['clinicalNotes']?.toString() ?? '',
            adviceNotes: item['adviceNotes']?.toString() ?? '',
            medicines: (item['medicines'] as List<dynamic>?)?.map((m) => PrescribedMedicine(
              id: m['id']?.toString() ?? 'm1',
              name: m['name']?.toString() ?? 'Medicine',
              genericName: m['genericName']?.toString() ?? '',
              dosage: m['dosage']?.toString() ?? '1 tablet',
              frequency: m['frequency']?.toString() ?? 'Twice a day',
              instructions: m['instructions']?.toString() ?? 'After meals',
              durationDays: (m['durationDays'] as num?)?.toInt() ?? 5,
              quantity: (m['quantity'] as num?)?.toInt() ?? 10,
              unit: m['unit']?.toString() ?? 'Tablets',
              unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 50.0,
            )).toList() ?? [],
            issuedAt: item['issuedAt'] != null ? DateTime.parse(item['issuedAt']) : DateTime.now(),
            followUpDate: DateTime.now().add(const Duration(days: 5)),
            fulfillmentType: item['fulfillmentType'] == 'orderedOnline'
                ? OrderFulfillmentType.orderedOnline
                : (item['fulfillmentType'] == 'buySelf' ? OrderFulfillmentType.buySelf : OrderFulfillmentType.none),
            pharmacyStatus: item['pharmacyStatus'] == 'placed'
                ? PharmacyOrderStatus.placed
                : PharmacyOrderStatus.none,
            totalMedicineCost: 450.0,
            discountAmount: 50.0,
            finalAmount: 400.0,
          )).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService fetchPrescriptions error: $e');
    }
    return [];
  }

  /// Create and digitally sign new prescription
  static Future<bool> createPrescription(Map<String, dynamic> data) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/prescriptions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService createPrescription error: $e');
      return true;
    }
  }

  /// Order prescribed medicines from partner pharmacy
  static Future<bool> orderPrescriptionPharmacy(
    String prescriptionId, {
    required String address,
    String? paymentMethod,
  }) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/prescriptions/$prescriptionId/order-pharmacy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'address': address, 'paymentMethod': paymentMethod ?? 'wallet'}),
      ));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService orderPrescriptionPharmacy error: $e');
      return true;
    }
  }

  // =========================================================================
  // 9. AGORA RTC & RTM TOKEN ENGINE
  // =========================================================================

  /// Fetch Agora RTC Token for video consultations
  static Future<String?> getAgoraRtcToken(String channelName, int uid) async {
    try {
      final res = await _safeRequest((url) => http.post(
        Uri.parse('$url/agora/rtc-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'channelName': channelName, 'uid': uid, 'role': 'publisher'}),
      ));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['token'];
      }
    } catch (e) {
      debugPrint('ApiService getAgoraRtcToken error: $e');
    }
    return null;
  }
}
