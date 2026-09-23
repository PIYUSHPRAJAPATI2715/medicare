const defaultPlans = [
  {
    id: 'plan_starter',
    name: 'Starter Care Pass',
    tagline: 'Ideal for immediate doctor consultation & quick recovery',
    price: 199,
    originalPrice: 499,
    durationDays: 30,
    durationLabel: '1 Month',
    consultationLimit: 3,
    isPopular: false,
    badgeText: 'AFFORDABLE',
    isActive: true,
    subscribersCount: 1420,
    features: [
      '3 Video or Audio Consultations with top doctors',
      '24/7 Unlimited Doctor Chat & Follow-ups',
      'Official Digital Prescriptions with instant download',
      '10% Flat Discount on all pharmacy tablet orders',
      'Free home medicine delivery on orders above ₹199'
    ]
  },
  {
    id: 'plan_gold',
    name: 'Gold Family Shield',
    tagline: 'Complete year-round coverage for up to 4 family members',
    price: 699,
    originalPrice: 1999,
    durationDays: 180,
    durationLabel: '6 Months',
    consultationLimit: -1,
    isPopular: true,
    badgeText: 'MOST POPULAR',
    isActive: true,
    subscribersCount: 3840,
    features: [
      'Unlimited 24/7 Video & Audio Consultations',
      'Direct connection to MD Specialists & Super-specialists',
      'Family coverage for up to 4 family profiles',
      'Instant Electronic Rx with Priority Pharmacy Dispatch',
      '20% Off all prescribed tablets & medicines',
      'Priority 2-hour doorstep tablet delivery',
      '₹0 Convenience fees on all appointments'
    ]
  },
  {
    id: 'plan_platinum',
    name: 'Platinum 365 SuperCare',
    tagline: 'Premium VIP medical access, full health checkups & 1-year coverage',
    price: 1299,
    originalPrice: 3499,
    durationDays: 365,
    durationLabel: '1 Year',
    consultationLimit: -1,
    isPopular: false,
    badgeText: 'BEST VALUE',
    isActive: true,
    subscribersCount: 2150,
    features: [
      'Unlimited Consultations for the entire year (365 Days)',
      'Full Comprehensive Annual Health Checkup Included (62 Tests)',
      'VIP Priority Doctor Routing within 60 seconds',
      'Dedicated Personal Health Care Manager',
      '25% Off on all prescribed medicines & diagnostic tests',
      'Free doorstep sample collection & free express delivery'
    ]
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
    const newPlan = { id: `plan_${Date.now()}`, ...req.body };
    defaultPlans.push(newPlan);
    return res.status(201).json({ success: true, data: newPlan });
  }

  return res.status(200).json({
    success: true,
    count: defaultPlans.length,
    data: defaultPlans,
  });
}
