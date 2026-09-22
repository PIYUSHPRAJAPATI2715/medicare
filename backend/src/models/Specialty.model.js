const mongoose = require('mongoose');

const specialtySchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    icon: { type: String, default: 'medical_services_rounded' },
    bgColorHex: { type: String, default: '#EBF5FF' },
    iconColorHex: { type: String, default: '#1A56DB' },
    doctorCount: { type: Number, default: 0 },
    description: { type: String },
    commonSymptoms: [{ type: String }],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Specialty', specialtySchema);
