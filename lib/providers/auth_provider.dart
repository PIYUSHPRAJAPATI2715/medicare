import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../data/mock/mock_data.dart';
import '../services/api_service.dart';

class AuthState {
  final UserModel user;
  final bool isAuthenticated;
  final String currentCity;
  final bool isLoading;
  final String? errorMessage;
  final String? token;
  final bool isInitialized;

  const AuthState({
    required this.user,
    this.isAuthenticated = false,
    this.currentCity = 'Jaipur',
    this.isLoading = false,
    this.errorMessage,
    this.token,
    this.isInitialized = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    String? currentCity,
    bool? isLoading,
    String? errorMessage,
    String? token,
    bool? isInitialized,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentCity: currentCity ?? this.currentCity,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      token: token ?? this.token,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const String _prefTokenKey = 'medicare_auth_token';
  static const String _prefUserKey = 'medicare_auth_user';
  static const String _prefIsAuthKey = 'medicare_is_authenticated';

  @override
  AuthState build() {
    _restoreSavedSession();
    return AuthState(
      user: MockData.currentPatient,
      isAuthenticated: false,
      isInitialized: false,
    );
  }

  /// Automatically restore persistent user session and token on app launch
  Future<void> _restoreSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(_prefIsAuthKey) ?? false;
      final token = prefs.getString(_prefTokenKey);
      final userJsonStr = prefs.getString(_prefUserKey);

      if (isAuth && token != null && token.isNotEmpty && userJsonStr != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJsonStr);
        final user = UserModel.fromJson(userMap);
        ApiService.setAuthToken(token);
        state = state.copyWith(
          user: user,
          token: token,
          isAuthenticated: true,
          isInitialized: true,
        );
        debugPrint('✅ [AuthNotifier] Restored persistent session for: ${user.name} (${user.phone})');
        return;
      }
    } catch (e) {
      debugPrint('⚠️ [AuthNotifier] Error restoring session: $e');
    }
    state = state.copyWith(isInitialized: true);
  }

  /// Persist session token and user info into SharedPreferences
  Future<void> _persistSession(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefTokenKey, token);
      await prefs.setString(_prefUserKey, jsonEncode(user.toJson()));
      await prefs.setBool(_prefIsAuthKey, true);
      ApiService.setAuthToken(token);
      debugPrint('💾 [AuthNotifier] Session saved to SharedPreferences. Token: ${token.substring(0, token.length > 18 ? 18 : token.length)}...');
    } catch (e) {
      debugPrint('⚠️ [AuthNotifier] Error persisting session: $e');
    }
  }

  /// Clear session from SharedPreferences upon logout
  Future<void> _clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefTokenKey);
      await prefs.remove(_prefUserKey);
      await prefs.setBool(_prefIsAuthKey, false);
      ApiService.setAuthToken(null);
      debugPrint('🗑️ [AuthNotifier] Session cleared from SharedPreferences');
    } catch (e) {
      debugPrint('⚠️ [AuthNotifier] Error clearing session: $e');
    }
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
      final token = res['data']['token']?.toString() ??
          res['data']['authToken']?.toString() ??
          'jwt_live_${user.id}';

      await _persistSession(token, user);
      state = state.copyWith(user: user, token: token, isAuthenticated: true);
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
    String? avatarUrl,
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
      avatarUrl: avatarUrl,
    );
    state = state.copyWith(isLoading: false);

    if (res['success'] == true && res['data'] != null && res['data']['user'] != null) {
      final user = UserModel.fromJson(res['data']['user']);
      final token = res['data']['token']?.toString() ??
          res['data']['authToken']?.toString() ??
          'jwt_live_${user.id}';

      await _persistSession(token, user);
      state = state.copyWith(user: user, token: token, isAuthenticated: true);
    }

    return res;
  }

  void loginAsPatient() async {
    final user = MockData.currentPatient;
    const token = 'jwt_live_patient_demo';
    await _persistSession(token, user);
    state = state.copyWith(
      user: user,
      token: token,
      isAuthenticated: true,
    );
  }

  void loginAsDoctor() async {
    final user = MockData.currentDoctor;
    const token = 'jwt_live_doc_demo';
    await _persistSession(token, user);
    state = state.copyWith(
      user: user,
      token: token,
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

  /// Update Profile with optional avatar/photo update
  void updateProfile({
    String? name,
    String? phone,
    String? gender,
    String? dob,
    String? avatarUrl,
  }) {
    final updated = state.user.copyWith(
      name: name,
      phone: phone,
      gender: gender,
      dob: dob,
      avatarUrl: avatarUrl,
    );
    state = state.copyWith(user: updated);

    // Update SharedPreferences cache
    if (state.token != null) {
      _persistSession(state.token!, updated);
    }

    // Sync to backend asynchronously with Bearer token
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (dob != null) data['dob'] = dob;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    ApiService.updateUserProfile(state.user.id, data);
  }

  /// Delete account permanently from backend
  Future<bool> deleteAccount() async {
    final success = await ApiService.deleteAccount(state.user.id);
    if (success) {
      await _clearPersistedSession();
      state = state.copyWith(isAuthenticated: false, token: null);
    }
    return success;
  }

  /// Logout and clear persistent storage
  Future<void> logout() async {
    await _clearPersistedSession();
    state = state.copyWith(isAuthenticated: false, token: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
