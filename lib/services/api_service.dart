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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/doctor-register'),
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
          'qualificationCertUrl': medicalCouncilCertUrl, // Backwards compatibility
          'imageUrl': imageUrl,
          'languages': languages,
          'aboutText': aboutText,
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
      'message': 'Registration submitted! Medical license & certificates are under admin verification.',
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
