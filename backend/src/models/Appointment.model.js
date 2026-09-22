const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema(
  {
    patientName: { type: String, required: true },
    patientPhone: { type: String },
    doctorName: { type: String, required: true },
    doctorId: { type: String, required: true },
    specialty: { type: String },
    date: { type: String, required: true },
    timeSlot: { type: String, required: true },
    type: { type: String, enum: ['video', 'inPerson'], default: 'video' },
    status: { type: String, enum: ['upcoming', 'completed', 'cancelled'], default: 'upcoming' },
    fee: { type: Number, required: true },
    channelName: { type: String },
    prescription: {
      diagnosis: { type: String },
      medicines: [{ type: String }],
      notes: { type: String },
      issuedAt: { type: Date },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Appointment', appointmentSchema);
