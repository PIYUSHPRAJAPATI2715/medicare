import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class MedicareLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final Color? textColor;
  final bool isDarkBackground;

  const MedicareLogo({
    super.key,
    this.size = 48,
    this.showTagline = true,
    this.textColor,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = textColor ?? (isDarkBackground ? Colors.white : AppColors.primaryDark);
    final tagColor = isDarkBackground ? Colors.white70 : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF1A56DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: size * 0.72,
              ),
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: size * 0.62,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'MediCare',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '+',
                  style: TextStyle(
                    color: const Color(0xFF06B6D4),
                    fontSize: size * 0.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (showTagline)
              Text(
                'Your Health, Our Priority',
                style: TextStyle(
                  color: tagColor,
                  fontSize: (size * 0.23).clamp(10, 13),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
