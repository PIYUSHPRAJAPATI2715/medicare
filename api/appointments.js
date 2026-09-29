import { getAppointments, addAppointment, getStore, saveStore } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const id = req.query.id || req.body?.id;
  const store = getStore();

  // GET: All or filtered appointments
  if (req.method === 'GET') {
    let list = getAppointments();
    const { userId, doctorId, status } = req.query;

    if (id) {
      const found = list.find(a => a.id === id);
      if (!found) {
        return res.status(404).json({
          status: 404,
          statusCode: 404,
          success: false,
          message: 'Appointment not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Appointment retrieved',
        data: found,
      });
    }

    if (userId) list = list.filter(a => a.userId === userId);
    if (doctorId) list = list.filter(a => a.doctorId === doctorId);
    if (status) list = list.filter(a => a.status === status);

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      count: list.length,
      message: 'Appointments retrieved successfully',
      data: list,
    });
  }

  // POST: Create new appointment
  if (req.method === 'POST') {
    const newApt = addAppointment(req.body || {});
    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'Appointment scheduled successfully',
      data: newApt,
    });
  }

  // PUT: Update appointment
  if (req.method === 'PUT') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'Appointment ID is required to update',
        data: null,
      });
    }

    const idx = store.appointments.findIndex(a => a.id === id);
    if (idx === -1) {
      return res.status(404).json({
        status: 404,
        statusCode: 404,
        success: false,
        message: 'Appointment not found',
        data: null,
      });
    }

    store.appointments[idx] = { ...store.appointments[idx], ...req.body, id };
    saveStore(store);

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Appointment updated successfully',
      data: store.appointments[idx],
    });
  }

  return res.status(405).json({
    status: 405,
    statusCode: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
