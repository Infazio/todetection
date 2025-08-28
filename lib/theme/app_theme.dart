// File: lib/theme/app_theme.dart
import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

class AppTheme {
  // 🎨 INFAZIO COLOR PALETTE (Based on logo)
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color primaryPurpleLight = Color(0xFF8B5CF6);
  static const Color primaryPurpleDark = Color(0xFF553C9A);

  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryBlueLight = Color(0xFF60A5FA);
  static const Color secondaryBlueDark = Color(0xFF2563EB);

  static const Color accentCyan = Color(0xFF00BCD4); // Match logo
  static const Color accentCyanLight = Color(0xFF26C6DA);
  static const Color accentCyanDark = Color(0xFF00ACC1);

  // 🌙 DARK THEME COLORS
  static const Color darkPrimary = Color(0xFF0F172A);
  static const Color darkSecondary = Color(0xFF1E293B);
  static const Color darkTertiary = Color(0xFF334155);

  // ☀️ LIGHT THEME COLORS
  static const Color lightPrimary = Color(0xFFF8FAFC);
  static const Color lightSecondary = Color(0xFFE2E8F0);
  static const Color lightTertiary = Color(0xFFCBD5E1);

  // 🎯 STATUS COLORS
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = accentCyan;

  // 🎭 GLASSMORPHISM COLORS
  static Color get glassWhite => Colors.white.withValues(alpha: 0.1);
  static Color get glassBlack => Colors.black.withValues(alpha: 0.1);
  static Color get glassPurple => primaryPurple.withValues(alpha: 0.1);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF8B5CF6), // Purple start
      Color(0xFF3B82F6), // Blue middle
      Color(0xFF00BCD4), // Cyan end
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFF3B82F6), // Blue start
      Color(0xFF00BCD4), // Cyan end
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Optional: Keep for future background use
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFEDE9FE), // Light purple
      Color(0xFFEFF6FF), // Light blue
      Color(0xFFE0F7FA), // Light cyan
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 📐 SPACING & SIZING
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // 🎨 SHADOW DEFINITIONS
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // 🎯 BUTTON STYLES
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent, // Transparent untuk gradient
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    elevation: 0, // Remove shadow karena pakai custom container
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    elevation: 0,
  );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryPurple,
    side: const BorderSide(color: primaryPurple),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );

  // 📱 SNACKBAR STYLES
  static SnackBarThemeData get snackBarTheme => const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
    ),
  );

  // 🎨 APP BAR STYLES
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: primaryPurple,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  // 📝 TEXT STYLES
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: darkTertiary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: lightTertiary,
  );

  // 🌈 CONTEXT-AWARE SNACKBAR COLORS
  static Color getSnackbarColor(BuildContext context, SnackbarType type) {
    final isDarkBackground = _isDarkBackground(context);

    switch (type) {
      case SnackbarType.success:
        return isDarkBackground ? success : success;
      case SnackbarType.error:
        return isDarkBackground ? error : error;
      case SnackbarType.warning:
        return isDarkBackground ? warning : warning;
      case SnackbarType.info:
        return isDarkBackground ? info : info;
    }
  }

  static Color getSnackbarTextColor(BuildContext context) {
    return _isDarkBackground(context) ? Colors.white : Colors.white;
  }

  static bool _isDarkBackground(BuildContext context) {
    // Check if current screen has dark background
    final route = ModalRoute.of(context)?.settings.name;
    return route == '/recognition'; // Recognition screen has dark background
  }

  // TAMBAH helper method di AppTheme class:
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isSecondary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSecondary ? accentGradient : primaryGradient,
        borderRadius: BorderRadius.circular(radiusMedium),
        boxShadow: softShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: primaryButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
