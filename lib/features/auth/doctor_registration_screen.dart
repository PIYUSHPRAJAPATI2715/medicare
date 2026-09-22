import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/api_service.dart';
import '../../core/animation/animation_utils.dart';

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends ConsumerState<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController(text: 'Dr. Ananya Sharma');
  final _emailController = TextEditingController(text: 'dr.ananya@medicare.com');
  final _phoneController = TextEditingController(text: '+91 98123 45678');
  final _qualificationController = TextEditingController(text: 'MBBS, MD (General Medicine)');
  final _experienceController = TextEditingController(text: '8');
  final _feeController = TextEditingController(text: '600');
  final _clinicNameController = TextEditingController(text: 'Sharma Health Clinic');
  final _clinicAddressController = TextEditingController(text: '45, Central Spine, Malviya Nagar, Jaipur');
  
  // Licensing & Council Verification
  final _licenseNoController = TextEditingController(text: 'DMC-2024-88912');
  final _stateCouncilController = TextEditingController(text: 'Delhi Medical Council');
  final _qualCertUrlController = TextEditingController(text: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600');
  final _idProofUrlController = TextEditingController(text: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600');
  final _clinicProofUrlController = TextEditingController(text: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600');

  String _selectedSpecialty = 'General Physician';
  bool _isLoading = false;

  final List<String> _specialties = [
    'General Physician',
    'Dermatologist',
    'Pediatrician',
    'Gynecologist',
    'Cardiologist',
    'Neurologist',
    'Orthopedist',
    'Ophthalmologist',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _licenseNoController.dispose();
    _stateCouncilController.dispose();
    _qualCertUrlController.dispose();
    _idProofUrlController.dispose();
    _clinicProofUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.registerDoctor(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      specialty: _selectedSpecialty,
      qualification: _qualificationController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? 1,
      consultationFee: double.tryParse(_feeController.text.trim()) ?? 500.0,
      clinicName: _clinicNameController.text.trim(),
      clinicAddress: _clinicAddressController.text.trim(),
      medicalLicenseNo: _licenseNoController.text.trim(),
      stateMedicalCouncil: _stateCouncilController.text.trim(),
      qualificationCertUrl: _qualCertUrlController.text.trim(),
      idProofUrl: _idProofUrlController.text.trim(),
      clinicAddressProofUrl: _clinicProofUrlController.text.trim(),
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
                'Registration Submitted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          result['message'] ??
              'Your doctor profile and medical credentials have been submitted. Our compliance team will verify your medical license within 24 hours.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to account/previous screen
            },
            child: const Text('OK, Got It', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Doctor Portal Registration',
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
                  child: const Row(
                    children: [
                      Icon(Icons.medical_information_rounded, color: Colors.white, size: 36),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join MediCare+ Provider Network',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Provide medical registration & documents for verification.',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: Personal & Professional Info
              _buildSectionHeader('1. Personal & Professional Details', Icons.person_outline_rounded),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name (with Title)',
                icon: Icons.person_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Phone required' : null,
                    ),
                  ),
                ],
              ),
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
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                    items: _specialties.map((spec) {
                      return DropdownMenuItem(
                        value: spec,
                        child: Text(spec, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      );
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
                      controller: _qualificationController,
                      label: 'Degrees / Qualification',
                      icon: Icons.school_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _experienceController,
                      label: 'Exp (Years)',
                      icon: Icons.work_history_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 2: Clinic & Fee
              _buildSectionHeader('2. Practice & Fee Structure', Icons.local_hospital_outlined),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _clinicNameController,
                      label: 'Clinic / Hospital Name',
                      icon: Icons.business_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Clinic name required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _feeController,
                      label: 'Fee (₹)',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Fee required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _clinicAddressController,
                label: 'Clinic Address',
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Address required' : null,
              ),

              const SizedBox(height: 24),

              // Section 3: Medical Licensing & Document Uploads
              _buildSectionHeader('3. License & Document Verification', Icons.assignment_turned_in_outlined),
              const SizedBox(height: 6),
              const Text(
                'Requirements per Medical Council of India (MCI / NMC) rules for online practice.',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _licenseNoController,
                      label: 'Medical Registration No',
                      icon: Icons.badge_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'License No required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateCouncilController,
                      label: 'State Medical Council',
                      icon: Icons.account_balance_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Council name required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _qualCertUrlController,
                label: 'Qualification Degree Certificate Image URL',
                icon: Icons.insert_drive_file_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Degree proof URL required' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _idProofUrlController,
                label: 'Identity Proof (Aadhaar / Passport) URL',
                icon: Icons.verified_user_rounded,
                validator: (v) => v == null || v.isEmpty ? 'ID proof URL required' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _clinicProofUrlController,
                label: 'Clinic Establishment / Address Proof URL',
                icon: Icons.file_present_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Clinic proof URL required' : null,
              ),

              const SizedBox(height: 32),

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
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Submit Doctor Registration',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
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
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
