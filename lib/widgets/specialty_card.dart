import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/specialty_model.dart';

class SpecialtyCard extends StatefulWidget {
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
  State<SpecialtyCard> createState() => _SpecialtyCardState();
}

class _SpecialtyCardState extends State<SpecialtyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.specialty;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: s.bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: s.iconColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    s.icon,
                    color: s.iconColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.showSubtitle) ...[
                const SizedBox(height: 2),
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
      ),
    );
  }
}
