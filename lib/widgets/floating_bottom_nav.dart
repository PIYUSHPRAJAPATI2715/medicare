import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/animation/animation_utils.dart';

class NavItemData {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  IconData get effectiveActiveIcon => activeIcon ?? icon;
}

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItemData> _items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment_rounded,
      label: 'In-Person',
    ),
    NavItemData(
      icon: Icons.videocam_outlined,
      activeIcon: Icons.videocam_rounded,
      label: 'Video Consult',
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding > 0 ? bottomPadding + 4 : 14,
        top: 6,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            // Deep ambient dark elevation shadow
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.14),
              blurRadius: 28,
              spreadRadius: 1,
              offset: const Offset(0, 10),
            ),
            // Medical primary blue ambient glow
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, 6),
            ),
            // Crisp grounding contact shadow
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 1.5,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final itemWidth = totalWidth / _items.length;

                  return Stack(
                    children: [
                      // Smooth animated sliding background pill
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.fastOutSlowIn,
                        left: currentIndex * itemWidth + 3,
                        top: 3,
                        bottom: 3,
                        width: itemWidth - 6,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primaryLight.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 3),
                              width: 18,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Nav Items in vertical column layout
                      Row(
                        children: List.generate(_items.length, (index) {
                          final isSelected = currentIndex == index;
                          final item = _items[index];

                          return Expanded(
                            child: AppBouncyTouch(
                              scaleFactor: 0.93,
                              onTap: () => onTap(index),
                              child: Container(
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 3),
                                    AnimatedScale(
                                      scale: isSelected ? 1.12 : 1.0,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOutBack,
                                      child: Icon(
                                        isSelected ? item.effectiveActiveIcon : item.icon,
                                        size: 22,
                                        color: isSelected
                                            ? AppColors.primary
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primary
                                            : const Color(0xFF64748B),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 11,
                                        letterSpacing: -0.2,
                                      ),
                                      child: Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
