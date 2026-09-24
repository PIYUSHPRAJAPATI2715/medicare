import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/permission_helper.dart';
import '../../providers/specialty_provider.dart';
import '../../providers/doctor_verification_provider.dart';

/// Representation of an actual uploaded document or photo
class UploadedDoc {
  final String fileName;
  final String? filePath;
  final Uint8List? fileBytes;
  final int fileSizeBytes;
  final bool isPdf;
  final DateTime uploadedAt;

  UploadedDoc({
    required this.fileName,
    this.filePath,
    this.fileBytes,
    required this.fileSizeBytes,
    required this.isPdf,
    required this.uploadedAt,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0; // 0 to 6 = 7 steps; 7 = submission success
  bool _isSubmitting = false;

  // Real uploaded documents vault mapping: docKey -> UploadedDoc
  final Map<String, UploadedDoc> _uploadedDocs = {};
  UploadedDoc? _profilePhoto;

  // -------------------------------------------------------------
  // STEP 1: PERSONAL INFORMATION
  // -------------------------------------------------------------
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _gender = 'Male';
  DateTime? _dateOfBirth;

  // -------------------------------------------------------------
  // STEP 2: MEDICAL QUALIFICATIONS & EDUCATION
  // -------------------------------------------------------------
  String _primaryDegree = 'MBBS';
  final _primaryCollegeController = TextEditingController();
  final _primaryPassingYearController = TextEditingController();

  String _postGradDegree = 'None';
  final _postGradCollegeController = TextEditingController();
  final _postGradPassingYearController = TextEditingController();

  // -------------------------------------------------------------
  // STEP 3: REGISTRATION & SPECIALIZATION
  // -------------------------------------------------------------
  final _licenseNoController = TextEditingController();
  String _stateCouncil = 'National Medical Commission (NMC / MCI)';
  final _registrationYearController = TextEditingController();
  final _expiryYearController = TextEditingController();
  String? _selectedSpecialty;
  final _subSpecialtyController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final List<String> _selectedLanguages = ['English', 'Hindi'];

  // -------------------------------------------------------------
  // STEP 4: CLINIC / HOSPITAL DETAILS
  // -------------------------------------------------------------
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _consultationType = 'both'; // 'in_person', 'video', 'both'

  // -------------------------------------------------------------
  // STEP 5: CONSULTATION SCHEDULE & FEES
  // -------------------------------------------------------------
  final _inPersonFeeController = TextEditingController();
  final _videoFeeController = TextEditingController();
  final _followUpFeeController = TextEditingController();
  String _slotDuration = '20 mins';
  final List<String> _availableDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> _availableTimeSlots = [
    'Morning (09:00 AM - 01:00 PM)',
    'Evening (05:00 PM - 09:00 PM)'
  ];
  bool _emergencyAvailable = false;

  // -------------------------------------------------------------
  // STEP 7: BANK & ETHICAL DECLARATIONS
  // -------------------------------------------------------------
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _confirmAccountNoController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _panController = TextEditingController();
  final _aboutBioController = TextEditingController();

  bool _agreeCodeOfConduct = false;
  bool _agreeTelemedicineGuidelines = false;

  String _generatedRegId = '';

  // Council options
  final List<String> _stateCouncils = [
    'National Medical Commission (NMC / MCI)',
    'Rajasthan Medical Council',
    'Delhi Medical Council',
    'Maharashtra Medical Council',
    'Karnataka Medical Council',
    'Tamil Nadu Medical Council',
    'Uttar Pradesh Medical Council',
    'West Bengal Medical Council',
    'Gujarat Medical Council',
    'Kerala Medical Council',
    'Andhra Pradesh Medical Council',
    'Telangana Medical Council',
    'Punjab Medical Council',
    'Haryana Medical Council',
    'Madhya Pradesh Medical Council',
    'Bihar Medical Council',
    'Odisha Medical Council',
  ];

  final List<String> _primaryDegrees = [
    'MBBS',
    'BDS',
    'BAMS (Ayurveda)',
    'BHMS (Homeopathy)',
    'BUMS (Unani)',
  ];

  final List<String> _postGradDegrees = [
    'None',
    'MD (Internal Medicine)',
    'MS (General Surgery)',
    'MD (Cardiology / DM)',
    'MD (Pediatrics)',
    'MS (Obstetrics & Gynaecology)',
    'MD (Dermatology)',
    'MS (Orthopedics)',
    'DNB (Diplomate of National Board)',
    'DM (Super-Specialty)',
    'MCh (Surgical Super-Specialty)',
    'Diploma / Fellowship',
  ];

  final List<String> _languageOptions = [
    'English',
    'Hindi',
    'Punjabi',
    'Gujarati',
    'Marathi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Malayalam',
    'Kannada',
    'Urdu',
  ];

  final List<String> _daysList = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  final List<String> _timeSlotOptions = [
    'Morning (09:00 AM - 01:00 PM)',
    'Afternoon (01:00 PM - 05:00 PM)',
    'Evening (05:00 PM - 09:00 PM)',
    'Night (09:00 PM - 11:00 PM)'
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

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // -------------------------------------------------------------
  // REAL DOCUMENT & PHOTO PICKERS (CAMERA / GALLERY / FILES)
  // -------------------------------------------------------------
  Future<void> _pickImage(String docKey, ImageSource source) async {
    if (source == ImageSource.camera) {
      final hasPermission = await PermissionHelper.requestCameraPermission(context);
      if (!hasPermission) return;
    } else {
      final hasPermission = await PermissionHelper.requestGalleryPermission(context);
      if (!hasPermission) return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          if (docKey == 'profile_photo') {
            _profilePhoto = UploadedDoc(
              fileName: picked.name,
              filePath: kIsWeb ? null : picked.path,
              fileBytes: bytes,
              fileSizeBytes: bytes.length,
              isPdf: false,
              uploadedAt: DateTime.now(),
            );
          } else {
            _uploadedDocs[docKey] = UploadedDoc(
              fileName: picked.name,
              filePath: kIsWeb ? null : picked.path,
              fileBytes: bytes,
              fileSizeBytes: bytes.length,
              isPdf: false,
              uploadedAt: DateTime.now(),
            );
          }
        });
        _showSnack('Image uploaded successfully');
      }
    } catch (e) {
      _showSnack('Unable to pick image. Please check permissions.', isError: true);
    }
  }

