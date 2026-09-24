import { initialAppointments, initialDoctors } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  const id = req.query.id || req.body?.id;

  // GET: appointments
  if (req.method === 'GET') {
    if (id) {
      const apt = initialAppointments.find(a => a.id === id);
      if (!apt) {
        return res.status(404).json({
          status: 404,
          success: false,
          message: 'Appointment not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        success: true,
        message: 'Appointment details retrieved',
        data: apt,
      });
    }

    const { userId, doctorId } = req.query;
    let list = [...initialAppointments];

    if (userId) {
      list = list.filter(a => a.userId === userId || a.patientName?.toLowerCase().includes('piyush'));
    }
    if (doctorId) {
      list = list.filter(a => a.doctorId === doctorId);
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Appointments list retrieved successfully',
      count: list.length,
      data: list,
    });
  }

  // POST: book new appointment
  if (req.method === 'POST') {
    const data = req.body || {};
    const doctor = initialDoctors.find(d => d.id === data.doctorId);

    const newApt = {
      id: `apt_${Date.now()}`,
      userId: data.userId || 'u1',
      doctorId: data.doctorId || 'd1',
      patientName: data.patientName || 'Piyush Prajapati',
      doctorName: data.doctorName || doctor?.name || 'Dr. Rajesh Sharma',
      specialty: data.specialty || doctor?.specialty || 'General Physician',
      date: data.date || new Date().toISOString().split('T')[0],
      time: data.time || data.timeSlot || '10:30 AM',
      type: data.type || 'video',
      status: 'upcoming',
      fee: data.fee || doctor?.consultationFee || 499,
      platformFee: 49,
      taxes: 98.64,
      totalAmount: (data.fee || 499) + 49 + 98.64,
      createdAt: new Date().toISOString(),
    };

    initialAppointments.unshift(newApt);

    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Appointment booked successfully!',
      data: newApt,
    });
  }

  // PUT: update or cancel appointment
  if (req.method === 'PUT') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'Appointment ID is required for update',
        data: null,
      });
    }

    const idx = initialAppointments.findIndex(a => a.id === id);
    if (idx === -1) {
      return res.status(404).json({
        status: 404,
        success: false,
        message: 'Appointment not found',
        data: null,
      });
    }

    initialAppointments[idx] = { ...initialAppointments[idx], ...req.body, id };

    return res.status(200).json({
      status: 200,
      success: true,
      message: `Appointment ${id} updated successfully`,
      data: initialAppointments[idx],
    });
  }

  return res.status(405).json({
    status: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
