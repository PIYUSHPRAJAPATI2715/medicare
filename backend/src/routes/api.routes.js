const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const agoraController = require('../controllers/agora.controller');

// --- AGORA TOKEN ENDPOINTS ---
router.get('/agora/config', agoraController.getAgoraConfig);
router.post('/agora/rtc-token', agoraController.generateRtcToken);
router.post('/agora/rtm-token', agoraController.generateRtmToken);

// --- ANALYTICS ---
router.get('/analytics', adminController.getAnalytics);

// --- AUTH & REGISTRATION ---
router.post('/auth/login', adminController.authLogin);
router.post('/auth/signup', adminController.registerPatient);
router.post('/auth/register-patient', adminController.registerPatient);
router.post('/auth/doctor-register', adminController.registerDoctor);
router.get('/auth/doctor-status/:id', adminController.getDoctorStatus);
router.delete('/auth/delete-account/:id', adminController.deleteUser);

// --- USERS & PROFILE ---
router.get('/users', adminController.getUsers);
router.get('/users/:id', adminController.getUserProfile);
router.post('/users', adminController.createUser);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// --- DOCTOR VERIFICATION & DIRECTORY ---
router.get('/doctors', adminController.getDoctors);
router.get('/doctors/pending', adminController.getPendingDoctors);
router.get('/doctors/:id', adminController.getDoctorById);
router.put('/doctors/:id/verify', adminController.verifyDoctor);
router.post('/doctors', adminController.createDoctor);
router.put('/doctors/:id', adminController.updateDoctor);
router.delete('/doctors/:id', adminController.deleteDoctor);

// --- SPECIALTIES ---
router.get('/specialties', adminController.getSpecialties);
router.post('/specialties', adminController.createSpecialty);
router.put('/specialties/:id', adminController.updateSpecialty);
router.delete('/specialties/:id', adminController.deleteSpecialty);

// --- DISEASES & SYMPTOMS ---
router.get('/diseases', adminController.getDiseases);
router.post('/diseases', adminController.createDisease);

// --- HOSPITALS ---
router.get('/hospitals', adminController.getHospitals);
router.post('/hospitals', adminController.createHospital);
router.put('/hospitals/:id', adminController.updateHospital);
router.delete('/hospitals/:id', adminController.deleteHospital);

// --- CARE PLANS & SUBSCRIPTIONS ---
router.get('/plans', adminController.getPlans);
router.post('/plans', adminController.createPlan);
router.put('/plans/:id', adminController.updatePlan);
router.delete('/plans/:id', adminController.deletePlan);
router.get('/subscriptions/:userId', adminController.getUserSubscription);
router.post('/subscriptions/purchase', adminController.purchaseSubscription);
router.post('/subscriptions/cancel', adminController.cancelSubscription);

// --- HEALTHPAY WALLET & TRANSACTIONS ---
router.get('/wallet/:userId', adminController.getWallet);
router.post('/wallet/topup', adminController.topupWallet);
router.post('/wallet/pay', adminController.payWithWallet);

// --- PAYMENTS & GATEWAY INTEGRATION ---
router.post('/payments/create-order', adminController.createPaymentOrder);
router.post('/payments/verify-success', adminController.verifyPaymentSuccess);

// --- APPOINTMENTS & TELECONSULTATION ---
router.get('/appointments', adminController.getAppointments);
router.post('/appointments', adminController.createAppointment);
router.put('/appointments/:id', adminController.updateAppointment);

// --- PRESCRIPTIONS & PHARMACY ORDERS ---
router.get('/prescriptions', adminController.getPrescriptions);
router.get('/prescriptions/:id', adminController.getPrescriptionById);
router.post('/prescriptions', adminController.createPrescription);
router.post('/prescriptions/:id/order-pharmacy', adminController.orderPharmacyPrescription);

// --- CHATS ---
router.get('/chats', adminController.getChats);
router.post('/chats', adminController.sendChatMessage);

// --- SETTINGS & COUPONS ---
router.get('/settings', adminController.getSettings);
router.put('/settings', adminController.updateSettings);
router.post('/coupons', adminController.addCoupon);
router.delete('/coupons/:code', adminController.deleteCoupon);

module.exports = router;
