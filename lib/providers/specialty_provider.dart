import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/specialty_model.dart';
import '../../models/disease_model.dart';
import '../../data/mock/mock_data.dart';
import '../services/api_service.dart';

class SpecialtySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final specialtySearchQueryProvider = NotifierProvider<SpecialtySearchNotifier, String>(SpecialtySearchNotifier.new);

final allSpecialtiesProvider = FutureProvider<List<SpecialtyModel>>((ref) async {
  return await ApiService.fetchSpecialties();
});

final allDiseasesProvider = FutureProvider<List<DiseaseModel>>((ref) async {
  return await ApiService.fetchDiseases();
});

final specialtiesListProvider = Provider<List<SpecialtyModel>>((ref) {
  final query = ref.watch(specialtySearchQueryProvider).toLowerCase().trim();
  final asyncSpecialties = ref.watch(allSpecialtiesProvider);
  final list = asyncSpecialties.value ?? MockData.specialties;

  if (query.isEmpty) return list;
  return list.where((s) {
    final matchName = s.name.toLowerCase().contains(query);
    final matchDesc = s.description.toLowerCase().contains(query);
    final matchSymptom = s.commonSymptoms.any((sym) => sym.toLowerCase().contains(query));
    return matchName || matchDesc || matchSymptom;
  }).toList();
});


