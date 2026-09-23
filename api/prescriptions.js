const defaultPrescriptions = [
  {
    id: 'RX-84920',
    consultationId: 'CONS-9482',
    doctorName: 'Dr. Vipin Kumar Jain',
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

  if (req.method === 'POST') {
    const newRx = { id: `RX-${Date.now().toString().slice(-5)}`, ...req.body };
    defaultPrescriptions.unshift(newRx);
    return res.status(201).json({ success: true, data: newRx });
  }

  return res.status(200).json({
    success: true,
    count: defaultPrescriptions.length,
    data: defaultPrescriptions,
  });
}
