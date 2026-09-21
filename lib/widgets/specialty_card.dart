import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/animation/animation_utils.dart';
import '../models/specialty_model.dart';

class SpecialtyCard extends StatelessWidget {
  final SpecialtyModel specialty;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showSubtitle;

  const SpecialtyCard({
    super.key,
    required this.specialty,
    required this.onTap,
    this.isSelected = false,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = specialty;

    return AppBouncyTouch(
      scaleFactor: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: s.bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: s.iconColor.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  s.icon,
                  color: s.iconColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 3),
              Text(
                '${s.doctorCount} Doctors',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
