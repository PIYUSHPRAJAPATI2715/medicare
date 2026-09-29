import { getPrescriptions, addPrescription, getStore, saveStore } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const id = req.query.id || req.body?.id;
  const action = req.query.action || req.body?.action;
  const pathPart = (req.url || '').split('?')[0];

  // 1. GET: Fetch prescriptions
  if (req.method === 'GET') {
    const list = getPrescriptions();
    if (id) {
      const rx = list.find(r => r.id === id);
      if (!rx) {
        return res.status(404).json({
          status: 404,
          statusCode: 404,
          success: false,
          message: 'Prescription not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Prescription retrieved successfully',
        data: rx,
      });
    }

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      count: list.length,
      message: 'Prescriptions list retrieved',
      data: list,
    });
  }

  // 2. POST /order-pharmacy: Order medicines from digital prescription
  if (action === 'order-pharmacy' || pathPart.endsWith('/order-pharmacy')) {
    const store = getStore();
    const rx = store.prescriptions.find(r => r.id === id);
    if (!rx) {
      return res.status(404).json({
        status: 404,
        statusCode: 404,
        success: false,
        message: 'Prescription not found to order',
        data: null,
      });
    }

    rx.pharmacyStatus = 'orderConfirmed';
    rx.fulfillmentType = 'orderedOnline';
    saveStore(store);

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Medicines ordered successfully! Pharmacy delivery dispatched.',
      data: rx,
    });
  }

  // 3. POST: Create prescription
  if (req.method === 'POST') {
    const newRx = addPrescription(req.body || {});
    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'Prescription issued successfully',
      data: newRx,
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
