import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/specialty_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';

class SpecialtyListScreen extends ConsumerStatefulWidget {
  const SpecialtyListScreen({super.key});

  @override
  ConsumerState<SpecialtyListScreen> createState() => _SpecialtyListScreenState();
}

class _SpecialtyListScreenState extends ConsumerState<SpecialtyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialties = ref.watch(specialtiesListProvider);
    final asyncDiseases = ref.watch(allDiseasesProvider);
    final diseases = asyncDiseases.value ?? [];
    final searchQuery = ref.watch(specialtySearchQueryProvider).toLowerCase().trim();

    final filteredDiseases = diseases.where((d) {
      if (searchQuery.isEmpty) return true;
      return d.name.toLowerCase().contains(searchQuery) ||
          d.specialty.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Find Doctors & Care',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
          tabs: const [
            Tab(text: 'Specialities'),
            Tab(text: 'Diseases & Symptoms'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(specialtySearchQueryProvider.notifier).setQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search condition or specialty...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(specialtySearchQueryProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Specialities
                specialties.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No Specialities Found',
                        message: 'Try searching for common symptoms or different specialty names.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: specialties.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 78,
                          endIndent: 20,
                          color: AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final item = specialties[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: item.bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icon, color: item.iconColor, size: 24),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.doctorCount} Doctors available',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            onTap: () {
                              ref.read(doctorFilterProvider.notifier).setSpecialty(item.name);
                              Navigator.of(context).pushNamed(AppRoutes.doctorList);
                            },
                          );
                        },
                      ),

                // Tab 2: Diseases & Symptoms
                filteredDiseases.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.healing_rounded,
                        title: 'No Diseases Found',
                        message: 'Check your search query or consult a general physician.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: filteredDiseases.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 78,
                          endIndent: 20,
                          color: AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredDiseases[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.coronavirus_rounded,
                                color: Color(0xFF2563EB),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  'Recommended: ${item.specialty}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.symptomCount,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Consult',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            onTap: () {
                              ref.read(doctorFilterProvider.notifier).setSpecialty(item.specialty);
                              Navigator.of(context).pushNamed(AppRoutes.doctorList);
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
