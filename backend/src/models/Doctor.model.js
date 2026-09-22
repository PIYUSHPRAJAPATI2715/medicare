const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String },
    phone: { type: String },
    specialty: { type: String, required: true },
    qualification: { type: String, required: true },
    experienceYears: { type: Number, default: 5 },
    ratingPercentage: { type: Number, default: 95.0 },
    patientStoriesCount: { type: Number, default: 12 },
    consultationFee: { type: Number, required: true },
    languages: [{ type: String }],
    isOnline: { type: Boolean, default: true },
    imageUrl: { type: String },
    clinicName: { type: String, required: true },
    clinicAddress: { type: String, required: true },
    distanceKm: { type: Number, default: 1.5 },
    nextAvailableSlot: { type: String, default: 'Today, 04:00 PM' },
    aboutText: { type: String },
    services: [{ type: String }],
    education: [{ type: String }],
    experienceHistory: [{ type: String }],
    allowsPhysical: { type: Boolean, default: true },
    allowsVideo: { type: Boolean, default: true },

    // Medical Licensing & Admin Document Verification Fields
    medicalLicenseNo: { type: String },
    stateMedicalCouncil: { type: String },
    qualificationCertUrl: { type: String },
    idProofUrl: { type: String },
    clinicAddressProofUrl: { type: String },
    verificationStatus: {
      type: String,
      enum: ['approved', 'pending', 'rejected'],
      default: 'approved',
    },
    rejectionReason: { type: String, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Doctor', doctorSchema);
