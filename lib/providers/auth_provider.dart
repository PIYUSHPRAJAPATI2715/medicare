import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../data/mock/mock_data.dart';

class AuthState {
  final UserModel user;
  final bool isAuthenticated;
  final String currentCity;

  const AuthState({
    required this.user,
    this.isAuthenticated = true,
    this.currentCity = 'Jaipur',
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    String? currentCity,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentCity: currentCity ?? this.currentCity,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(user: MockData.currentPatient);
  }

  void loginAsPatient() {
    state = state.copyWith(
      user: MockData.currentPatient,
      isAuthenticated: true,
    );
  }

  void loginAsDoctor() {
    state = state.copyWith(
      user: MockData.currentDoctor,
      isAuthenticated: true,
    );
  }

  void switchRole(UserRole role) {
    if (role == UserRole.doctor) {
      state = state.copyWith(user: MockData.currentDoctor);
    } else if (role == UserRole.patient) {
      state = state.copyWith(user: MockData.currentPatient);
    } else {
      state = state.copyWith(
        user: const UserModel(
          id: 'admin_001',
          name: 'System Administrator',
          email: 'admin@medicare.com',
          phone: '+91 99999 00000',
          role: UserRole.admin,
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
        ),
      );
    }
  }

  void toggleDoctorAvailability() {
    if (state.user.role == UserRole.doctor) {
      final current = state.user.isDoctorAvailable;
      state = state.copyWith(
        user: state.user.copyWith(isDoctorAvailable: !current),
      );
    }
  }

  void updateCity(String newCity) {
    state = state.copyWith(currentCity: newCity);
  }

  void updateProfile({String? name, String? phone, String? gender, String? dob}) {
    state = state.copyWith(
      user: state.user.copyWith(
        name: name,
        phone: phone,
        gender: gender,
        dob: dob,
      ),
    );
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
