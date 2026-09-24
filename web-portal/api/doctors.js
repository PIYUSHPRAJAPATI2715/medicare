import { initialDoctors } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  const id = req.query.id || req.body?.id;

  // GET: single doctor or all doctors
  if (req.method === 'GET') {
    if (id) {
      const doctor = initialDoctors.find(d => d.id === id);
      if (!doctor) {
        return res.status(404).json({
          status: 404,
          success: false,
          message: 'Doctor not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        success: true,
        message: 'Doctor details retrieved successfully',
        data: doctor,
      });
    }

    const { status, specialty, all } = req.query;
    let list = [...initialDoctors];

    if (all !== 'true' && !status) {
      // By default return approved doctors for app users
      list = list.filter(d => d.isVerified && d.verificationStatus === 'approved');
    } else if (status) {
      list = list.filter(d => d.verificationStatus === status);
    }

    if (specialty) {
      list = list.filter(d => d.specialty.toLowerCase() === specialty.toLowerCase());
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Doctors list retrieved successfully',
      count: list.length,
      data: list,
    });
  }

  // PUT: update or verify doctor
  if (req.method === 'PUT') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'Doctor ID is required for update',
        data: null,
      });
    }

    const idx = initialDoctors.findIndex(d => d.id === id);
    if (idx === -1) {
      return res.status(404).json({
        status: 404,
        success: false,
        message: 'Doctor not found to update',
        data: null,
      });
    }

    const { action, rejectionReason } = req.body || {};

    if (action === 'approve') {
      initialDoctors[idx].isVerified = true;
      initialDoctors[idx].verificationStatus = 'approved';
      initialDoctors[idx].rejectionReason = null;
      return res.status(200).json({
        status: 200,
        success: true,
        message: `Doctor ${initialDoctors[idx].name} verified and approved successfully!`,
        data: initialDoctors[idx],
      });
    }

    if (action === 'reject') {
      initialDoctors[idx].isVerified = false;
      initialDoctors[idx].verificationStatus = 'rejected';
      initialDoctors[idx].rejectionReason = rejectionReason || 'Incomplete credentials';
      return res.status(200).json({
        status: 200,
        success: true,
        message: `Doctor ${initialDoctors[idx].name} registration rejected.`,
        data: initialDoctors[idx],
      });
    }

    initialDoctors[idx] = { ...initialDoctors[idx], ...req.body, id };

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Doctor updated successfully',
      data: initialDoctors[idx],
    });
  }

  // DELETE: delete doctor
  if (req.method === 'DELETE') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'Doctor ID is required for deletion',
        data: null,
      });
    }

    const idx = initialDoctors.findIndex(d => d.id === id);
    if (idx !== -1) {
      initialDoctors.splice(idx, 1);
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Doctor removed successfully from MediCare+',
      data: { id, deleted: true },
    });
  }

  // POST: create doctor
  if (req.method === 'POST') {
    const newDoc = { id: `d_${Date.now()}`, ...req.body };
    initialDoctors.unshift(newDoc);
    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Doctor created successfully',
      data: newDoc,
    });
  }

  return res.status(405).json({
    status: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
