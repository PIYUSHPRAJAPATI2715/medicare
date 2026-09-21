import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RatingBadge extends StatelessWidget {
  final double ratingPercentage;
  final int storiesCount;
  final bool compact;

  const RatingBadge({
    super.key,
    required this.ratingPercentage,
    required this.storiesCount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.thumb_up_alt_rounded,
            size: 13,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            '${ratingPercentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              '($storiesCount Stories)',
              style: TextStyle(
                color: AppColors.success.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
