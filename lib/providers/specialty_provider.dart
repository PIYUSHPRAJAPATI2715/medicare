import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/specialty_model.dart';
import '../../data/mock/mock_data.dart';

class SpecialtySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final specialtySearchQueryProvider = NotifierProvider<SpecialtySearchNotifier, String>(SpecialtySearchNotifier.new);

final specialtiesListProvider = Provider<List<SpecialtyModel>>((ref) {
  final query = ref.watch(specialtySearchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return MockData.specialties;
  return MockData.specialties.where((s) {
    final matchName = s.name.toLowerCase().contains(query);
    final matchDesc = s.description.toLowerCase().contains(query);
    final matchSymptom = s.commonSymptoms.any((sym) => sym.toLowerCase().contains(query));
    return matchName || matchDesc || matchSymptom;
  }).toList();
});
