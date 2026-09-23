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

function ProtectedLayout({ children, requiredRole }) {
  const { user } = useAuth();
  const [isMobileOpen, setIsMobileOpen] = React.useState(false);

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (requiredRole && user.role !== requiredRole) {
    return <Navigate to={user.role === 'doctor' ? '/doctor/dashboard' : '/admin/dashboard'} replace />;
  }

  return (
    <div className="flex min-h-screen bg-slate-50">
      <Sidebar isMobileOpen={isMobileOpen} onCloseMobile={() => setIsMobileOpen(false)} />
      <div className="flex-1 flex flex-col min-w-0">
        <Navbar onToggleMobileMenu={() => setIsMobileOpen(!isMobileOpen)} />
        <main className="p-4 sm:p-6 flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

function RootRedirect() {
  const { user } = useAuth();
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  return <Navigate to={user.role === 'doctor' ? '/doctor/dashboard' : '/admin/dashboard'} replace />;
}

export default function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Public Auth */}
          <Route path="/login" element={<LoginPage />} />

          {/* Root Redirect */}
          <Route path="/" element={<RootRedirect />} />

          {/* Admin Routes */}
          <Route path="/admin/dashboard" element={<ProtectedLayout requiredRole="admin"><AdminDashboardPage /></ProtectedLayout>} />
          <Route path="/admin/doctors" element={<ProtectedLayout requiredRole="admin"><DoctorsApprovalPage /></ProtectedLayout>} />
          <Route path="/admin/users" element={<ProtectedLayout requiredRole="admin"><UsersPage /></ProtectedLayout>} />
          <Route path="/admin/specialties" element={<ProtectedLayout requiredRole="admin"><SpecialtiesPage /></ProtectedLayout>} />
          <Route path="/admin/hospitals" element={<ProtectedLayout requiredRole="admin"><HospitalsPage /></ProtectedLayout>} />
          <Route path="/admin/appointments" element={<ProtectedLayout requiredRole="admin"><AppointmentsPage /></ProtectedLayout>} />
          <Route path="/admin/settings" element={<ProtectedLayout requiredRole="admin"><SettingsPage /></ProtectedLayout>} />

          {/* Doctor Routes */}
          <Route path="/doctor/dashboard" element={<ProtectedLayout requiredRole="doctor"><DoctorDashboardPage /></ProtectedLayout>} />
          <Route path="/doctor/appointments" element={<ProtectedLayout requiredRole="doctor"><DoctorAppointmentsPage /></ProtectedLayout>} />
          <Route path="/doctor/video-call/:channelName" element={<ProtectedLayout requiredRole="doctor"><VideoCallRoomPage /></ProtectedLayout>} />

          {/* Default Fallback */}
          <Route path="*" element={<RootRedirect />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}
