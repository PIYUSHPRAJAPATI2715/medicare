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

// --- USERS ---
router.get('/users', adminController.getUsers);
router.post('/users', adminController.createUser);
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// --- DOCTORS ---
router.get('/doctors', adminController.getDoctors);
router.post('/doctors', adminController.createDoctor);
router.put('/doctors/:id', adminController.updateDoctor);
router.delete('/doctors/:id', adminController.deleteDoctor);

// --- SPECIALTIES ---
router.get('/specialties', adminController.getSpecialties);
router.post('/specialties', adminController.createSpecialty);
router.put('/specialties/:id', adminController.updateSpecialty);
router.delete('/specialties/:id', adminController.deleteSpecialty);

// --- HOSPITALS ---
router.get('/hospitals', adminController.getHospitals);
router.post('/hospitals', adminController.createHospital);
router.put('/hospitals/:id', adminController.updateHospital);
router.delete('/hospitals/:id', adminController.deleteHospital);

// --- APPOINTMENTS ---
router.get('/appointments', adminController.getAppointments);
router.post('/appointments', adminController.createAppointment);
router.put('/appointments/:id', adminController.updateAppointment);

// --- CHATS ---
router.get('/chats', adminController.getChats);
router.post('/chats', adminController.sendChatMessage);

// --- SETTINGS & COUPONS ---
router.get('/settings', adminController.getSettings);
router.put('/settings', adminController.updateSettings);
router.post('/coupons', adminController.addCoupon);
router.delete('/coupons/:code', adminController.deleteCoupon);

module.exports = router;
