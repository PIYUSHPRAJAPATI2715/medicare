import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../data/mock/mock_data.dart';
import '../services/api_service.dart';

class AuthState {
  final UserModel user;
  final bool isAuthenticated;
  final String currentCity;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.user,
    this.isAuthenticated = true,
    this.currentCity = 'Jaipur',
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    String? currentCity,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentCity: currentCity ?? this.currentCity,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(user: MockData.currentPatient);
  }

  /// Dynamic Login via REST API
  Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final res = await ApiService.login(
      emailOrPhone: emailOrPhone,
      password: password,
      role: role.name,
    );
    state = state.copyWith(isLoading: false);

    if (res['success'] == true && res['data'] != null && res['data']['user'] != null) {
      final user = UserModel.fromJson(res['data']['user']);
      state = state.copyWith(user: user, isAuthenticated: true);
    }

    return res;
  }

  /// Dynamic Patient Registration via REST API
  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
    String gender = 'Male',
    String dob = '1995-08-15',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final res = await ApiService.registerPatient(
      name: name,
      email: email,
      phone: phone,
      password: password,
      gender: gender,
      dob: dob,
      currentCity: state.currentCity,
    );
    state = state.copyWith(isLoading: false);

    if (res['success'] == true && res['data'] != null && res['data']['user'] != null) {
      final user = UserModel.fromJson(res['data']['user']);
      state = state.copyWith(user: user, isAuthenticated: true);
    }

    return res;
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
    final updated = state.user.copyWith(
      name: name,
      phone: phone,
      gender: gender,
      dob: dob,
    );
    state = state.copyWith(user: updated);

    // Sync to backend asynchronously
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (dob != null) data['dob'] = dob;
    ApiService.updateUserProfile(state.user.id, data);
  }

  /// Delete account permanently from backend
  Future<bool> deleteAccount() async {
    final success = await ApiService.deleteAccount(state.user.id);
    if (success) {
      state = state.copyWith(isAuthenticated: false);
    }
    return success;
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
