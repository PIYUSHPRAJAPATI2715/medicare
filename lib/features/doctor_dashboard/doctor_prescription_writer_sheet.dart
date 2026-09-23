import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../models/prescription_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prescription_provider.dart';

class DoctorPrescriptionWriterSheet extends ConsumerStatefulWidget {
  final DoctorModel doctor;
  final String? initialDiagnosis;
  final VoidCallback? onPrescriptionSent;

  const DoctorPrescriptionWriterSheet({
    super.key,
    required this.doctor,
    this.initialDiagnosis,
    this.onPrescriptionSent,
  });

  static Future<PrescriptionModel?> show(
    BuildContext context, {
    required DoctorModel doctor,
    String? initialDiagnosis,
  }) {
    return showModalBottomSheet<PrescriptionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DoctorPrescriptionWriterSheet(
        doctor: doctor,
        initialDiagnosis: initialDiagnosis,
      ),
    );
  }

  @override
  ConsumerState<DoctorPrescriptionWriterSheet> createState() =>
      _DoctorPrescriptionWriterSheetState();
}

class _DoctorPrescriptionWriterSheetState
    extends ConsumerState<DoctorPrescriptionWriterSheet> {
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;
  late TextEditingController _adviceController;

  final List<PrescribedMedicine> _medicines = [];
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 5));

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController(
      text: widget.initialDiagnosis ??
          'Upper Respiratory Tract Infection with Fever & Pharyngitis',
    );
    _notesController = TextEditingController(
      text:
          'Patient presented with throat irritation, mild fever, and dry cough. Chest auscultation clear. Throat mildly hyperemic.',
    );
    _adviceController = TextEditingController(
      text:
          'Take steam inhalation twice daily. Drink warm water throughout the day. Rest well and complete the full antibiotic course.',
    );

    // Initial default medicines
    _medicines.addAll([
      const PrescribedMedicine(
        id: 'med_draft_1',
        name: 'Augmentin 625 Duo',
        genericName: 'Amoxycillin (500mg) + Clavulanic Acid (125mg)',
        dosage: '625 mg',
        frequency: '1-0-1 (Twice Daily)',
        instructions: 'After meals with full glass of water',
        durationDays: 5,
        quantity: 10,
        unit: 'Tablets',
        unitPrice: 204.0,
      ),
      const PrescribedMedicine(
        id: 'med_draft_2',
        name: 'Dolo 650 Tablets',
        genericName: 'Paracetamol',
        dosage: '650 mg',
        frequency: '1-0-1 (SOS for fever > 100°F)',
        instructions: 'After meals',
        durationDays: 3,
        quantity: 15,
        unit: 'Tablets',
        unitPrice: 33.5,
      ),
      const PrescribedMedicine(
        id: 'med_draft_3',
        name: 'Allegra 120mg',
        genericName: 'Fexofenadine',
        dosage: '120 mg',
        frequency: '0-0-1 (Once daily at bedtime)',
        instructions: 'Take before sleeping with warm water',
        durationDays: 5,
        quantity: 10,
        unit: 'Tablets',
        unitPrice: 198.0,
      ),
    ]);
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  void _addMedicineDialog() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '500 mg');
    String frequency = '1-0-1';
    String instructions = 'After food';
    int days = 5;
    double price = 120.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.medication_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Add Medicine', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name & Strength',
                    hintText: 'e.g. Azithromycin 500mg',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    hintText: 'e.g. 500 mg or 10 ml',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Frequency (Morning-Noon-Night)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ['1-0-1', '1-1-1', '1-0-0', '0-0-1', 'SOS'].map((f) {
                    final isSel = frequency == f;
                    return ChoiceChip(
                      label: Text(f),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setDialogState(() => frequency = f);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Food Timing',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ['After food', 'Before food', 'At bedtime'].map((i) {
                    final isSel = instructions == i;
                    return ChoiceChip(
                      label: Text(i),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setDialogState(() => instructions = i);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: days,
                      items: [3, 5, 7, 10, 14, 30]
                          .map((d) => DropdownMenuItem(value: d, child: Text('$d Days')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => days = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  _medicines.add(
                    PrescribedMedicine(
                      id: 'med_custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      genericName: name,
                      dosage: dosageCtrl.text.trim(),
                      frequency: frequency,
                      instructions: instructions,
                      durationDays: days,
                      quantity: days * 2,
                      unit: 'Tablets',
                      unitPrice: price,
                    ),
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add to Rx'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPrescription() {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a clinical diagnosis')),
      );
      return;
    }

    final newRx = ref.read(prescriptionProvider.notifier).submitDoctorPrescription(
          doctor: widget.doctor,
          diagnosis: _diagnosisController.text.trim(),
          clinicalNotes: _notesController.text.trim(),
          adviceNotes: _adviceController.text.trim(),
          medicines: _medicines,
          followUpDate: _followUpDate,
        );

    widget.onPrescriptionSent?.call();

    Navigator.pop(context, newRx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0E9F6E),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Prescription #${newRx.id} digitally signed and delivered to patient!',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(authProvider).user;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEF7EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: Color(0xFF0E9F6E), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doctor Prescription Writer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.doctor.name} • ${widget.doctor.specialty}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 20 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient metadata pill
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            patient.name.isNotEmpty ? patient.name[0] : 'P',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient: ${patient.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${patient.gender ?? "Male"} • 30 Yrs • Session: Today',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'CONS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 1: Diagnosis
                  _sectionTitle('1. Clinical Diagnosis & Impression'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _diagnosisController,
                    decoration: InputDecoration(
                      hintText: 'Enter clinical diagnosis...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 2: Clinical Findings & Notes
                  _sectionTitle('2. Doctor Clinical Observations'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Observations, vitals, examination notes...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 3: Prescribed Medicines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('3. Prescribed Medications (${_medicines.length})'),
                      TextButton.icon(
                        onPressed: _addMedicineDialog,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Medicine',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ..._medicines.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final med = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.medication_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        med.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${med.durationDays} Days',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dosage: ${med.dosage} • Frequency: ${med.frequency}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Instructions: ${med.instructions}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.redAccent, size: 18),
                            onPressed: () {
                              setState(() => _medicines.removeAt(idx));
                            },
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Section 4: Advice Notes
                  _sectionTitle('4. Doctor Advice & Dietary Guidelines'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _adviceController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Diet, hydration, activity instructions...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 5: Follow up date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _followUpDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _followUpDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 18, color: AppColors.primary),
                              SizedBox(width: 10),
                              Text('Follow-up Review:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(_followUpDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit_calendar_rounded,
                                  size: 16, color: AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Digital Signature Stamp Preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded,
                            color: Color(0xFF16A34A), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Digital Signature Seal: ${widget.doctor.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: Color(0xFF14532D),
                                ),
                              ),
                              Text(
                                'RMC-${40000 + widget.doctor.experienceYears * 412} • Certified MCI e-Prescription Token',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign & Deliver Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E9F6E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _submitPrescription,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Sign & Deliver Prescription to Patient',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
