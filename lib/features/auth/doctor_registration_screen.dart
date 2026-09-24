import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "../../core/theme/app_colors.dart";
import "../../core/routes/app_routes.dart";
import "../../providers/specialty_provider.dart";
import "../../services/api_service.dart";

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final _scrollController = ScrollController();
  int _currentStep = 0; // 0 to 6 (7 steps), 7 = Success screen
  bool _isSubmitting = false;

  // -------------------------------------------------------------
  // 1. BASIC INFORMATION
  // -------------------------------------------------------------
  final _nameController = TextEditingController(text: "Dr. Vikramaditya Rathore");
  final _emailController = TextEditingController(text: "dr.vikramaditya@medicare.com");
  final _phoneController = TextEditingController(text: "+91 98112 34567");
  final _altPhoneController = TextEditingController(text: "+91 94140 12345");
  final _passwordController = TextEditingController(text: "Medical@Pass2026");
  bool _obscurePassword = true;
  String _gender = "Male";
  DateTime _dateOfBirth = DateTime(1987, 4, 12);
  String _profilePhotoUrl =
      "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400";

  // -------------------------------------------------------------
  // 2. MEDICAL QUALIFICATIONS & EDUCATION
  // -------------------------------------------------------------
  String _primaryDegree = "MBBS";
  final _primaryCollegeController =
      TextEditingController(text: "SMS Medical College & Hospital, Jaipur");
  final _primaryPassingYearController = TextEditingController(text: "2011");
  String _primaryDegreeCertUrl =
      "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800";

  String _postGradDegree = "MD (Internal Medicine)";
  final _postGradCollegeController =
      TextEditingController(text: "AIIMS New Delhi");
  final _postGradPassingYearController = TextEditingController(text: "2015");
  String _postGradCertUrl =
      "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800";

  // -------------------------------------------------------------
  // 3. REGISTRATION & SPECIALIZATION (FROM ADMIN SPECIALTIES)
  // -------------------------------------------------------------
  final _licenseNoController = TextEditingController(text: "RMC/2011/77321");
  String _stateCouncil = "Rajasthan Medical Council";
  final _registrationStateController = TextEditingController(text: "Rajasthan");
  final _registrationYearController = TextEditingController(text: "2011");
  final _expiryYearController = TextEditingController(text: "2036");

  // Selected Specialization (Fetched dynamically from Admin)
  String _selectedSpecialty = "Cardiologist";
  final _subSpecialtyController =
      TextEditingController(text: "Interventional Cardiology & Angiography");
  final _experienceYearsController = TextEditingController(text: "12");
  final List<String> _selectedLanguages = ["English", "Hindi", "Punjabi"];

  // -------------------------------------------------------------
  // 4. CLINIC / HOSPITAL INFORMATION
  // -------------------------------------------------------------
  final _clinicNameController =
      TextEditingController(text: "Rathore Heart & Multispecialty Clinic");
  final _clinicAddressController =
      TextEditingController(text: "Plot 12, JLN Marg, Near World Trade Park");
  final _cityController = TextEditingController(text: "Jaipur");
  final _stateController = TextEditingController(text: "Rajasthan");
  final _pincodeController = TextEditingController(text: "302018");
  final _landmarkController =
      TextEditingController(text: "Opposite Gaurav Tower, Malviya Nagar");
  String _consultationType = "both"; // "in_person", "video", "both"

  // -------------------------------------------------------------
  // 5. CONSULTATION DETAILS & AVAILABILITY
  // -------------------------------------------------------------
  final _inPersonFeeController = TextEditingController(text: "800");
  final _videoFeeController = TextEditingController(text: "650");
  final _followUpFeeController = TextEditingController(text: "400");
  String _slotDuration = "20 mins";
  final List<String> _availableDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final List<String> _availableTimeSlots = [
    "Morning (09:00 AM - 01:00 PM)",
    "Evening (05:00 PM - 09:00 PM)"
  ];
  bool _emergencyAvailable = true;

  // -------------------------------------------------------------
  // 6. DOCUMENTS & VERIFICATION UPLOADS
  // -------------------------------------------------------------
  String _medicalCouncilCertUrl =
      "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800";
  String _idProofUrl =
      "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800";
  String _clinicProofUrl =
      "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800";
  String _signatureUrl =
      "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800";
  String _otherCertUrl =
      "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800";

  // -------------------------------------------------------------
  // 7. BANK / PAYMENT DETAILS & PROFILE BIO
  // -------------------------------------------------------------
  final _accountHolderController =
      TextEditingController(text: "Dr. Vikramaditya Rathore");
  final _bankNameController = TextEditingController(text: "HDFC Bank");
  final _accountNoController = TextEditingController(text: "50100492817263");
  final _confirmAccountNoController =
      TextEditingController(text: "50100492817263");
  final _ifscController = TextEditingController(text: "HDFC0001234");
  final _upiIdController = TextEditingController(text: "drvikram@okhdfcbank");
  final _panController = TextEditingController(text: "ABCDE1234F");

  final _aboutBioController = TextEditingController(
      text:
          "Senior Interventional Cardiologist with over 12 years of clinical practice. Specialist in coronary angiography, hypertension management, preventive heart checkups, and tele-cardiology consultations.");
  final _areasOfExpertiseController = TextEditingController(
      text:
          "Clinical Cardiology, 2D Echocardiography, Coronary Angiography, Hypertension Control, Lipidology");
  final _awardsController = TextEditingController(
      text:
          "Gold Medalist in MD Medicine (2015), Best Clinical Research Paper - Cardiological Society of India (2021)");

  bool _agreeCodeOfConduct = true;
  bool _agreeTelemedicineGuidelines = true;

  // Generated Registration ID
  String _generatedRegId = "MED-DOC-77321";

  // State Medical Councils in India
  final List<String> _indianMedicalCouncils = [
    "National Medical Commission (NMC / MCI)",
    "Rajasthan Medical Council",
    "Delhi Medical Council",
    "Maharashtra Medical Council",
    "Karnataka Medical Council",
    "Tamil Nadu Medical Council",
    "Uttar Pradesh Medical Council",
    "West Bengal Medical Council",
    "Gujarat Medical Council",
    "Kerala Medical Council",
    "Andhra Pradesh Medical Council",
    "Telangana Medical Council",
    "Punjab Medical Council",
    "Haryana Medical Council",
    "Madhya Pradesh Medical Council",
    "Bihar Medical Council",
    "Odisha Medical Council",
  ];

  final List<String> _primaryDegreeOptions = [
    "MBBS",
    "BDS",
    "BAMS (Ayurveda)",
    "BHMS (Homeopathy)",
    "BUMS (Unani)",
  ];

  final List<String> _postGradDegreeOptions = [
    "MD (Internal Medicine)",
    "MS (General Surgery)",
    "MD (Cardiology / DM)",
    "MD (Pediatrics)",
    "MS (Obstetrics & Gynaecology)",
    "MD (Dermatology)",
    "MS (Orthopedics)",
    "DNB (Diplomate of National Board)",
    "DM (Super-Specialty)",
    "MCh (Surgical Super-Specialty)",
    "Fellowship / Diploma",
    "None / Primary Only",
  ];

  final List<String> _languageOptions = [
    "English",
    "Hindi",
    "Punjabi",
    "Gujarati",
    "Marathi",
    "Bengali",
    "Tamil",
    "Telugu",
    "Malayalam",
    "Kannada",
    "Urdu",
  ];

  final List<String> _dayOptions = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _passwordController.dispose();
    _primaryCollegeController.dispose();
    _primaryPassingYearController.dispose();
    _postGradCollegeController.dispose();
    _postGradPassingYearController.dispose();
    _licenseNoController.dispose();
    _registrationStateController.dispose();
    _registrationYearController.dispose();
    _expiryYearController.dispose();
    _subSpecialtyController.dispose();
    _experienceYearsController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    _inPersonFeeController.dispose();
    _videoFeeController.dispose();
    _followUpFeeController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNoController.dispose();
    _confirmAccountNoController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    _panController.dispose();
    _aboutBioController.dispose();
    _areasOfExpertiseController.dispose();
    _awardsController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // -------------------------------------------------------------
  // VALIDATION & STEP ADVANCEMENT
  // -------------------------------------------------------------
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Information
        if (_nameController.text.trim().isEmpty) {
          _showSnack("Please enter your full legal name.");
          return false;
        }
        if (_phoneController.text.trim().isEmpty) {
          _showSnack("Please enter your mobile phone number.");
          return false;
        }
        if (_emailController.text.trim().isEmpty ||
            !_emailController.text.contains("@")) {
          _showSnack("Please enter a valid official email address.");
          return false;
        }
        if (_passwordController.text.trim().length < 6) {
          _showSnack("Password must be at least 6 characters long.");
          return false;
        }
        return true;

      case 1: // Education
        if (_primaryCollegeController.text.trim().isEmpty) {
          _showSnack("Please enter your primary medical college/university.");
          return false;
        }
        if (_primaryPassingYearController.text.trim().isEmpty) {
          _showSnack("Please enter primary graduation year.");
          return false;
        }
        return true;

      case 2: // Registration & Specialization
        if (_licenseNoController.text.trim().isEmpty) {
          _showSnack("Please enter your State Medical Council registration number.");
          return false;
        }
        if (_experienceYearsController.text.trim().isEmpty) {
          _showSnack("Please specify your years of clinical experience.");
          return false;
        }
        return true;

      case 3: // Clinic / Hospital
        if (_clinicNameController.text.trim().isEmpty) {
          _showSnack("Please enter your clinic or hospital establishment name.");
          return false;
        }
        if (_clinicAddressController.text.trim().isEmpty) {
          _showSnack("Please enter your clinic street address.");
          return false;
        }
        if (_cityController.text.trim().isEmpty) {
          _showSnack("Please enter your clinic city.");
          return false;
        }
        return true;

      case 4: // Consultation Details
        if (_inPersonFeeController.text.trim().isEmpty ||
            _videoFeeController.text.trim().isEmpty) {
          _showSnack("Please set both in-person and video consultation fees.");
          return false;
        }
        if (_availableDays.isEmpty) {
          _showSnack("Please select at least one available consultation day.");
          return false;
        }
        return true;

      case 5: // Documents Upload
        if (_medicalCouncilCertUrl.isEmpty || _idProofUrl.isEmpty) {
          _showSnack("Please attach mandatory Medical Council Certificate and Govt ID.");
          return false;
        }
        return true;

      case 6: // Bank & Profile
        if (_accountNoController.text.trim().isEmpty) {
          _showSnack("Please enter your bank account number.");
          return false;
        }
        if (_accountNoController.text.trim() !=
            _confirmAccountNoController.text.trim()) {
          _showSnack("Bank account numbers do not match.");
          return false;
        }
        if (!_agreeCodeOfConduct || !_agreeTelemedicineGuidelines) {
          _showSnack("Please accept NMC Code of Conduct & Telemedicine Guidelines.");
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 6) {
        setState(() => _currentStep++);
        _scrollToTop();
      } else {
        _submitRegistration();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _scrollToTop();
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // -------------------------------------------------------------
  // FAST AUTO-FILL DEMO SHORTCUT
  // -------------------------------------------------------------
  void _autoFillDemoProfile() {
    setState(() {
      _nameController.text = "Dr. Vikramaditya Rathore";
      _emailController.text = "dr.vikramaditya@medicare.com";
      _phoneController.text = "+91 97112 34567";
      _altPhoneController.text = "+91 94140 88990";
      _passwordController.text = "DoctorPass@2026";
      _gender = "Male";
      _dateOfBirth = DateTime(1987, 4, 12);
      _profilePhotoUrl =
          "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400";

      _primaryDegree = "MBBS";
      _primaryCollegeController.text =
          "SMS Medical College & Attached Hospitals, Jaipur";
      _primaryPassingYearController.text = "2011";
      _primaryDegreeCertUrl =
          "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800";

      _postGradDegree = "MD (Internal Medicine)";
      _postGradCollegeController.text = "AIIMS New Delhi";
      _postGradPassingYearController.text = "2015";
      _postGradCertUrl =
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800";

      _licenseNoController.text = "RMC/2011/77321";
      _stateCouncil = "Rajasthan Medical Council";
      _registrationStateController.text = "Rajasthan";
      _registrationYearController.text = "2011";
      _expiryYearController.text = "2036";
      _selectedSpecialty = "Cardiologist";
      _subSpecialtyController.text =
          "Interventional Cardiology & Coronary Angiography";
      _experienceYearsController.text = "12";

      _clinicNameController.text = "Rathore Heart Care & Wellness Clinic";
      _clinicAddressController.text =
          "Plot 12, JLN Marg, Near World Trade Park";
      _cityController.text = "Jaipur";
      _stateController.text = "Rajasthan";
      _pincodeController.text = "302018";
      _landmarkController.text = "Opposite Gaurav Tower, Malviya Nagar";
      _consultationType = "both";

      _inPersonFeeController.text = "800";
      _videoFeeController.text = "650";
      _followUpFeeController.text = "400";
      _slotDuration = "20 mins";
      _emergencyAvailable = true;

      _medicalCouncilCertUrl =
          "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800";
      _idProofUrl =
          "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800";
      _clinicProofUrl =
          "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800";
      _signatureUrl =
          "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800";
      _otherCertUrl =
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800";

      _accountHolderController.text = "Dr. Vikramaditya Rathore";
      _bankNameController.text = "HDFC Bank";
      _accountNoController.text = "50100492817263";
      _confirmAccountNoController.text = "50100492817263";
      _ifscController.text = "HDFC0001234";
      _upiIdController.text = "drvikram@okhdfcbank";
      _panController.text = "ABCDE1234F";

      _aboutBioController.text =
          "Senior Interventional Cardiologist with over 12 years of clinical practice. Specialist in coronary angiography, hypertension management, preventive heart checkups, and tele-cardiology consultations.";
      _areasOfExpertiseController.text =
          "Clinical Cardiology, 2D Echocardiography, Coronary Angiography, Hypertension Control, Lipidology";
      _awardsController.text =
          "Gold Medalist in MD Medicine (2015), Best Clinical Research Paper - Cardiological Society of India (2021)";

      _agreeCodeOfConduct = true;
      _agreeTelemedicineGuidelines = true;
    });

    _showSnack(
      "Demo practitioner profile, qualifications & 6 docs loaded! Tap Next to review.",
      isError: false,
    );
  }

  // -------------------------------------------------------------
  // SUBMISSION TO API & BACKEND
  // -------------------------------------------------------------
  Future<void> _submitRegistration() async {
    setState(() => _isSubmitting = true);

    try {
      final payload = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "altPhone": _altPhoneController.text.trim(),
        "gender": _gender,
        "dateOfBirth": DateFormat("yyyy-MM-dd").format(_dateOfBirth),
        "primaryDegree": _primaryDegree,
        "qualification": "$_primaryDegree, $_postGradDegree",
        "collegeName": _primaryCollegeController.text.trim(),
        "graduationYear": _primaryPassingYearController.text.trim(),
        "postGradDegree": _postGradDegree,
        "postGradCollege": _postGradCollegeController.text.trim(),
        "postGradYear": _postGradPassingYearController.text.trim(),
        "medicalLicenseNo": _licenseNoController.text.trim(),
        "stateMedicalCouncil": _stateCouncil,
        "registrationState": _registrationStateController.text.trim(),
        "registrationYear": _registrationYearController.text.trim(),
        "licenseExpiryYear": _expiryYearController.text.trim(),
        "specialty": _selectedSpecialty,
        "subSpecialty": _subSpecialtyController.text.trim(),
        "experienceYears":
            int.tryParse(_experienceYearsController.text.trim()) ?? 5,
        "languages": _selectedLanguages,
        "clinicName": _clinicNameController.text.trim(),
        "clinicAddress": _clinicAddressController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "pincode": _pincodeController.text.trim(),
        "landmark": _landmarkController.text.trim(),
        "consultationType": _consultationType,
        "consultationFee":
            double.tryParse(_inPersonFeeController.text.trim()) ?? 500.0,
        "videoConsultationFee":
            double.tryParse(_videoFeeController.text.trim()) ?? 450.0,
        "followUpFee":
            double.tryParse(_followUpFeeController.text.trim()) ?? 300.0,
        "slotDuration": _slotDuration,
        "availableDays": _availableDays,
        "availableTimeSlots": _availableTimeSlots,
        "emergencyAvailable": _emergencyAvailable,
        "medicalCouncilCertUrl": _medicalCouncilCertUrl,
        "primaryDegreeCertUrl": _primaryDegreeCertUrl,
        "postGradCertUrl": _postGradCertUrl,
        "idProofUrl": _idProofUrl,
        "clinicAddressProofUrl": _clinicProofUrl,
        "doctorSignatureUrl": _signatureUrl,
        "otherCertUrl": _otherCertUrl,
        "imageUrl": _profilePhotoUrl,
        "accountHolderName": _accountHolderController.text.trim(),
        "bankName": _bankNameController.text.trim(),
        "accountNumber": _accountNoController.text.trim(),
        "ifscCode": _ifscController.text.trim(),
        "upiId": _upiIdController.text.trim(),
        "panNumber": _panController.text.trim(),
        "aboutText": _aboutBioController.text.trim(),
        "areasOfExpertise": _areasOfExpertiseController.text.trim(),
        "awards": _awardsController.text.trim(),
      };

      await ApiService.registerDoctor(
        name: payload["name"] as String,
        email: payload["email"] as String,
        phone: payload["phone"] as String,
        gender: payload["gender"] as String,
        dateOfBirth: payload["dateOfBirth"] as String,
        specialty: payload["specialty"] as String,
        subSpecialty: payload["subSpecialty"] as String,
        qualification: payload["qualification"] as String,
        collegeName: payload["collegeName"] as String,
        graduationYear: payload["graduationYear"] as String,
        postGradDegree: payload["postGradDegree"] as String,
        postGradCollege: payload["postGradCollege"] as String,
        postGradYear: payload["postGradYear"] as String,
        experienceYears: payload["experienceYears"] as int,
        consultationFee: payload["consultationFee"] as double,
        videoConsultationFee: payload["videoConsultationFee"] as double,
        clinicName: payload["clinicName"] as String,
        clinicAddress: payload["clinicAddress"] as String,
        city: payload["city"] as String,
        pincode: payload["pincode"] as String,
        medicalLicenseNo: payload["medicalLicenseNo"] as String,
        stateMedicalCouncil: payload["stateMedicalCouncil"] as String,
        registrationYear: payload["registrationYear"] as String,
        licenseExpiryYear: payload["licenseExpiryYear"] as String,
        medicalCouncilCertUrl: payload["medicalCouncilCertUrl"] as String,
        primaryDegreeCertUrl: payload["primaryDegreeCertUrl"] as String,
        postGradCertUrl: payload["postGradCertUrl"] as String,
        idProofUrl: payload["idProofUrl"] as String,
        clinicAddressProofUrl: payload["clinicAddressProofUrl"] as String,
        doctorSignatureUrl: payload["doctorSignatureUrl"] as String,
        imageUrl: payload["imageUrl"] as String,
        languages: List<String>.from(payload["languages"] as List),
        aboutText: payload["aboutText"] as String,
      );

      _generatedRegId =
          "DOC-${DateTime.now().year}-${(10000 + DateTime.now().millisecond).toString()}";

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _currentStep = 7; // Transition to Success / Pending Screen
      });
      _scrollToTop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack("Submission error: $e");
    }
  }

  // -------------------------------------------------------------
  // DOCUMENT LIGHTBOX & PICKER
  // -------------------------------------------------------------
  void _openDocumentLightbox(String title, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Text(
                          "Document Preview",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Pinch to zoom in / inspect certificate seals and stamps",
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentUploadSheet({
    required String title,
    required Function(String newUrl) onSelected,
  }) {
    final presets = [
      "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800",
      "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800",
      "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800",
      "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800",
      "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800",
      "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload $title",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Take a photo of physical document, select from gallery, or choose official preset.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                ),
                title: const Text("Capture with Device Camera",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: const Text("Scan document directly",
                    style: TextStyle(fontSize: 11.5)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelected(presets[0]);
                  _showSnack("Camera document photo captured & attached!",
                      isError: false);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Colors.blue),
                ),
                title: const Text("Choose from Photo Gallery / Files",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: const Text("Supports JPG, PNG, PDF",
                    style: TextStyle(fontSize: 11.5)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelected(presets[1]);
                  _showSnack("Document attached from device storage!",
                      isError: false);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_outlined,
                      color: AppColors.success),
                ),
                title: const Text("Use Certified NMC Sample Certificate",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: const Text("High-resolution verified specimen",
                    style: TextStyle(fontSize: 11.5)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onSelected(presets[2]);
                  _showSnack("Certified document specimen loaded.",
                      isError: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BUILD METHOD
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Watch specialties dynamically from Admin Provider
    final specialtiesAsync = ref.watch(specialtiesListProvider);
    final List<String> adminSpecialties = specialtiesAsync.isNotEmpty
        ? specialtiesAsync.map((s) => s.name).toList()
        : [
            "General Physician",
            "Cardiologist",
            "Dermatologist",
            "Gynecologist",
            "Pediatrician",
            "Orthopedic Surgeon",
            "Neurologist",
            "ENT Specialist",
            "Psychiatrist",
            "Dentist",
            "Ophthalmologist",
            "Pulmonologist",
          ];

    // Ensure selected specialty exists in admin list
    if (!adminSpecialties.contains(_selectedSpecialty) &&
        adminSpecialties.isNotEmpty) {
      _selectedSpecialty = adminSpecialties.first;
    }

    if (_currentStep == 7) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Doctor Registration",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "NMC Telemedicine License Application",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Icon(Icons.flash_on_rounded,
                  color: Colors.amber, size: 16),
              label: const Text(
                "⚡ Auto-fill Demo",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: Colors.amber.shade50,
              side: BorderSide(color: Colors.amber.shade200),
              onPressed: _autoFillDemoProfile,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // STEP PROGRESS STEPPER AT TOP
            _buildStepperHeader(),

            // SCROLLABLE CURRENT STEP CONTENT
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: _buildStepBody(adminSpecialties),
              ),
            ),

            // BOTTOM NAVIGATION BAR
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEPPER HEADER WIDGET
  // -------------------------------------------------------------
  Widget _buildStepperHeader() {
    final stepTitles = [
      "Personal Details",
      "Medical Degrees",
      "Registration & Specialty",
      "Clinic Details",
      "Fees & Availability",
      "Documents Vault",
      "Bank & Profile",
    ];

    final progress = (_currentStep + 1) / 7;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "STEP ${_currentStep + 1} OF 7",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stepTitles[_currentStep],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                "${(progress * 100).toInt()}% Done",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          // Horizontal step badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (idx) {
                final isDone = idx < _currentStep;
                final isCurrent = idx == _currentStep;

                return GestureDetector(
                  onTap: () {
                    // Only allow jumping back to completed steps
                    if (idx < _currentStep) {
                      setState(() => _currentStep = idx);
                      _scrollToTop();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primaryLight
                          : isDone
                              ? AppColors.successLight
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primary
                            : isDone
                                ? AppColors.success.withValues(alpha: 0.5)
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDone)
                          const Icon(Icons.check_circle_rounded,
                              size: 13, color: AppColors.success)
                        else
                          Text(
                            "${idx + 1}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isCurrent
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        const SizedBox(width: 5),
                        Text(
                          stepTitles[idx],
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? AppColors.primary
                                : isDone
                                    ? const Color(0xFF065F46)
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP CONTENT DISPATCHER
  // -------------------------------------------------------------
  Widget _buildStepBody(List<String> adminSpecialties) {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2Education();
      case 2:
        return _buildStep3RegistrationAndSpecialty(adminSpecialties);
      case 3:
        return _buildStep4Clinic();
      case 4:
        return _buildStep5ConsultationDetails();
      case 5:
        return _buildStep6Documents();
      case 6:
        return _buildStep7BankAndProfile();
      default:
        return _buildStep1BasicInfo();
    }
  }

  // -------------------------------------------------------------
  // STEP 1: BASIC INFORMATION
  // -------------------------------------------------------------
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.person_rounded,
          title: "1. Basic Personal Information",
          subtitle:
              "Official doctor legal identity as registered with Medical Council",
        ),
        const SizedBox(height: 16),

        // Profile Photo Avatar Card
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: NetworkImage(_profilePhotoUrl),
                    onBackgroundImageError: (context, error) {},
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _showDocumentUploadSheet(
                          title: "Doctor Profile Photo",
                          onSelected: (url) =>
                              setState(() => _profilePhotoUrl = url),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Doctor Profile Picture (Tap camera to change)",
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _nameController,
          label: "Full Legal Name (with title) *",
          hint: "e.g. Dr. Vikramaditya Rathore",
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 14),

        // Gender Choice Chips
        const Text(
          "Gender *",
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Row(
          children: ["Male", "Female", "Other"].map((g) {
            final isSel = _gender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g),
                selected: isSel,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                onSelected: (_) => setState(() => _gender = g),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Date of Birth Interactive Picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth,
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 21)),
            );
            if (picked != null) setState(() => _dateOfBirth = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Date of Birth *",
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(
                      "${DateFormat("dd MMMM yyyy").format(_dateOfBirth)} (${DateTime.now().year - _dateOfBirth.year} years)",
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _phoneController,
          label: "Mobile Number *",
          hint: "+91 98112 34567",
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_iphone_rounded,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _altPhoneController,
          label: "Alternate Mobile / Clinic Landline",
          hint: "+91 94140 12345 (Optional)",
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.call_outlined,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _emailController,
          label: "Official Email Address *",
          hint: "dr.name@medicare.com",
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _passwordController,
          label: "Account Password *",
          hint: "Create secure practitioner password",
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: Colors.grey,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: MEDICAL QUALIFICATIONS & EDUCATION
  // -------------------------------------------------------------
  Widget _buildStep2Education() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.school_rounded,
          title: "2. Medical Qualifications & Degrees",
          subtitle:
              "Record recognized MBBS graduation and post-graduate medical training",
        ),
        const SizedBox(height: 16),

        // Primary Degree Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_outlined,
                        color: Colors.blue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Primary Medical Qualification (Undergraduate)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _primaryDegree,
                decoration: _fieldDecoration(
                  label: "Degree Title *",
                  prefixIcon: Icons.workspace_premium_outlined,
                ),
                items: _primaryDegreeOptions.map((deg) {
                  return DropdownMenuItem(value: deg, child: Text(deg));
                }).toList(),
                onChanged: (val) =>
                    setState(() => _primaryDegree = val ?? "MBBS"),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _primaryCollegeController,
                label: "Medical College / University *",
                hint: "e.g. SMS Medical College, Jaipur",
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _primaryPassingYearController,
                label: "Year of Passing *",
                hint: "e.g. 2011",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 14),

              // Upload Primary Degree
              _buildMiniDocUpload(
                title: "Primary Degree Certificate (MBBS)",
                url: _primaryDegreeCertUrl,
                onTapUpload: () {
                  _showDocumentUploadSheet(
                    title: "Primary Degree Certificate",
                    onSelected: (u) => setState(() => _primaryDegreeCertUrl = u),
                  );
                },
                onTapInspect: () => _openDocumentLightbox(
                    "Primary Degree Certificate", _primaryDegreeCertUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Post-Graduate Degree Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.military_tech_outlined,
                        color: Colors.indigo, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Post-Graduate Specialization (PG / Higher Degree)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _postGradDegree,
                decoration: _fieldDecoration(
                  label: "PG Degree Title",
                  prefixIcon: Icons.military_tech_outlined,
                ),
                items: _postGradDegreeOptions.map((deg) {
                  return DropdownMenuItem(value: deg, child: Text(deg));
                }).toList(),
                onChanged: (val) => setState(
                    () => _postGradDegree = val ?? "MD (Internal Medicine)"),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _postGradCollegeController,
                label: "PG College / Institute",
                hint: "e.g. AIIMS New Delhi",
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _postGradPassingYearController,
                label: "PG Passing Year",
                hint: "e.g. 2015",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 14),

              // Upload PG Certificate
              _buildMiniDocUpload(
                title: "Post-Graduate Specialization Certificate",
                url: _postGradCertUrl,
                onTapUpload: () {
                  _showDocumentUploadSheet(
                    title: "Post-Graduate Degree Certificate",
                    onSelected: (u) => setState(() => _postGradCertUrl = u),
                  );
                },
                onTapInspect: () => _openDocumentLightbox(
                    "Post-Graduate Certificate", _postGradCertUrl),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 3: REGISTRATION & SPECIALIZATION (FROM ADMIN)
  // -------------------------------------------------------------
  Widget _buildStep3RegistrationAndSpecialty(List<String> adminSpecialties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.badge_rounded,
          title: "3. State Council & Specialization",
          subtitle:
              "Medical licensing authority and practice specialty (configured by Admin)",
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _licenseNoController,
          label: "Medical Registration / License Number *",
          hint: "e.g. RMC/2011/77321 or MCI/2011/84920",
          prefixIcon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          initialValue: _stateCouncil,
          isExpanded: true,
          decoration: _fieldDecoration(
            label: "Medical Council / Registration Authority *",
            prefixIcon: Icons.verified_user_outlined,
          ),
          items: _indianMedicalCouncils.map((council) {
            return DropdownMenuItem(
              value: council,
              child: Text(council,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) =>
              setState(() => _stateCouncil = val ?? _indianMedicalCouncils.first),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _registrationYearController,
                label: "Registration Year *",
                hint: "2011",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.event_available_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _expiryYearController,
                label: "License Valid Till",
                hint: "2036",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.event_busy_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // SPECIALIZATION SELECTION FROM ADMIN
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Text(
                    "Practice Specialization (Live from Admin Portal)",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Select your primary discipline from specialties configured by the hospital admin.",
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedSpecialty,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Primary Specialization *",
                  labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                  prefixIcon:
                      const Icon(Icons.medical_information_rounded, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
                items: adminSpecialties.map((spec) {
                  return DropdownMenuItem(
                    value: spec,
                    child: Text(
                      spec,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSpecialty = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _subSpecialtyController,
          label: "Sub-Specialization / Clinical Interest",
          hint: "e.g. Interventional Cardiology, Pediatric Asthma",
          prefixIcon: Icons.healing_outlined,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _experienceYearsController,
          label: "Total Years of Clinical Experience *",
          hint: "e.g. 12",
          keyboardType: TextInputType.number,
          prefixIcon: Icons.work_history_outlined,
        ),
        const SizedBox(height: 16),

        // Languages Spoken Chips
        const Text(
          "Languages Spoken with Patients *",
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languageOptions.map((lang) {
            final isSel = _selectedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSel,
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSel ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11.5,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedLanguages.add(lang);
                  } else {
                    if (_selectedLanguages.length > 1) {
                      _selectedLanguages.remove(lang);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 4: CLINIC / HOSPITAL DETAILS
  // -------------------------------------------------------------
  Widget _buildStep4Clinic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.apartment_rounded,
          title: "4. Clinic & Hospital Practice Information",
          subtitle:
              "Physical clinic premises, hospital affiliations, and consultation format",
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _clinicNameController,
          label: "Clinic / Hospital Name *",
          hint: "e.g. Rathore Heart Care & Wellness Clinic",
          prefixIcon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _clinicAddressController,
          label: "Clinic Street Address *",
          hint: "Plot 12, JLN Marg, Near World Trade Park",
          maxLines: 2,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: "City *",
                hint: "e.g. Jaipur",
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _pincodeController,
                label: "Pincode *",
                hint: "302018",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _landmarkController,
          label: "Google Map Landmark / Location Tag",
          hint: "Opposite Gaurav Tower, Malviya Nagar",
          prefixIcon: Icons.map_outlined,
        ),
        const SizedBox(height: 18),

        // Consultation Type Cards
        const Text(
          "Consultation Mode Offered *",
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            _buildConsultTypeCard(
              id: "in_person",
              title: "In-Person",
              subtitle: "Clinic visit only",
              icon: Icons.storefront_rounded,
            ),
            const SizedBox(width: 8),
            _buildConsultTypeCard(
              id: "video",
              title: "Video Call",
              subtitle: "Telemedicine only",
              icon: Icons.videocam_rounded,
            ),
            const SizedBox(width: 8),
            _buildConsultTypeCard(
              id: "both",
              title: "Both Modes",
              subtitle: "In-person + Video",
              icon: Icons.health_and_safety_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultTypeCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSel = _consultationType == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _consultationType = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? AppColors.primary : Colors.grey.shade300,
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: isSel ? AppColors.primary : Colors.grey.shade700),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSel ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5,
                  color: isSel ? AppColors.primary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 5: CONSULTATION DETAILS & AVAILABILITY
  // -------------------------------------------------------------
  Widget _buildStep5ConsultationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.schedule_rounded,
          title: "5. Consultation Fees & Weekly Schedule",
          subtitle:
              "Set your professional pricing, appointment duration, and active slots",
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _inPersonFeeController,
                label: "In-Person Fee (₹) *",
                hint: "800",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _videoFeeController,
                label: "Video Call Fee (₹) *",
                hint: "650",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.videocam_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _followUpFeeController,
          label: "Follow-up Consultation Fee (₹)",
          hint: "400 (Within 7 days)",
          keyboardType: TextInputType.number,
          prefixIcon: Icons.replay_rounded,
        ),
        const SizedBox(height: 16),

        // Slot Duration Chips
        const Text(
          "Average Consultation Duration *",
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: ["15 mins", "20 mins", "30 mins", "45 mins"].map((dur) {
            final isSel = _slotDuration == dur;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(dur),
                selected: isSel,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
                onSelected: (_) => setState(() => _slotDuration = dur),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Available Days
        const Text(
          "Available Practice Days *",
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _dayOptions.map((day) {
            final isSel = _availableDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSel,
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSel ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _availableDays.add(day);
                  } else {
                    if (_availableDays.length > 1) _availableDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Emergency Consultation Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emergency_rounded,
                        color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Emergency Consultations",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "Accept urgent on-demand calls",
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _emergencyAvailable,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _emergencyAvailable = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 6: DOCUMENTS & VERIFICATION UPLOADS
  // -------------------------------------------------------------
  Widget _buildStep6Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.folder_shared_rounded,
          title: "6. Required Documents & Verification Vault",
          subtitle:
              "Upload clear photocopies of certificates for National Medical Commission (NMC) verification",
        ),
        const SizedBox(height: 16),

        // 1. Council Cert
        _buildDocUploadCard(
          number: "1",
          title: "State Medical Council / NMC Registration Certificate *",
          subtitle:
              "Official license proving active registration with State Council",
          url: _medicalCouncilCertUrl,
          onUpload: () => _showDocumentUploadSheet(
            title: "Medical Council Certificate",
            onSelected: (u) => setState(() => _medicalCouncilCertUrl = u),
          ),
          onInspect: () => _openDocumentLightbox(
              "Medical Council Registration Certificate",
              _medicalCouncilCertUrl),
        ),
        const SizedBox(height: 12),

        // 2. Primary Degree
        _buildDocUploadCard(
          number: "2",
          title: "Primary Medical Degree Certificate (MBBS) *",
          subtitle: "Graduation degree awarded by approved medical university",
          url: _primaryDegreeCertUrl,
          onUpload: () => _showDocumentUploadSheet(
            title: "MBBS Degree Certificate",
            onSelected: (u) => setState(() => _primaryDegreeCertUrl = u),
          ),
          onInspect: () => _openDocumentLightbox(
              "Primary Degree Certificate (MBBS)", _primaryDegreeCertUrl),
        ),
        const SizedBox(height: 12),

        // 3. Post Grad Degree
        _buildDocUploadCard(
          number: "3",
          title: "Post-Graduate Degree / Specialization Certificate",
          subtitle: "MD / MS / DNB / DM Higher Medical Qualification proof",
          url: _postGradCertUrl,
          onUpload: () => _showDocumentUploadSheet(
            title: "Post-Graduate Degree Certificate",
            onSelected: (u) => setState(() => _postGradCertUrl = u),
          ),
          onInspect: () => _openDocumentLightbox(
              "Post-Graduate Specialization Certificate", _postGradCertUrl),
        ),
        const SizedBox(height: 12),

        // 4. Govt ID
        _buildDocUploadCard(
          number: "4",
          title: "Government Photo ID Proof *",
          subtitle: "Aadhaar Card, Passport, or Voter ID matching doctor name",
          url: _idProofUrl,
          onUpload: () => _showDocumentUploadSheet(
            title: "Government Identity Proof",
            onSelected: (u) => setState(() => _idProofUrl = u),
          ),
          onInspect: () => _openDocumentLightbox(
              "Government Photo ID Proof", _idProofUrl),
        ),
        const SizedBox(height: 12),

        // 5. Clinic Proof
        _buildDocUploadCard(
          number: "5",
          title: "Clinic / Hospital Establishment & Address Proof",
          subtitle:
              "Clinical establishment license, utility bill, or hospital empanelment",
          url: _clinicProofUrl,
          onUpload: () => _showDocumentUploadSheet(
            title: "Clinic / Hospital Proof",
            onSelected: (u) => setState(() => _clinicProofUrl = u),
          ),
          onInspect: () => _openDocumentLightbox(
              "Clinic Establishment & Address Proof", _clinicProofUrl),
        ),
        const SizedBox(height: 12),

        // 6. Doctor Signature
        _buildDocUploadCard(
          number: "6",
          title: "Doctor Official Signature & Stamp Specimen *",
          subtitle:
              "Clear specimen used to sign digital e-prescriptions after calls",
          url: _signatureUrl,
          onUpload: () => _showDocumentUploadSheet(
            title: "Doctor Official Signature & Stamp",
            onSelected: (u) => setState(() => _signatureUrl = u),
          ),
          onInspect: () => _openDocumentLightbox(
              "Official Signature & Stamp Specimen", _signatureUrl),
        ),
      ],
    );
  }

  Widget _buildDocUploadCard({
    required String number,
    required String title,
    required String subtitle,
    required String url,
    required VoidCallback onUpload,
    required VoidCallback onInspect,
  }) {
    final hasDoc = url.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDoc ? const Color(0xFFA7F3D0) : Colors.amber.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: hasDoc
                    ? AppColors.successLight
                    : Colors.amber.shade100,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: hasDoc
                        ? const Color(0xFF065F46)
                        : Colors.amber.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: hasDoc
                      ? AppColors.successLight
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasDoc ? "Attached" : "Required",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: hasDoc
                        ? const Color(0xFF065F46)
                        : Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thumbnail Row & Action Buttons
          Row(
            children: [
              GestureDetector(
                onTap: onInspect,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 48,
                    color: Colors.grey.shade100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                              Icons.description_outlined,
                              color: Colors.grey),
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.2),
                          child: const Center(
                            child: Icon(Icons.zoom_in_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.zoom_in_rounded, size: 16),
                        label: const Text("Inspect & Zoom",
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onInspect,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.upload_rounded,
                            size: 16, color: Colors.white),
                        label: const Text("Change",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onUpload,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDocUpload({
    required String title,
    required String url,
    required VoidCallback onTapUpload,
    required VoidCallback onTapInspect,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.description, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text("Certificate Attached (Tap inspect to verify)",
                    style: TextStyle(fontSize: 10, color: AppColors.success)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded,
                color: AppColors.primary, size: 20),
            onPressed: onTapInspect,
            tooltip: "Inspect Certificate",
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.grey, size: 20),
            onPressed: onTapUpload,
            tooltip: "Replace File",
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 7: BANK DETAILS, PROFILE BIO & UNDERTAKINGS
  // -------------------------------------------------------------
  Widget _buildStep7BankAndProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.account_balance_rounded,
          title: "7. Bank Payout Details & Profile Bio",
          subtitle:
              "Bank details for patient consultation fees payout and public doctor bio",
        ),
        const SizedBox(height: 16),

        // Bank Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Direct Bank Transfer Details for Consultation Payouts",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _accountHolderController,
                label: "Account Holder Name *",
                hint: "As printed on bank passbook",
                prefixIcon: Icons.person_pin_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _bankNameController,
                label: "Bank Name *",
                hint: "e.g. HDFC Bank, SBI, ICICI Bank",
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _accountNoController,
                label: "Bank Account Number *",
                hint: "e.g. 50100492817263",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _confirmAccountNoController,
                label: "Confirm Bank Account Number *",
                hint: "Re-enter account number",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ifscController,
                      label: "IFSC Code *",
                      hint: "HDFC0001234",
                      prefixIcon: Icons.domain_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _panController,
                      label: "PAN Number *",
                      hint: "ABCDE1234F",
                      prefixIcon: Icons.badge_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _upiIdController,
                label: "UPI ID for Instant Payouts",
                hint: "doctor@okhdfcbank (Optional)",
                prefixIcon: Icons.qr_code_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Doctor Profile & Bio
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Public Doctor Profile Bio & Expertise",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _aboutBioController,
                label: "About Doctor / Professional Clinical Bio *",
                hint: "Describe your medical philosophy and clinical background...",
                maxLines: 4,
                prefixIcon: Icons.history_edu_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _areasOfExpertiseController,
                label: "Key Areas of Medical Expertise",
                hint: "e.g. Coronary Angiography, Echo, Heart Failure",
                prefixIcon: Icons.stars_outlined,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _awardsController,
                label: "Awards & Honors (Optional)",
                hint: "e.g. Best Physician Award 2021",
                prefixIcon: Icons.emoji_events_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Legal Declarations
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gavel_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "NMC Medical Compliance Declarations",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _agreeCodeOfConduct,
                activeColor: AppColors.primary,
                title: const Text(
                  "I affirm adherence to the National Medical Commission (NMC) Code of Medical Conduct (2002/2023).",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                onChanged: (v) =>
                    setState(() => _agreeCodeOfConduct = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _agreeTelemedicineGuidelines,
                activeColor: AppColors.primary,
                title: const Text(
                  "I agree to follow the Indian Telemedicine Practice Guidelines (2020) and affirm that all uploaded certificates are authentic copies.",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                onChanged: (v) =>
                    setState(() => _agreeTelemedicineGuidelines = v ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // SUCCESS / PENDING AUDIT SCREEN (STEP 8)
  // -------------------------------------------------------------
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Shield Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.success,
                    size: 54,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Registration Submitted!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Welcome, ${_nameController.text}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),

              // Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "AUDIT STATUS:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.amber,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Pending Admin Verification",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Registration Ref ID:",
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          _generatedRegId,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontFamily: "monospace",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("License Number:",
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          _licenseNoController.text,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontFamily: "monospace",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Our medical compliance team will audit your State Council credentials and 6 attached verification certificates within 2-4 hours. You can inspect your dashboard now.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              ElevatedButton.icon(
                icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
                label: const Text(
                  "Go to Doctor Dashboard",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.doctorDashboard,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                child: const Text("Return to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BOTTOM NAVIGATION BAR
  // -------------------------------------------------------------
  Widget _buildBottomBar() {
    final isLast = _currentStep == 6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text("Back",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _prevStep,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isLast
                          ? Icons.verified_user_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
              label: Text(
                _isSubmitting
                    ? "Submitting..."
                    : isLast
                        ? "Submit for Verification"
                        : "Next: Step ${_currentStep + 2}",
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLast ? const Color(0xFF047857) : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // UI HELPERS
  // -------------------------------------------------------------
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      decoration: _fieldDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 19, color: Colors.grey.shade600)
          : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
    );
  }
}
