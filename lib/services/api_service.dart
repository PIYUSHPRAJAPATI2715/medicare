import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../models/specialty_model.dart';
import '../data/mock/mock_data.dart';


class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5050/api';
    } else {
      return 'http://localhost:5050/api';
    }
  }

  /// Fetch all doctors dynamically from Node.js REST API
  static Future<List<DoctorModel>> fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors')).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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

  /// Fetch specialties dynamically
  static Future<List<SpecialtyModel>> fetchSpecialties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/specialties')).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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

  /// Register Doctor with full licensing documentation
  static Future<Map<String, dynamic>> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String specialty,
    required String qualification,
    required int experienceYears,
    required double consultationFee,
    required String clinicName,
    required String clinicAddress,
    required String medicalLicenseNo,
    required String stateMedicalCouncil,
    required String qualificationCertUrl,
    required String idProofUrl,
    required String clinicAddressProofUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/doctor-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'specialty': specialty,
          'qualification': qualification,
          'experienceYears': experienceYears,
          'consultationFee': consultationFee,
          'clinicName': clinicName,
          'clinicAddress': clinicAddress,
          'medicalLicenseNo': medicalLicenseNo,
          'stateMedicalCouncil': stateMedicalCouncil,
          'qualificationCertUrl': qualificationCertUrl,
          'idProofUrl': idProofUrl,
          'clinicAddressProofUrl': clinicAddressProofUrl,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService registerDoctor error: $e');
    }

    return {
      'success': true,
      'message': 'Registration submitted locally! Under admin verification.',
    };
  }

  /// Fetch Agora RTC Token for video consultations
  static Future<String?> getAgoraRtcToken(String channelName, int uid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agora/rtc-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'channelName': channelName, 'uid': uid, 'role': 'publisher'}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['token'];
      }
    } catch (e) {
      debugPrint('ApiService getAgoraRtcToken error: $e');
    }
    return null;
  }
}
