import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor_model.dart';
import '../../data/mock/mock_data.dart';

class DoctorFilterState {
  final String searchQuery;
  final String? selectedSpecialty;
  final String consultationMode; // 'all', 'inPerson', 'video'
  final bool onlineOnly;
  final bool highRatingOnly;     // > 90%
  final bool experience10Plus;   // >= 10 years
  final String? selectedLanguage;
  final Set<String> favoriteDoctorIds;

  const DoctorFilterState({
    this.searchQuery = '',
    this.selectedSpecialty,
    this.consultationMode = 'video',
    this.onlineOnly = false,
    this.highRatingOnly = false,
    this.experience10Plus = false,
    this.selectedLanguage,
    this.favoriteDoctorIds = const {},
  });

  DoctorFilterState copyWith({
    String? searchQuery,
    String? selectedSpecialty,
    bool clearSpecialty = false,
    String? consultationMode,
    bool? onlineOnly,
    bool? highRatingOnly,
    bool? experience10Plus,
    String? selectedLanguage,
    bool clearLanguage = false,
    Set<String>? favoriteDoctorIds,
  }) {
    return DoctorFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSpecialty: clearSpecialty ? null : (selectedSpecialty ?? this.selectedSpecialty),
      consultationMode: consultationMode ?? this.consultationMode,
      onlineOnly: onlineOnly ?? this.onlineOnly,
      highRatingOnly: highRatingOnly ?? this.highRatingOnly,
      experience10Plus: experience10Plus ?? this.experience10Plus,
      selectedLanguage: clearLanguage ? null : (selectedLanguage ?? this.selectedLanguage),
      favoriteDoctorIds: favoriteDoctorIds ?? this.favoriteDoctorIds,
    );
  }
}

class DoctorNotifier extends Notifier<DoctorFilterState> {
  @override
  DoctorFilterState build() {
    return const DoctorFilterState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSpecialty(String? specialty) {
    if (specialty == null) {
      state = state.copyWith(clearSpecialty: true);
    } else {
      state = state.copyWith(selectedSpecialty: specialty);
    }
  }

  void setConsultationMode(String mode) {
    state = state.copyWith(consultationMode: mode);
  }

  void toggleOnlineOnly() {
    state = state.copyWith(onlineOnly: !state.onlineOnly);
  }

  void toggleHighRating() {
    state = state.copyWith(highRatingOnly: !state.highRatingOnly);
  }

  void toggleExperience10Plus() {
    state = state.copyWith(experience10Plus: !state.experience10Plus);
  }

  void setLanguage(String? lang) {
    if (lang == null || state.selectedLanguage == lang) {
      state = state.copyWith(clearLanguage: true);
    } else {
      state = state.copyWith(selectedLanguage: lang);
    }
  }

  void toggleFavorite(String doctorId) {
    final updated = Set<String>.from(state.favoriteDoctorIds);
    if (updated.contains(doctorId)) {
      updated.remove(doctorId);
    } else {
      updated.add(doctorId);
    }
    state = state.copyWith(favoriteDoctorIds: updated);
  }

  void resetFilters() {
    state = const DoctorFilterState();
  }
}

final doctorFilterProvider = NotifierProvider<DoctorNotifier, DoctorFilterState>(DoctorNotifier.new);

// Filtered doctors list provider
final filteredDoctorsProvider = Provider<List<DoctorModel>>((ref) {
  final filter = ref.watch(doctorFilterProvider);
  final all = MockData.doctors;

  return all.where((doc) {
    // Mode filter
    if (filter.consultationMode == 'video' && !doc.allowsVideo) return false;
    if (filter.consultationMode == 'inPerson' && !doc.allowsPhysical) return false;

    // Specialty filter
    if (filter.selectedSpecialty != null && filter.selectedSpecialty!.isNotEmpty) {
      if (!doc.specialty.toLowerCase().contains(filter.selectedSpecialty!.toLowerCase())) {
        return false;
      }
    }

    // Search query
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      final matchName = doc.name.toLowerCase().contains(q);
      final matchSpecialty = doc.specialty.toLowerCase().contains(q);
      final matchClinic = doc.clinicName.toLowerCase().contains(q);
      final matchService = doc.services.any((s) => s.toLowerCase().contains(q));
      if (!matchName && !matchSpecialty && !matchClinic && !matchService) return false;
    }

    // Online only
    if (filter.onlineOnly && !doc.isOnline) return false;

    // High rating
    if (filter.highRatingOnly && doc.ratingPercentage < 90) return false;

    // Experience
    if (filter.experience10Plus && doc.experienceYears < 10) return false;

    // Language
    if (filter.selectedLanguage != null &&
        !doc.languages.contains(filter.selectedLanguage)) {
      return false;
    }

    return true;
  }).toList();
});

// Instant vs Later
final instantDoctorsProvider = Provider<List<DoctorModel>>((ref) {
  final list = ref.watch(filteredDoctorsProvider);
  return list.where((d) => d.isOnline).toList();
});

final laterDoctorsProvider = Provider<List<DoctorModel>>((ref) {
  final list = ref.watch(filteredDoctorsProvider);
  return list.where((d) => !d.isOnline).toList();
});

// Doctor by ID
final doctorByIdProvider = Provider.family<DoctorModel?, String>((ref, id) {
  try {
    return MockData.doctors.firstWhere((d) => d.id == id);
  } catch (_) {
    return null;
  }
});
