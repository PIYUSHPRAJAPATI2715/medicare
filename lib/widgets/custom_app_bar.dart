import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/animation/animation_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool isGlass;
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.isGlass = true,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? Colors.white.withValues(alpha: isGlass ? 0.85 : 1.0);

    Widget appBarChild = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: showBack || leading != null ? 56 : null,
      leading: leading ??
          (showBack
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: AppBouncyTouch(
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceVariant.withValues(alpha: 0.8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                )
              : null),
      actions: actions?.map((action) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppBouncyTouch(child: action),
          )).toList(),
    );

    if (isGlass) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: effectiveBgColor,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderLight.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
            ),
            child: appBarChild,
          ),
        ),
      );
    }

    return Container(
      color: effectiveBgColor,
      child: appBarChild,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
