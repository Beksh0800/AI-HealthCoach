import 'package:flutter/material.dart';

/// App color palette - Medical/Health theme
class AppColors {
  AppColors._();

  // Primary colors - Healing Blue-Green
  static const Color primary = Color(0xFF00B4A0);
  static const Color primaryLight = Color(0xFF5FE6D6);
  static const Color primaryDark = Color(0xFF008573);

  // Secondary colors - Calm Purple
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color secondaryLight = Color(0xFFB47CFF);
  static const Color secondaryDark = Color(0xFF3D1DCB);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Pain indicator colors
  static const Color painLow = Color(0xFF4CAF50);
  static const Color painMedium = Color(0xFFFFC107);
  static const Color painHigh = Color(0xFFF44336);

  // Neutral colors
  static const MaterialColor neutral = MaterialColor(
    0xFF9E9E9E,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      400: Color(0xFFBDBDBD),
      500: Color(0xFF9E9E9E),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      900: Color(0xFF212121),
    },
  );
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1D1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Gradient for workout cards
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B4A0), Color(0xFF00D4AA)],
  );
}
