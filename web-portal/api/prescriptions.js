const defaultPrescriptions = [
  {
    id: 'RX-84920',
    consultationId: 'CONS-9482',
    doctorName: 'Dr. Rajesh Sharma',
    doctorSpecialty: 'General Physician',
    patientName: 'Piyush Prajapati',
    patientPhone: '+91 98765 43210',
    patientAddress: 'Flat 402, Sunshine Heights, Malviya Nagar, Jaipur - 302017',
    diagnosis: 'Acute Upper Respiratory Tract Infection & Mild Bronchial Congestion',
    medicines: [
      { name: 'Augmentin 625 Duo', qty: '10 Tabs', dosage: '625 mg', price: 204.0 },
      { name: 'Dolo 650', qty: '15 Tabs', dosage: '650 mg', price: 33.5 },
      { name: 'Allegra 120mg', qty: '10 Tabs', dosage: '120 mg', price: 198.0 },
      { name: 'Alex Cough Syrup', qty: '1 Bottle', dosage: '100 ml', price: 145.0 }
    ],
    totalAmount: 495.5,
    issuedAt: 'Today, 02:15 PM',
    fulfillmentType: 'orderedOnline',
    pharmacyStatus: 'outForDelivery'
  }
];

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  const id = req.query.id || req.body?.id;

  if (req.method === 'GET') {
    if (id) {
      const rx = defaultPrescriptions.find(p => p.id === id);
      if (!rx) {
        return res.status(404).json({
          status: 404,
          success: false,
          message: 'Prescription not found',
          data: null,
        });
      }
      return res.status(200).json({
        status: 200,
        success: true,
        message: 'Prescription details retrieved',
        data: rx,
      });
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Prescriptions retrieved successfully',
      count: defaultPrescriptions.length,
      data: defaultPrescriptions,
    });
  }

  if (req.method === 'POST') {
    const { action, address } = req.body || {};

    if (action === 'order-pharmacy' && id) {
      const idx = defaultPrescriptions.findIndex(p => p.id === id);
      if (idx !== -1) {
        defaultPrescriptions[idx].pharmacyStatus = 'dispatched';
        defaultPrescriptions[idx].fulfillmentType = 'orderedOnline';
        defaultPrescriptions[idx].patientAddress = address || defaultPrescriptions[idx].patientAddress;
      }
      return res.status(200).json({
        status: 200,
        success: true,
        message: 'Prescription sent to pharmacy for home delivery!',
        data: defaultPrescriptions[idx] || null,
      });
    }

    const newRx = {
      id: `RX-${Date.now().toString().slice(-5)}`,
      ...req.body,
      issuedAt: 'Just now',
    };
    defaultPrescriptions.unshift(newRx);

    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Prescription generated successfully',
      data: newRx,
    });
  }

  return res.status(405).json({
    status: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
