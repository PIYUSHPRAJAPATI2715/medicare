import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/specialty_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';

class SpecialtyListScreen extends ConsumerWidget {
  const SpecialtyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialties = ref.watch(specialtiesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Consult a Doctor',
      ),
      body: Column(
        children: [
          // Search box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              onChanged: (val) {
                ref.read(specialtySearchQueryProvider.notifier).setQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search speciality...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
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

          // List
          Expanded(
            child: specialties.isEmpty
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
          ),
        ],
      ),
    );
  }
}
