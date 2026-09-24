import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/api_service.dart';
import '../../core/animation/animation_utils.dart';

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Personal & Contact Controllers
  final _nameController = TextEditingController(text: 'Dr. Ananya Sharma');
  final _emailController = TextEditingController(text: 'dr.ananya@medicare.com');
  final _phoneController = TextEditingController(text: '+91 98123 45678');
  String _gender = 'Female';
  DateTime _dateOfBirth = DateTime(1989, 7, 24);
  String _profileImageUrl =
      'https://images.unsplash.com/photo-1594824813566-78a933758f46?w=400';

  // 2. Medical Education & Qualifications
  String _primaryDegree = 'MBBS';
  final _collegeNameController =
      TextEditingController(text: 'All India Institute of Medical Sciences (AIIMS) New Delhi');
  final _graduationYearController = TextEditingController(text: '2014');
  final _postGradDegreeController =
      TextEditingController(text: 'MD (Internal Medicine)');
  final _postGradCollegeController =
      TextEditingController(text: 'PGIMER Chandigarh');
  final _postGradYearController = TextEditingController(text: '2018');

  // 3. Medical Council Registration & Licensing
  String _stateCouncil = 'Delhi Medical Council';
  final _licenseNoController = TextEditingController(text: 'DMC-2018-94812');
  final _registrationYearController = TextEditingController(text: '2014');
  final _licenseExpiryYearController = TextEditingController(text: '2034');

  // 4. Clinical Practice & Consultation Fees
  String _selectedSpecialty = 'General Physician';
  final _subSpecialtyController =
      TextEditingController(text: 'Preventive Healthcare & Diabetology');
  final _experienceController = TextEditingController(text: '10');
  final _clinicNameController =
      TextEditingController(text: 'Sharma Advanced Wellness Clinic');
  final _clinicAddressController = TextEditingController(
      text: 'Plot 45, Commercial Belt, Malviya Nagar, Jaipur, Rajasthan');
  final _cityController = TextEditingController(text: 'Jaipur');
  final _pincodeController = TextEditingController(text: '302017');
  final _feeController = TextEditingController(text: '700');
  final _videoFeeController = TextEditingController(text: '500');
  final _bioController = TextEditingController(
      text: 'Senior Consultant Physician specializing in lifestyle disease reversal, diabetes, and preventive medicine. Over 10 years of clinical experience across premier institutes.');

  final List<String> _selectedLanguages = ['English', 'Hindi'];

  // 5. Mandatory Medical Verification Documents (6 Core Documents)
  final Map<String, _DocEntry> _documents = {
    'councilCert': _DocEntry(
      title: 'State Medical Council / NMC Certificate',
      subtitle: 'Official registration certificate bearing council seal & license number',
      url: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
      fileName: 'DMC_Registration_Certificate_2018.pdf',
      fileSize: '2.4 MB',
      isMandatory: true,
    ),
    'mbbsDegree': _DocEntry(
      title: 'Primary Medical Degree (MBBS / Equivalent)',
      subtitle: 'Graduation degree certificate issued by recognized University',
      url: 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800',
      fileName: 'AIIMS_MBBS_Degree_Certificate.pdf',
      fileSize: '3.1 MB',
      isMandatory: true,
    ),
    'pgDegree': _DocEntry(
      title: 'Post-Graduate Degree / Diploma (MD / MS)',
      subtitle: 'Specialization degree certificate or National Board diploma',
      url: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
      fileName: 'PGIMER_MD_Medicine_Degree.pdf',
      fileSize: '1.9 MB',
      isMandatory: true,
    ),
    'idProof': _DocEntry(
      title: 'Government Identity Proof (Aadhaar / Passport)',
      subtitle: 'Valid government issued photo ID for KYC verification',
      url: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
      fileName: 'Govt_Aadhaar_Card_Front_Back.pdf',
      fileSize: '1.2 MB',
      isMandatory: true,
    ),
    'clinicProof': _DocEntry(
      title: 'Clinic / Hospital Establishment & Address Proof',
      subtitle: 'Clinical establishment registration / Hospital ID / Utility bill',
      url: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800',
      fileName: 'Clinic_Establishment_License_Jaipur.pdf',
      fileSize: '2.8 MB',
      isMandatory: true,
    ),
    'signatureStamp': _DocEntry(
      title: 'Official Signature & Registration Seal Specimen',
      subtitle: 'Digital specimen for issuing verified legal tele-prescriptions',
      url: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
      fileName: 'Dr_Ananya_Digital_Signature_Seal.png',
      fileSize: '450 KB',
      isMandatory: true,
    ),
  };

  bool _agreeToEthicsCode = true;
  bool _agreeToTelemedGuidelines = true;
  bool _isLoading = false;

  final List<String> _specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Gynecologist',
    'Neurologist',
    'Orthopedist',
    'Ophthalmologist',
    'ENT Specialist',
    'Psychiatrist',
    'Dentist',
  ];

  final List<String> _councils = [
    'Delhi Medical Council',
    'Maharashtra Medical Council',
    'Rajasthan Medical Council',
    'Karnataka Medical Council',
    'Tamil Nadu Medical Council',
    'West Bengal Medical Council',
    'Uttar Pradesh Medical Council',
    'National Medical Commission (NMC / MCI)',
  ];

  final List<String> _degreeOptions = [
    'MBBS',
    'BDS',
    'BAMS',
    'BHMS',
    'MD / MS (Direct)',
  ];

  final List<String> _availableLanguages = [
    'English',
    'Hindi',
    'Bengali',
    'Marathi',
    'Telugu',
    'Tamil',
    'Gujarati',
    'Punjabi',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _collegeNameController.dispose();
    _graduationYearController.dispose();
    _postGradDegreeController.dispose();
    _postGradCollegeController.dispose();
    _postGradYearController.dispose();
    _licenseNoController.dispose();
    _registrationYearController.dispose();
    _licenseExpiryYearController.dispose();
    _subSpecialtyController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _feeController.dispose();
    _videoFeeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _autofillDemoProfile() {
    setState(() {
      _nameController.text = 'Dr. Rajeshwar Sharma';
      _emailController.text = 'dr.rajeshwar@medicare.com';
      _phoneController.text = '+91 98290 12345';
      _gender = 'Male';
      _dateOfBirth = DateTime(1982, 3, 14);
      _profileImageUrl =
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400';
      _primaryDegree = 'MBBS';
      _collegeNameController.text =
          'Maulana Azad Medical College (MAMC) New Delhi';
      _graduationYearController.text = '2006';
      _postGradDegreeController.text = 'MD (General Medicine), DM (Cardiology)';
      _postGradCollegeController.text = 'AIIMS New Delhi';
      _postGradYearController.text = '2011';
      _stateCouncil = 'Delhi Medical Council';
      _licenseNoController.text = 'DMC-2006-67841';
      _registrationYearController.text = '2006';
      _licenseExpiryYearController.text = '2036';
      _selectedSpecialty = 'Cardiologist';
      _subSpecialtyController.text = 'Interventional Cardiology';
      _experienceController.text = '18';
      _clinicNameController.text = 'Heart Care & Multispecialty Hospital';
      _clinicAddressController.text =
          'C-Scheme, Near Statue Circle, Jaipur, Rajasthan';
      _cityController.text = 'Jaipur';
      _pincodeController.text = '302001';
      _feeController.text = '900';
      _videoFeeController.text = '600';
      _bioController.text =
          'Chief Cardiologist with 18+ years of dedicated practice. Specialized in preventive cardiology, coronary interventions, and cardiac health checkups.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ Doctor profile & all credentials fast-filled!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDocumentViewer(String key, _DocEntry doc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc.fileName} • ${doc.fileSize}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    doc.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.description_rounded,
                            size: 64, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                        SizedBox(width: 4),
                        Text('Cryptographically Signed',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted fields before submitting.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreeToEthicsCode || !_agreeToTelemedGuidelines) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm compliance with NMC Ethics & Telemedicine guidelines.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final qualificationString = _postGradDegreeController.text.trim().isNotEmpty
        ? '$_primaryDegree, ${_postGradDegreeController.text.trim()}'
        : _primaryDegree;

    final result = await ApiService.registerDoctor(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _gender,
      dateOfBirth: DateFormat('yyyy-MM-dd').format(_dateOfBirth),
      specialty: _selectedSpecialty,
      subSpecialty: _subSpecialtyController.text.trim(),
      qualification: qualificationString,
      collegeName: _collegeNameController.text.trim(),
      graduationYear: _graduationYearController.text.trim(),
      postGradDegree: _postGradDegreeController.text.trim(),
      postGradCollege: _postGradCollegeController.text.trim(),
      postGradYear: _postGradYearController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? 5,
      consultationFee: double.tryParse(_feeController.text.trim()) ?? 600.0,
      videoConsultationFee: double.tryParse(_videoFeeController.text.trim()) ?? 499.0,
      clinicName: _clinicNameController.text.trim(),
      clinicAddress: _clinicAddressController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      medicalLicenseNo: _licenseNoController.text.trim(),
      stateMedicalCouncil: _stateCouncil,
      registrationYear: _registrationYearController.text.trim(),
      licenseExpiryYear: _licenseExpiryYearController.text.trim(),
      medicalCouncilCertUrl: _documents['councilCert']!.url,
      primaryDegreeCertUrl: _documents['mbbsDegree']!.url,
      postGradCertUrl: _documents['pgDegree']!.url,
      idProofUrl: _documents['idProof']!.url,
      clinicAddressProofUrl: _documents['clinicProof']!.url,
      doctorSignatureUrl: _documents['signatureStamp']!.url,
      imageUrl: _profileImageUrl,
      languages: _selectedLanguages,
      aboutText: _bioController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Registration Submitted!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result['message'] ??
                  'Your credentials and 6 mandatory medical documents have been submitted to the compliance team.',
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow('Doctor:', _nameController.text.trim()),
                  _summaryRow('Specialty:', _selectedSpecialty),
                  _summaryRow('Council:', _stateCouncil),
                  _summaryRow('License No:', _licenseNoController.text.trim()),
                  _summaryRow('Documents:', '6 / 6 Uploaded & Sealed'),
                  _summaryRow('Verification ETA:', 'Within 24 Hours'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return
            },
            child: const Text('OK, Got It',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Doctor Portal Registration',
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
            tooltip: 'Fast-Fill Demo Profile',
            onPressed: _autofillDemoProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              StaggeredFadeSlide(
                index: 0,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.bannerGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_information_rounded,
                          color: Colors.white, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Join MediCare+ Provider Network',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Complete 6-point verification per NMC Telemedicine regulations.',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 1: Personal & Contact Details
              // ==========================================
              _buildSectionHeader('1. Personal & Contact Details', Icons.person_outline_rounded),
              const SizedBox(height: 12),

              // Profile Picture Row
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _profileImageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person, size: 40, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Professional Photo / Headshot',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Displays on your prescription pad & patient booking profile.',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _presetPhotoChip('Female Specialist',
                                  'https://images.unsplash.com/photo-1594824813566-78a933758f46?w=400'),
                              const SizedBox(width: 6),
                              _presetPhotoChip('Male Physician',
                                  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name (with Dr. prefix) *',
                icon: Icons.person_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter doctor full name' : null,
              ),
              const SizedBox(height: 12),

              // Gender & Date of Birth Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _gender = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth,
                          firstDate: DateTime(1945),
                          lastDate: DateTime.now().subtract(const Duration(days: 365 * 22)),
                        );
                        if (picked != null) {
                          setState(() => _dateOfBirth = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DOB: ${DateFormat('dd MMM yyyy').format(_dateOfBirth)}',
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.calendar_today_rounded,
                                size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Official Email *',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Mobile Number *',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Phone required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 2: Medical Education & Degrees
              // ==========================================
              _buildSectionHeader('2. Medical Education & Qualifications', Icons.school_outlined),
              const SizedBox(height: 12),

              // Primary Degree & Graduation Year
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _primaryDegree,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary),
                          items: _degreeOptions.map((deg) {
                            return DropdownMenuItem(value: deg, child: Text(deg));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _primaryDegree = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _graduationYearController,
                      label: 'Passing Year *',
                      icon: Icons.date_range_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Year required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _collegeNameController,
                label: 'Medical College / Institute (MBBS) *',
                icon: Icons.account_balance_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'College name required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _postGradDegreeController,
                      label: 'Post-Graduation / Spec Degree (MD/MS/DNB)',
                      icon: Icons.workspace_premium_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _postGradYearController,
                      label: 'PG Year',
                      icon: Icons.date_range_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _postGradCollegeController,
                label: 'Post-Graduate Institute / Hospital',
                icon: Icons.local_hospital_rounded,
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 3: Council Registration & Licensing
              // ==========================================
              _buildSectionHeader(
                  '3. Medical Council Registration & Licensing', Icons.badge_outlined),
              const SizedBox(height: 4),
              const Text(
                'Per NMC Telemedicine Practice Guidelines, all practitioners must have an active State Council Registration.',
                style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              // State Medical Council Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _stateCouncil,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary),
                    items: _councils.map((c) {
                      return DropdownMenuItem(
                          value: c,
                          child: Text(c,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13.5)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _stateCouncil = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _licenseNoController,
                label: 'Medical Registration Number *',
                icon: Icons.assignment_ind_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Registration license required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _registrationYearController,
                      label: 'Registration Year *',
                      icon: Icons.calendar_month_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Reg year required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _licenseExpiryYearController,
                      label: 'Validity / Renewal Year *',
                      icon: Icons.event_repeat_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Expiry required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 4: Practice & Consultation Fees
              // ==========================================
              _buildSectionHeader('4. Practice, Specialty & Fees', Icons.local_hospital_outlined),
              const SizedBox(height: 12),

              // Specialty Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSpecialty,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary),
                    items: _specialties.map((spec) {
                      return DropdownMenuItem(
                          value: spec,
                          child: Text(spec,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13.5)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSpecialty = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _subSpecialtyController,
                      label: 'Sub-Specialty / Clinical Focus',
                      icon: Icons.healing_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _experienceController,
                      label: 'Exp (Years) *',
                      icon: Icons.work_history_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Exp required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _clinicNameController,
                label: 'Clinic / Hospital Affiliation Name *',
                icon: Icons.apartment_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Clinic name required' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _clinicAddressController,
                label: 'Clinic Complete Street Address *',
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Address required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City *',
                      icon: Icons.location_city_rounded,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'City required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _pincodeController,
                      label: 'Pincode *',
                      icon: Icons.pin_drop_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Pincode required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fees Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _videoFeeController,
                      label: 'Video Consult Fee (₹) *',
                      icon: Icons.videocam_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Fee required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _feeController,
                      label: 'In-Person Fee (₹) *',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Fee required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Languages Spoken
              const Text(
                'Languages Spoken by Doctor:',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableLanguages.map((lang) {
                  final isSelected = _selectedLanguages.contains(lang);
                  return FilterChip(
                    label: Text(lang),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    checkmarkColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
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
              const SizedBox(height: 12),

              _buildTextField(
                controller: _bioController,
                label: 'Doctor Professional Bio (Patient-facing) *',
                icon: Icons.description_rounded,
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Bio required' : null,
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 5: Mandatory Document Uploads (6 Core Docs)
              // ==========================================
              _buildSectionHeader('5. Mandatory Verification Documents',
                  Icons.verified_user_outlined),
              const SizedBox(height: 4),
              const Text(
                'Submit clear, high-resolution certificates. All documents undergo multi-level clinical compliance verification.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 14),

              ..._documents.entries.map((entry) {
                return _buildDocumentCard(entry.key, entry.value);
              }),

              const SizedBox(height: 20),

              // ==========================================
              // SECTION 6: Compliance & Ethics Declaration
              // ==========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _agreeToEthicsCode,
                      activeColor: AppColors.primary,
                      title: const Text(
                        'I declare adherence to the Indian Medical Council (Professional Conduct, Etiquette & Ethics) Regulations.',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      onChanged: (val) =>
                          setState(() => _agreeToEthicsCode = val ?? false),
                    ),
                    const Divider(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _agreeToTelemedGuidelines,
                      activeColor: AppColors.primary,
                      title: const Text(
                        'I agree to adhere to the Telemedicine Practice Guidelines issued by the Ministry of Health & Family Welfare (MoHFW) / NMC.',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      onChanged: (val) =>
                          setState(() => _agreeToTelemedGuidelines = val ?? false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              AppBouncyTouch(
                onTap: _isLoading ? () {} : _submitRegistration,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Submit Doctor Registration & All Docs',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetPhotoChip(String label, String url) {
    final isSelected = _profileImageUrl == url;
    return InkWell(
      onTap: () => setState(() => _profileImageUrl = url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(String key, _DocEntry doc) {
    final hasUploaded = doc.url.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasUploaded
              ? const Color(0xFF16A34A).withValues(alpha: 0.3)
              : AppColors.border,
          width: hasUploaded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Thumbnail
          InkWell(
            onTap: () => _showDocumentViewer(key, doc),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    doc.url,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.file_present_rounded,
                          color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: const Icon(Icons.zoom_in_rounded,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Document Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doc.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  doc.subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${doc.fileName} (${doc.fileSize})',
                        style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showDocumentViewer(key, doc),
                      child: const Text(
                        'Preview',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
          fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 19),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

class _DocEntry {
  final String title;
  final String subtitle;
  final String url;
  final String fileName;
  final String fileSize;
  final bool isMandatory;

  _DocEntry({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.isMandatory,
  });
}

