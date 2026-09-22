import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'models/user_model.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/shell/main_shell_screen.dart';
import 'features/specialties/specialty_list_screen.dart';
import 'features/doctors/doctor_list_screen.dart';
import 'features/doctors/doctor_detail_screen.dart';
import 'features/booking/booking_screen.dart';
import 'features/booking/payment_screen.dart';
import 'features/booking/booking_confirmation_screen.dart';
import 'features/consultation/video_call_screen.dart';
import 'features/consultation/audio_call_screen.dart';
import 'features/chat/doctor_chat_screen.dart';
import 'features/appointments/appointments_history_screen.dart';
import 'features/account/edit_profile_screen.dart';
import 'features/account/care_plan_screen.dart';
import 'features/account/notifications_screen.dart';
import 'features/account/help_support_screen.dart';
import 'features/auth/doctor_registration_screen.dart';
import 'features/doctor_dashboard/doctor_dashboard_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MediCareApp(),
    ),
  );
}

class MediCareApp extends StatelessWidget {
  const MediCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.signup:
            final role = settings.arguments as UserRole? ?? UserRole.patient;
            return MaterialPageRoute(builder: (_) => SignupScreen(initialRole: role));
          case AppRoutes.mainShell:
            return MaterialPageRoute(builder: (_) => const MainShellScreen());
          case AppRoutes.specialties:
            return MaterialPageRoute(builder: (_) => const SpecialtyListScreen());
          case AppRoutes.doctorList:
            return MaterialPageRoute(builder: (_) => const DoctorListScreen());
          case AppRoutes.doctorDetail:
            final doctorId = settings.arguments as String? ?? 'doc_vipin';
            return MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: doctorId));
          case AppRoutes.booking:
            return MaterialPageRoute(builder: (_) => const BookingScreen());
          case AppRoutes.payment:
            return MaterialPageRoute(builder: (_) => const PaymentScreen());
          case AppRoutes.appointmentConfirmation:
            return MaterialPageRoute(builder: (_) => const BookingConfirmationScreen());
          case AppRoutes.videoCall:
            return MaterialPageRoute(builder: (_) => const VideoCallScreen());
          case AppRoutes.audioCall:
            return MaterialPageRoute(builder: (_) => const AudioCallScreen());
          case AppRoutes.chat:
            return MaterialPageRoute(builder: (_) => const DoctorChatScreen());
          case AppRoutes.appointmentsHistory:
            return MaterialPageRoute(builder: (_) => const AppointmentsHistoryScreen());
          case AppRoutes.editProfile:
            return MaterialPageRoute(builder: (_) => const EditProfileScreen());
          case AppRoutes.carePlan:
            return MaterialPageRoute(builder: (_) => const CarePlanScreen());
          case AppRoutes.notifications:
            return MaterialPageRoute(builder: (_) => const NotificationsScreen());
          case AppRoutes.helpSupport:
            return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
          case AppRoutes.doctorDashboard:
            return MaterialPageRoute(builder: (_) => const DoctorDashboardScreen());
          case AppRoutes.doctorRegister:
            return MaterialPageRoute(builder: (_) => const DoctorRegistrationScreen());
          case AppRoutes.adminDashboard:
            return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

          default:
            return MaterialPageRoute(builder: (_) => const MainShellScreen());
        }
      },
    );
  }
}
