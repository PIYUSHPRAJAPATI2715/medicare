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

class ApiService {

/// Single production API base URL.
/// Every API request in this service must use this URL.
static const String baseUrl = 'https://www.drconnects24.com/api';

/// Sends a request only to the production API.
static Future<http.Response> _request(
  Future<http.Response> Function(String url) requestFn, {
  Duration timeout = const Duration(seconds: 20),
  String label = '',
}) async {
  debugPrint('🌐 [LIVE API REQUEST] $label -> $baseUrl');
  try {
    final res = await requestFn(baseUrl).timeout(timeout);
    debugPrint('📥 [LIVE API RESPONSE] HTTP ${res.statusCode} | $label');
    debugPrint('📄 [RAW BODY] ${res.body}');
    _printStructuredResponse(res);
    return res;
  } catch (e) {
    debugPrint('❌ [API ERROR] $label failed: $e');
    rethrow;
  }
}

static void _printStructuredResponse(http.Response response) {
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final status = decoded['status'] ?? response.statusCode;
      final message = decoded['message'] ?? (status < 400 ? 'Success' : 'Error');
      final data = decoded['data'];
      debugPrint('📊 [STATUS CODE]: $status');
      debugPrint('💬 [MESSAGE]: $message');
      debugPrint('📦 [DATA]: $data');
    } else if (decoded is List) {
      debugPrint('📊 [STATUS CODE]: ${response.statusCode}');
      debugPrint('📦 [DATA LIST]: count = ${decoded.length}');
    }
  } catch (_) {
    debugPrint('⚠️ [NON-JSON BODY]: ${response.body}');
  }
}

static Map<String, dynamic> _errorResponse(Object error) => {
  'status': 500,
  'statusCode': 500,
  'success': false,
  'message': error.toString(),
  'data': null,
  'error': true,
};

static Map<String, dynamic> _decodeObject(http.Response response) {
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final int status = decoded['status'] ?? response.statusCode;
      final bool success = decoded['success'] ?? (status >= 200 && status < 300);
      final String message = decoded['message'] ?? (success ? 'Success' : 'Request failed');
      return {
        'status': status,
        'statusCode': status,
        'success': success,
        'message': message,
        'data': decoded['data'] ?? decoded,
      };
    }
    return {
      'status': response.statusCode,
      'statusCode': response.statusCode,
      'success': response.statusCode >= 200 && response.statusCode < 300,
      'message': 'OK',
      'data': decoded,
    };
  } catch (_) {
    return {
      'status': response.statusCode,
      'statusCode': response.statusCode,
      'success': false,
      'message': response.body.isNotEmpty ? response.body : 'Invalid or empty API response',
      'data': null,
    };
  }
}

static bool _isSuccess(http.Response response) {
  return response.statusCode >= 200 && response.statusCode < 300;
}