  Future<void> _pickFile(String docKey) async {
    final hasPermission = await PermissionHelper.requestGalleryPermission(context);
    if (!hasPermission) return;

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final isPdf = file.extension?.toLowerCase() == 'pdf';
        final bytes = await file.readAsBytes();
        final size = file.lengthSync() ?? bytes.length;

        setState(() {
          _uploadedDocs[docKey] = UploadedDoc(
            fileName: file.name,
            filePath: file.path,
            fileBytes: bytes,
            fileSizeBytes: size,
            isPdf: isPdf,
            uploadedAt: DateTime.now(),
          );
        });
        _showSnack('Document attached successfully');
      }
    } catch (e) {
      _showSnack('Unable to select file: $e', isError: true);
    }
  }

  void _showDocumentPickerModal(String docKey, String docTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attach $docTitle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textTertiary),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Supported formats: JPG, PNG, or PDF up to 10MB',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 22),
                  ),
                  title: const Text('Take Photo with Camera',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Capture certificate directly',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(docKey, ImageSource.camera);
                  },
                ),
                const Divider(height: 1, color: AppColors.borderLight),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF16A34A), size: 22),
                  ),
                  title: const Text('Choose from Photo Gallery',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Select an image from device library',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(docKey, ImageSource.gallery);
                  },
                ),
                const Divider(height: 1, color: AppColors.borderLight),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFDC2626), size: 22),
                  ),
                  title: const Text('Browse Files / PDF',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Select scanned PDF or document',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickFile(docKey);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDocumentPreview(UploadedDoc doc, String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${doc.fileName} (${doc.formattedSize})',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderLight),

                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: doc.isPdf
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded,
                                    size: 64, color: Color(0xFFDC2626)),
                                const SizedBox(height: 12),
                                Text(
                                  doc.fileName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'PDF Document • ${doc.formattedSize}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            )
                          : InteractiveViewer(
                              maxScale: 4.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: doc.fileBytes != null
                                    ? Image.memory(doc.fileBytes!, fit: BoxFit.contain)
                                    : (doc.filePath != null
                                        ? Image.file(File(doc.filePath!), fit: BoxFit.contain)
                                        : const Icon(Icons.broken_image_outlined, size: 48)),
                              ),
                            ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // VALIDATION & STEP ADVANCEMENT
  // -------------------------------------------------------------
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          _showSnack('Please enter your full legal name.', isError: true);
          return false;
        }
        if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
          _showSnack('Please enter a valid email address.', isError: true);
          return false;
        }
        if (_phoneController.text.trim().length < 10) {
          _showSnack('Please enter a valid 10-digit mobile number.', isError: true);
          return false;
        }
        if (_passwordController.text.length < 6) {
          _showSnack('Password must be at least 6 characters long.', isError: true);
          return false;
        }
        if (_dateOfBirth == null) {
          _showSnack('Please select your Date of Birth.', isError: true);
          return false;
        }
        return true;

      case 1:
        if (_primaryCollegeController.text.trim().isEmpty) {
          _showSnack('Please enter your Primary Medical College / University.', isError: true);
          return false;
        }
        if (_primaryPassingYearController.text.trim().isEmpty) {
          _showSnack('Please enter your primary degree graduation year.', isError: true);
          return false;
        }
        if (!_uploadedDocs.containsKey('primary_degree')) {
          _showSnack('Please upload your Primary Degree Certificate.', isError: true);
          return false;
        }
        return true;

      case 2:
        if (_licenseNoController.text.trim().isEmpty) {
          _showSnack('Please enter your Medical Council Registration / License Number.', isError: true);
          return false;
        }
        if (_registrationYearController.text.trim().isEmpty) {
          _showSnack('Please enter your Medical Council registration year.', isError: true);
          return false;
        }
        if (_selectedSpecialty == null || _selectedSpecialty!.isEmpty) {
          _showSnack('Please select your practice specialization.', isError: true);
          return false;
        }
        if (_experienceYearsController.text.trim().isEmpty) {
          _showSnack('Please enter total years of clinical experience.', isError: true);
          return false;
        }
        return true;

      case 3:
        if (_clinicNameController.text.trim().isEmpty) {
          _showSnack('Please enter your Clinic or Hospital name.', isError: true);
          return false;
        }
        if (_clinicAddressController.text.trim().isEmpty) {
          _showSnack('Please enter your physical clinic street address.', isError: true);
          return false;
        }
        if (_cityController.text.trim().isEmpty) {
          _showSnack('Please enter your clinic city.', isError: true);
          return false;
        }
        if (_pincodeController.text.trim().length < 6) {
          _showSnack('Please enter a valid 6-digit postal PIN code.', isError: true);
          return false;
        }
        return true;

      case 4:
        if (_inPersonFeeController.text.trim().isEmpty && _videoFeeController.text.trim().isEmpty) {
          _showSnack('Please specify your consultation fee.', isError: true);
          return false;
        }
        if (_availableDays.isEmpty) {
          _showSnack('Please select at least one available consulting day.', isError: true);
          return false;
        }
        return true;

      case 5:
        if (!_uploadedDocs.containsKey('council_cert')) {
          _showSnack('Please upload your State Medical Council Certificate.', isError: true);
          return false;
        }
        if (!_uploadedDocs.containsKey('govt_id')) {
          _showSnack('Please upload Government Photo ID Proof.', isError: true);
          return false;
        }
        if (!_uploadedDocs.containsKey('clinic_proof')) {
          _showSnack('Please upload Clinic Establishment / Address Proof.', isError: true);
          return false;
        }
        if (!_uploadedDocs.containsKey('signature')) {
          _showSnack('Please upload your Signature Specimen for digital prescriptions.', isError: true);
          return false;
        }
        return true;

      case 6:
        if (_accountHolderController.text.trim().isEmpty) {
          _showSnack('Please enter the Bank Account Holder Name.', isError: true);
          return false;
        }
        if (_bankNameController.text.trim().isEmpty) {
          _showSnack('Please enter your Bank Name.', isError: true);
          return false;
        }
        if (_accountNoController.text.trim().isEmpty) {
          _showSnack('Please enter your Bank Account Number.', isError: true);
          return false;
        }
        if (_accountNoController.text.trim() != _confirmAccountNoController.text.trim()) {
          _showSnack('Account numbers do not match. Please verify.', isError: true);
          return false;
        }
        if (_ifscController.text.trim().isEmpty) {
          _showSnack('Please enter your bank IFSC Code.', isError: true);
          return false;
        }
        if (_panController.text.trim().isEmpty) {
          _showSnack('Please enter your PAN Card Number.', isError: true);
          return false;
        }
        if (!_agreeCodeOfConduct || !_agreeTelemedicineGuidelines) {
          _showSnack('Please accept the mandatory NMC regulatory declarations.', isError: true);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _nextStep() async {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 6) {
      setState(() => _currentStep++);
      _scrollToTop();
    } else {
      // Final Submit
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;

      final randomDigits = (10000 + (DateTime.now().millisecondsSinceEpoch % 89999)).toString();
      final regId = 'MED-DOC-$randomDigits';

      ref.read(doctorVerificationProvider.notifier).submitApplication(
        applicationId: regId,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        primaryDegree: _primaryDegree,
        postGradDegree: _postGradDegree == 'None' ? null : _postGradDegree,
        councilName: _stateCouncil,
        licenseNumber: _licenseNoController.text.trim(),
        specialization: _selectedSpecialty ?? 'General Physician',
        clinicName: _clinicNameController.text.trim(),
        uploadedDocsCount: _uploadedDocs.length,
      );

      setState(() {
        _isSubmitting = false;
        _generatedRegId = regId;
        _currentStep = 7; // Show verification status screen
      });
      _scrollToTop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _scrollToTop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 7) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: _previousStep,
        ),
        title: const Text(
          'Doctor Registration',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 7,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepHeader(),
                      const SizedBox(height: 24),
                      _buildStepContent(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP HEADER
  // -------------------------------------------------------------
  Widget _buildStepHeader() {
    final stepTitles = [
      'Personal Details',
      'Medical Qualifications',
      'Council & Specialty',
      'Clinic Information',
      'Consultation & Fees',
      'Document Vault',
      'Payout & Verification',
    ];

    final stepSubtitles = [
      'Enter your personal identification details as registered in medical records.',
      'Provide your primary and postgraduate medical degree credentials.',
      'Specify your medical council license and practice specialization.',
      'Enter your clinic or hospital address and practice modes.',
      'Define your consultation fees, available days, and slot timing.',
      'Attach clear photos or PDF copies of your licenses and certificates.',
      'Provide bank account details for consultation payouts and agree to declarations.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Step ${_currentStep + 1} of 7',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          stepTitles[_currentStep],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepSubtitles[_currentStep],
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP CONTENT DISPATCHER
  // -------------------------------------------------------------
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PersonalInfo();
      case 1:
        return _buildStep2Education();
      case 2:
        return _buildStep3Registration();
      case 3:
        return _buildStep4Clinic();
      case 4:
        return _buildStep5Consultation();
      case 5:
        return _buildStep6Documents();
      case 6:
        return _buildStep7BankAndBio();
      default:
        return const SizedBox.shrink();
    }
  }

  // -------------------------------------------------------------
  // STEP 1: PERSONAL INFORMATION
  // -------------------------------------------------------------
  Widget _buildStep1PersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real Profile Photo Picker
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => _showDocumentPickerModal('profile_photo', 'Profile Photo'),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: _profilePhoto != null
                      ? ClipOval(
                          child: _profilePhoto!.fileBytes != null
                              ? Image.memory(
                                  _profilePhoto!.fileBytes!,
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.cover,
                                )
                              : (_profilePhoto!.filePath != null
                                  ? Image.file(
                                      File(_profilePhoto!.filePath!),
                                      width: 92,
                                      height: 92,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.person, size: 48, color: AppColors.textTertiary)),
                        )
                      : const Icon(Icons.person_outline_rounded,
                          size: 46, color: AppColors.textTertiary),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showDocumentPickerModal('profile_photo', 'Profile Photo'),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _profilePhoto != null ? 'Tap to change photo' : 'Upload Professional Photo',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
        if (_profilePhoto != null)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _profilePhoto = null),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Remove Photo', style: TextStyle(fontSize: 11, color: AppColors.error)),
            ),
          ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _nameController,
          label: 'Full Legal Name *',
          hint: 'e.g. Dr. Rajesh Sharma',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),

        _buildLabel('Gender *'),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final isSel = _gender == g;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(g),
                selected: isSel,
                onSelected: (_) => setState(() => _gender = g),
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  color: isSel ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                backgroundColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSel ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        _buildLabel('Date of Birth *'),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final initial = _dateOfBirth ?? DateTime(now.year - 30, 1, 1);
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(1940),
              lastDate: DateTime(now.year - 21, now.month, now.day),
            );
            if (picked != null) {
              setState(() => _dateOfBirth = picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 10),
                Text(
                  _dateOfBirth != null
                      ? DateFormat('dd MMMM yyyy').format(_dateOfBirth!)
                      : 'Select Date of Birth',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _dateOfBirth != null ? AppColors.textPrimary : AppColors.textTertiary,
                    fontWeight: _dateOfBirth != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _phoneController,
          label: 'Mobile Number *',
          hint: '10-digit mobile number',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_iphone_rounded,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _altPhoneController,
          label: 'Alternate Mobile Number (Optional)',
          hint: 'Secondary contact number',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _emailController,
          label: 'Email Address *',
          hint: 'doctor.name@hospital.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _passwordController,
          label: 'Create Password *',
          hint: 'Minimum 6 characters',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
        _buildDropdownField<String>(
          label: 'Primary Medical Qualification *',
          value: _primaryDegree,
          items: _primaryDegrees,
          onChanged: (val) => setState(() => _primaryDegree = val ?? 'MBBS'),
          prefixIcon: Icons.school_outlined,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _primaryCollegeController,
          label: 'Medical College / University *',
          hint: 'e.g. SMS Medical College & Hospital, Jaipur',
          prefixIcon: Icons.apartment_outlined,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _primaryPassingYearController,
          label: 'Year of Passing / Graduation *',
          hint: 'e.g. 2012',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.event_available_outlined,
        ),
        const SizedBox(height: 16),

        _buildDocumentUploadWidget(
          docKey: 'primary_degree',
          title: 'Primary Degree Certificate *',
          subtitle: 'Scanned copy of MBBS / BDS degree diploma',
          isRequired: true,
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.borderLight),
        const SizedBox(height: 16),

        _buildDropdownField<String>(
          label: 'Postgraduate Medical Degree / Specialization',
          value: _postGradDegree,
          items: _postGradDegrees,
          onChanged: (val) => setState(() => _postGradDegree = val ?? 'None'),
          prefixIcon: Icons.workspace_premium_outlined,
        ),

        if (_postGradDegree != 'None') ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _postGradCollegeController,
            label: 'Postgraduate College / Institution',
            hint: 'e.g. AIIMS New Delhi',
            prefixIcon: Icons.apartment_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _postGradPassingYearController,
            label: 'PG Passing Year',
            hint: 'e.g. 2016',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.event_available_outlined,
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadWidget(
            docKey: 'post_grad_degree',
            title: 'Postgraduate Degree Certificate',
            subtitle: 'Upload MD / MS / DM certificate or fellowship scan',
            isRequired: false,
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 3: REGISTRATION & SPECIALIZATION
  // -------------------------------------------------------------
  Widget _buildStep3Registration() {
    final specialtiesList = ref.watch(specialtiesListProvider);
    final specialtyNames = specialtiesList.map((s) => s.name).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _licenseNoController,
          label: 'Medical Registration / License Number *',
          hint: 'e.g. RMC/2014/88412 or MCI-77321',
          prefixIcon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 16),

        _buildDropdownField<String>(
          label: 'Medical Council Authority *',
          value: _stateCouncil,
          items: _stateCouncils,
          onChanged: (val) => setState(() => _stateCouncil = val ?? _stateCouncils.first),
          prefixIcon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _registrationYearController,
                label: 'Registration Year *',
                hint: 'e.g. 2014',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_month_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _expiryYearController,
                label: 'License Valid Till',
                hint: 'e.g. 2035',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.event_busy_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Live Specialties from Admin
        _buildLabel('Practice Specialization (From Hospital Directory) *'),
        DropdownButtonFormField<String>(
          initialValue: _selectedSpecialty,
          isExpanded: true,
          hint: const Text('Select Specialization', style: TextStyle(fontSize: 13.5, color: AppColors.textTertiary)),
          decoration: _inputDecoration(prefixIcon: Icons.medical_services_outlined),
          items: specialtyNames.map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name, style: const TextStyle(fontSize: 13.5)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedSpecialty = val),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _subSpecialtyController,
          label: 'Sub-specialization / Clinical Focus',
          hint: 'e.g. Interventional Cardiology, Pediatric Asthma',
          prefixIcon: Icons.medication_outlined,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _experienceYearsController,
          label: 'Years of Clinical Practice Experience *',
          hint: 'e.g. 10',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.timeline_outlined,
        ),
        const SizedBox(height: 16),

        _buildLabel('Consultation Languages Spoken *'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languageOptions.map((lang) {
            final isSel = _selectedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSel,
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
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: isSel ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSel ? AppColors.primary : const Color(0xFFE2E8F0)),
              ),
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
        _buildTextField(
          controller: _clinicNameController,
          label: 'Clinic / Hospital Practice Name *',
          hint: 'e.g. City Health Clinic / Manipal Hospital',
          prefixIcon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _clinicAddressController,
          label: 'Street Address & Building Details *',
          hint: 'e.g. Suite 204, Metro Plaza, JLN Marg',
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City *',
                hint: 'e.g. Jaipur',
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State *',
                hint: 'e.g. Rajasthan',
                prefixIcon: Icons.map_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _pincodeController,
                label: 'PIN Code *',
                hint: 'e.g. 302018',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _landmarkController,
                label: 'Landmark (Optional)',
                hint: 'Near Metro Station',
                prefixIcon: Icons.near_me_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel('Practice Consultation Mode *'),
        Row(
          children: [
            _buildConsultTypeOption('in_person', 'In-Person', Icons.apartment_outlined),
            const SizedBox(width: 10),
            _buildConsultTypeOption('video', 'Video Call', Icons.videocam_outlined),
            const SizedBox(width: 10),
            _buildConsultTypeOption('both', 'Both Hybrid', Icons.sync_alt_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultTypeOption(String id, String label, IconData icon) {
    final isSel = _consultationType == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _consultationType = id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primaryLight : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? AppColors.primary : const Color(0xFFE2E8F0),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSel ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 5: CONSULTATION SCHEDULE & FEES
  // -------------------------------------------------------------
  Widget _buildStep5Consultation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _inPersonFeeController,
                label: 'In-Person Fee (₹) *',
                hint: 'e.g. 600',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _videoFeeController,
                label: 'Video Call Fee (₹) *',
                hint: 'e.g. 500',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _followUpFeeController,
          label: 'Follow-Up Review Fee (₹)',
          hint: 'e.g. 300 (or 0 for complimentary)',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.currency_rupee_rounded,
        ),
        const SizedBox(height: 20),

        _buildLabel('Average Appointment Duration *'),
        Row(
          children: ['15 mins', '20 mins', '30 mins', '45 mins'].map((dur) {
            final isSel = _slotDuration == dur;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(dur),
                selected: isSel,
                onSelected: (_) => setState(() => _slotDuration = dur),
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  color: isSel ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.5,
                ),
                backgroundColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isSel ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        _buildLabel('Weekly Available Days *'),
        Wrap(
          spacing: 8,
          children: _daysList.map((day) {
            final isSel = _availableDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSel,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _availableDays.add(day);
                  } else {
                    if (_availableDays.length > 1) _availableDays.remove(day);
                  }
                });
              },
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: isSel ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSel ? AppColors.primary : const Color(0xFFE2E8F0)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        _buildLabel('Preferred Consulting Time Slots *'),
        Column(
          children: _timeSlotOptions.map((slot) {
            final isSel = _availableTimeSlots.contains(slot);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              activeColor: AppColors.primary,
              title: Text(slot, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              value: isSel,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _availableTimeSlots.add(slot);
                  } else {
                    if (_availableTimeSlots.length > 1) _availableTimeSlots.remove(slot);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Urgent On-Demand Tele-consults',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Accept instant calls when online',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
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
  // STEP 6: DOCUMENT VAULT
  // -------------------------------------------------------------
  Widget _buildStep6Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocumentUploadWidget(
          docKey: 'council_cert',
          title: 'State Medical Council Certificate *',
          subtitle: 'Scanned certificate showing valid registration number',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        _buildDocumentUploadWidget(
          docKey: 'govt_id',
          title: 'Government Photo ID Proof *',
          subtitle: 'Aadhaar Card, Passport, or Voter ID',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        _buildDocumentUploadWidget(
          docKey: 'clinic_proof',
          title: 'Clinic Establishment / Address Proof *',
          subtitle: 'Clinic registration, utility bill, or rent deed',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        _buildDocumentUploadWidget(
          docKey: 'signature',
          title: 'Doctor Signature & Stamp Specimen *',
          subtitle: 'Required to digitally sign official tele-prescriptions',
          isRequired: true,
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 7: BANK ACCOUNT & BIO
  // -------------------------------------------------------------
  Widget _buildStep7BankAndBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _accountHolderController,
          label: 'Bank Account Holder Name *',
          hint: 'Name as registered with your bank',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _bankNameController,
          label: 'Bank Name *',
          hint: 'e.g. HDFC Bank, State Bank of India',
          prefixIcon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _accountNoController,
                label: 'Account Number *',
                hint: 'Enter account number',
                keyboardType: TextInputType.number,
                obscureText: true,
                prefixIcon: Icons.credit_card_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _confirmAccountNoController,
                label: 'Confirm Account No. *',
                hint: 'Re-enter account number',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.credit_card_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ifscController,
                label: 'IFSC Code *',
                hint: 'e.g. HDFC0001234',
                prefixIcon: Icons.tag_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _upiIdController,
                label: 'UPI ID (Optional)',
                hint: 'e.g. name@okhdfcbank',
                prefixIcon: Icons.alternate_email_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _panController,
          label: 'PAN Card Number *',
          hint: 'e.g. ABCDE1234F',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _aboutBioController,
          label: 'Professional Profile Summary / Bio',
          hint: 'Brief overview of your clinical expertise and treatment philosophy...',
          maxLines: 4,
          prefixIcon: Icons.description_outlined,
        ),
        const SizedBox(height: 20),

        // Declarations
        const Divider(color: AppColors.borderLight),
        const SizedBox(height: 12),

        CheckboxListTile(
          value: _agreeCodeOfConduct,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I affirm compliance with the National Medical Commission (NMC) Code of Medical Ethics and certify all uploaded credentials are valid.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
          onChanged: (val) => setState(() => _agreeCodeOfConduct = val ?? false),
        ),

        CheckboxListTile(
          value: _agreeTelemedicineGuidelines,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I agree to practice within the Indian Telemedicine Practice Guidelines (2020) and issue digital prescriptions following standard medical protocols.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
          onChanged: (val) => setState(() => _agreeTelemedicineGuidelines = val ?? false),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 8: SUBMISSION & VERIFICATION STATUS SCREEN
  // -------------------------------------------------------------
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 40),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Application Under Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Application ID: $_generatedRegId',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Your doctor profile is currently under review. Our medical credentialing team is verifying your council license and degree documents with the NMC.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Applicant', _nameController.text.trim()),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildSummaryRow('Specialization', _selectedSpecialty ?? 'General Physician'),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildSummaryRow('Council', _stateCouncil),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildSummaryRow('Documents Attached', '${_uploadedDocs.length} Verified Files'),
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildSummaryRow('Status', 'Under Verification (24-48 hrs)'),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.doctorVerificationStatus,
                    );
                  },
                  child: const Text(
                    'Track Verification Timeline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // REUSABLE DOCUMENT UPLOAD CARD
  // -------------------------------------------------------------
  Widget _buildDocumentUploadWidget({
    required String docKey,
    required String title,
    required String subtitle,
    required bool isRequired,
  }) {
    final doc = _uploadedDocs[docKey];
    final hasDoc = doc != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasDoc ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: hasDoc ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasDoc ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasDoc ? Icons.check_circle_outline_rounded : Icons.description_outlined,
                    color: hasDoc ? const Color(0xFF16A34A) : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (hasDoc) ...[
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showDocumentPreview(doc, title),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: doc.isPdf
                            ? const Center(
                                child: Icon(Icons.picture_as_pdf_rounded,
                                    color: Color(0xFFDC2626), size: 22),
                              )
                            : (doc.fileBytes != null
                                ? Image.memory(doc.fileBytes!, fit: BoxFit.cover)
                                : (doc.filePath != null
                                    ? Image.file(File(doc.filePath!), fit: BoxFit.cover)
                                    : const Icon(Icons.insert_drive_file, size: 20))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.fileName,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${doc.formattedSize} • Ready for audit',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  ),

                  // View Button
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 19, color: AppColors.primary),
                    tooltip: 'View File',
                    onPressed: () => _showDocumentPreview(doc, title),
                  ),

                  // Replace Button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.textSecondary),
                    tooltip: 'Change File',
                    onPressed: () => _showDocumentPickerModal(docKey, title),
                  ),

                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.error),
                    tooltip: 'Remove File',
                    onPressed: () {
                      setState(() => _uploadedDocs.remove(docKey));
                      _showSnack('Document removed');
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Attach Document',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  onPressed: () => _showDocumentPickerModal(docKey, title),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // BOTTOM NAVIGATION BAR
  // -------------------------------------------------------------
  Widget _buildBottomActionBar() {
    final isLast = _currentStep == 6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            SizedBox(
              height: 48,
              width: 100,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _previousStep,
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _nextStep,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isLast ? 'Submit Application' : 'Continue',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE FORM WIDGETS
  // -------------------------------------------------------------
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({IconData? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 19, color: AppColors.textTertiary) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          decoration: _inputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ).copyWith(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: _inputDecoration(prefixIcon: prefixIcon),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.toString(), style: const TextStyle(fontSize: 13.5)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
