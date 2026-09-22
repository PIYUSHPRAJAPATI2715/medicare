import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import LoginPage from './pages/auth/LoginPage';

// Admin Pages
import AdminDashboardPage from './pages/admin/AdminDashboardPage';
import DoctorsApprovalPage from './pages/admin/DoctorsApprovalPage';
import UsersPage from './pages/admin/UsersPage';
import SpecialtiesPage from './pages/admin/SpecialtiesPage';
import HospitalsPage from './pages/admin/HospitalsPage';
import AppointmentsPage from './pages/admin/AppointmentsPage';
import SettingsPage from './pages/admin/SettingsPage';

// Doctor Pages
import DoctorDashboardPage from './pages/doctor/DoctorDashboardPage';
import DoctorAppointmentsPage from './pages/doctor/DoctorAppointmentsPage';
import VideoCallRoomPage from './pages/doctor/VideoCallRoomPage';

function ProtectedLayout({ children }) {
  const { user } = useAuth();
  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="flex min-h-screen bg-slate-50">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <Navbar />
        <main className="p-6 flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Public Auth */}
          <Route path="/login" element={<LoginPage />} />

          {/* Admin Routes */}
          <Route path="/admin/dashboard" element={<ProtectedLayout><AdminDashboardPage /></ProtectedLayout>} />
          <Route path="/admin/doctors" element={<ProtectedLayout><DoctorsApprovalPage /></ProtectedLayout>} />
          <Route path="/admin/users" element={<ProtectedLayout><UsersPage /></ProtectedLayout>} />
          <Route path="/admin/specialties" element={<ProtectedLayout><SpecialtiesPage /></ProtectedLayout>} />
          <Route path="/admin/hospitals" element={<ProtectedLayout><HospitalsPage /></ProtectedLayout>} />
          <Route path="/admin/appointments" element={<ProtectedLayout><AppointmentsPage /></ProtectedLayout>} />
          <Route path="/admin/settings" element={<ProtectedLayout><SettingsPage /></ProtectedLayout>} />

          {/* Doctor Routes */}
          <Route path="/doctor/dashboard" element={<ProtectedLayout><DoctorDashboardPage /></ProtectedLayout>} />
          <Route path="/doctor/appointments" element={<ProtectedLayout><DoctorAppointmentsPage /></ProtectedLayout>} />
          <Route path="/doctor/video-call/:channelName" element={<ProtectedLayout><VideoCallRoomPage /></ProtectedLayout>} />

          {/* Default Fallback */}
          <Route path="*" element={<Navigate to="/admin/dashboard" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}