/// Prewarm core public catalog APIs on app launch.
static Future<void> prewarmAllCoreApis() async {
debugPrint('🚀 [ApiService] Prewarming from $baseUrl...');
try {
final results = await Future.wait([
fetchDoctors(),
fetchSpecialties(),
fetchPlans(),
fetchHospitals(),
], eagerError: false);

debugPrint(
'🌟 [ApiService] Ready! '
'${results[0].length} doctors, '
'${results[1].length} specialties, '
'${results[2].length} plans. '
'Active backend: $baseUrl',
);
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
final res = await _request(
(url) => http.post(
Uri.parse('$url/auth/login'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
'emailOrPhone': emailOrPhone,
'password': password,
'role': role,
}),
),

);
if (!_isSuccess(res)) {
return _decodeObject(res);

}
return _decodeObject(res);
} catch (e) {
debugPrint('ApiService.login error: $e');
return _errorResponse(e);
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
final res = await _request((url) => http.post(
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
return _errorResponse(e);
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
String imageUrl = '',
List<String> languages = const ['English', 'Hindi'],
String aboutText = '',
}) async {
try {
final res = await _request((url) => http.post(
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
return _errorResponse(e);
}
}

/// Check verification status of doctor
static Future<Map<String, dynamic>> getDoctorStatus(String doctorId) async {
try {
final res = await _request(
(url) => http.get(Uri.parse('$url/auth/doctor-status/$doctorId')),

);
if (res.statusCode == 200) {
return jsonDecode(res.body);
}
} catch (e) {
debugPrint('ApiService.getDoctorStatus error: $e');
}
return {'success': false, 'message': 'Unable to fetch doctor status'};
}

// =========================================================================
// 2. USER PROFILE & ACCOUNT MANAGEMENT
// =========================================================================

/// Fetch User Profile
static Future<UserModel?> getUserProfile(String userId) async {
try {
final res = await _request(
(url) => http.get(Uri.parse('$url/users/$userId')),

);
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
final res = await _request((url) => http.put(
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
return false;
}

/// Delete Account Permanently
static Future<bool> deleteAccount(String userId) async {
try {
final res = await _request((url) => http.delete(Uri.parse('$url/users/$userId')));
if (res.statusCode == 200) {
final json = jsonDecode(res.body);
return json['success'] == true;
}
} catch (e) {
debugPrint('ApiService.deleteAccount error: $e');
}
return false;
}

// =========================================================================
// 3. DOCTORS & CATALOGS
// =========================================================================

/// Fetch all doctors dynamically
static Future<List<DoctorModel>> fetchDoctors({bool all = true}) async {
try {
final res = await _request((url) => http.get(Uri.parse('$url/doctors?all=$all')));
if (res.statusCode == 200) {
final json = jsonDecode(res.body);
if (json['success'] == true && json['data'] != null) {
final List list = json['data'];
return list.map((item) => DoctorModel.fromJson(item)).toList();
}
}
} catch (e) {
debugPrint('ApiService fetchDoctors error, API request failed: $e');
}
return [];
}

/// Delete Doctor (Admin action)
static Future<bool> deleteDoctor(String id) async {
try {
final res = await _request((url) => http.delete(Uri.parse('$url/doctors/$id')));
return res.statusCode == 200;
} catch (e) {
debugPrint('ApiService deleteDoctor error: $e');
return false;
}
}

/// Fetch specialties dynamically
static Future<List<SpecialtyModel>> fetchSpecialties() async {
try {
final res = await _request((url) => http.get(Uri.parse('$url/specialties')));
if (res.statusCode == 200) {
final json = jsonDecode(res.body);
if (json['success'] == true && json['data'] != null) {
final List list = json['data'];
return list.map((item) => SpecialtyModel.fromJson(item)).toList();
}
}
} catch (e) {
debugPrint('ApiService fetchSpecialties error, API request failed: $e');
}
return [];
}

/// Fetch diseases & symptoms dynamically
static Future<List<DiseaseModel>> fetchDiseases() async {
try {
final res = await _request((url) => http.get(Uri.parse('$url/diseases')));
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
return [];
}

/// Fetch hospitals dynamically
static Future<List<HospitalModel>> fetchHospitals() async {
try {
final res = await _request((url) => http.get(Uri.parse('$url/hospitals')));
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
return [];
}

// =========================================================================
// 4. CARE PLANS & SUBSCRIPTIONS
// =========================================================================

/// Fetch all available Care Plans
static Future<List<SubscriptionPlanModel>> fetchPlans() async {
try {
final res = await _request((url) => http.get(Uri.parse('$url/plans')));
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
final res = await _request((url) => http.post(
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
return _errorResponse(e);
}
}

/// Fetch active user subscription
static Future<Map<String, dynamic>?> getUserSubscription(String userId) async {
try {
final res = await _request(
(url) => http.get(Uri.parse('$url/subscriptions/$userId')),

);
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
final res = await _request((url) => http.post(
Uri.parse('$url/subscriptions/cancel'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({'userId': userId, 'subscriptionId': subscriptionId}),
));
return res.statusCode == 200;
} catch (e) {
debugPrint('ApiService cancelSubscription error: $e');
return false;
}
}

// =========================================================================
// 5. HEALTHPAY WALLET & TRANSACTIONS
// =========================================================================

/// Fetch Wallet details & transactions
static Future<WalletAccount?> getWallet(String userId) async {
try {
final res = await _request(
(url) => http.get(Uri.parse('$url/wallet/$userId')),

);
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
final res = await _request((url) => http.post(
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
final res = await _request((url) => http.post(
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
return _errorResponse(e);
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
final res = await _request((url) => http.post(
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
return _errorResponse(e);
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
final res = await _request((url) => http.post(
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
return _errorResponse(e);
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

final res = await _request(
(url) => http.get(Uri.parse('$url/appointments$query')),

);
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
return [];
}

/// Book new appointment
static Future<AppointmentModel?> bookAppointment(Map<String, dynamic> data) async {
try {
final res = await _request((url) => http.post(
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

final res = await _request(
(url) => http.get(Uri.parse('$url/prescriptions$q')),

);
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
doctorAvatar: item['doctorAvatar']?.toString() ?? '',
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
final res = await _request((url) => http.post(
Uri.parse('$url/prescriptions'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode(data),
));
return res.statusCode == 200;
} catch (e) {
debugPrint('ApiService createPrescription error: $e');
return false;
}
}

/// Order prescribed medicines from partner pharmacy
static Future<bool> orderPrescriptionPharmacy(
String prescriptionId, {
required String address,
String? paymentMethod,
}) async {
try {
final res = await _request((url) => http.post(
Uri.parse('$url/prescriptions/$prescriptionId/order-pharmacy'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({'address': address, 'paymentMethod': paymentMethod ?? 'wallet'}),
));
return res.statusCode == 200;
} catch (e) {
debugPrint('ApiService orderPrescriptionPharmacy error: $e');
return false;
}
}

// =========================================================================
// 9. AGORA RTC & RTM TOKEN ENGINE
// =========================================================================

/// Fetch Agora RTC Token for video consultations
static Future<String?> getAgoraRtcToken(String channelName, int uid) async {
try {
final res = await _request((url) => http.post(
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