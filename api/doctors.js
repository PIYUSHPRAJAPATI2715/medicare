import { getDoctors, addDoctor, verifyDoctor, getStore, saveStore } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const id = req.query.id || req.body?.id;
  const isPending = req.query.pending === 'true' || req.url.includes('/pending');

  // GET: Doctors list or single doctor
  if (req.method === 'GET') {
    if (id) {
      const doctors = getDoctors({ all: 'true' });
      const doc = doctors.find(d => d.id === id);
      if (!doc) {
        return res.status(404).json({
          status: 404,
          statusCode: 404,
          success: false,
          message: 'Doctor not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Doctor profile retrieved',
        data: { doctor: doc },
      });
    }

    if (isPending) {
      const pendingList = getDoctors({ pending: 'true' });
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        count: pendingList.length,
        message: 'Pending doctor approvals retrieved',
        data: pendingList,
      });
    }

    const docList = getDoctors(req.query);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      count: docList.length,
      message: 'Doctors list retrieved successfully',
      data: docList,
    });
  }

  // PUT: Verify or Update Doctor
  if (req.method === 'PUT') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'Doctor ID is required for update or verification',
        data: null,
      });
    }

    const { status, action, notes, rejectionNotes } = req.body || {};
    const effectiveAction = action || (status === 'approved' ? 'approve' : (status === 'rejected' ? 'reject' : null));

    if (effectiveAction) {
      const updated = verifyDoctor(id, effectiveAction, notes || rejectionNotes);
      if (!updated) {
        return res.status(404).json({
          status: 404,
          statusCode: 404,
          success: false,
          message: 'Doctor not found to verify',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: `Doctor status updated to ${updated.verificationStatus}`,
        data: updated,
      });
    }

    // General update
    const store = getStore();
    const idx = store.doctors.findIndex(d => d.id === id);
    if (idx === -1) {
      return res.status(404).json({
        status: 404,
        statusCode: 404,
        success: false,
        message: 'Doctor not found',
        data: null,
      });
    }

    store.doctors[idx] = { ...store.doctors[idx], ...req.body, id };
    saveStore(store);

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Doctor profile updated successfully',
      data: store.doctors[idx],
    });
  }

  // POST: Add new doctor
  if (req.method === 'POST') {
    const newDoc = addDoctor(req.body || {});
    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'Doctor added successfully',
      data: newDoc,
    });
  }

  // DELETE: Delete doctor
  if (req.method === 'DELETE') {
    if (!id) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'Doctor ID is required',
        data: null,
      });
    }

    const store = getStore();
    store.doctors = store.doctors.filter(d => d.id !== id);
    saveStore(store);

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Doctor deleted successfully',
      data: { id, deleted: true },
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
