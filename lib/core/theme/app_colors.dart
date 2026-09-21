import 'package:flutter/material.dart';

class AppColors {
  // Primary Medical Palette
  static const Color primary = Color(0xFF1A56DB);       // Deep Medical Blue
  static const Color primaryDark = Color(0xFF1E429F);   // Darker shade for contrast
  static const Color primaryLight = Color(0xFFEBF5FF);  // Soft medical blue tint
  static const Color primarySoft = Color(0xFFEFF6FF);   // Very light blue for cards/pills
  
  // Secondary / Accent Colors
  static const Color secondary = Color(0xFF0284C7);     // Ocean Blue
  static const Color accent = Color(0xFF06B6D4);        // Cyan Accent
  static const Color accentLight = Color(0xFFECFEFF);   // Cyan light tint

  // Functional & Semantic Colors
  static const Color success = Color(0xFF0E9F6E);       // Green indicator for Online
  static const Color successLight = Color(0xFFDEF7EC);  // Light green badge background
  static const Color warning = Color(0xFFD97706);       // Amber for warnings/badges
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFE02424);         // Red for End Call, errors
  static const Color errorLight = Color(0xFFFDE8E8);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);    // Crisp clinic off-white
  static const Color surface = Color(0xFFFFFFFF);       // White card surface
  static const Color surfaceVariant = Color(0xFFF1F5F9);// Subtle grey-blue surface

  // Neutral & Text Colors
  static const Color textPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);  // Slate 400
  static const Color border = Color(0xFFE2E8F0);        // Light border
  static const Color borderLight = Color(0xFFF1F5F9);

  // Shadows
  static const Color shadow = Color(0x0F0F172A);        // Soft ambient shadow

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A56DB), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientBlue = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientCyan = LinearGradient(
    colors: [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF2563EB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
