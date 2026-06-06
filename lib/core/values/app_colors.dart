import 'package:flutter/material.dart';

/// Application Color Palette — inspired by MHD Cooperation logo
/// Logo palette: deep navy (#1A3A6E) · royal blue (#2864BC) · sky blue (#3BA8D5)
class AppColors {
  // Primary Colors (deep navy — logo briefcase)
  static const Color primary = Color(0xFF1A3A6E);
  static const Color primaryDark = Color(0xFF0E2347);
  static const Color primaryLight = Color(0xFF2864BC);

  // Secondary Colors (sky blue — logo document pages)
  static const Color secondary = Color(0xFF3BA8D5);
  static const Color secondaryDark = Color(0xFF1E8BBD);
  static const Color secondaryLight = Color(0xFF6CC5E8);

  // Accent Colors (amber — warm contrast with blues)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFBBF24);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFF9CA3AF);
  static const Color greyDark = Color(0xFF4B5563);

  // Background Colors
  static const Color background = Color(0xFFF0F4F8);
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A2E42);

  // Text Colors
  static const Color textPrimary = Color(0xFF0E2347);
  static const Color textSecondary = Color(0xFF5A7184);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textPrimaryDark = Color(0xFFF0F4F8);
  static const Color textSecondaryDark = Color(0xFF8BAFC7);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3BA8D5);

  // Content Type Colors
  static const Color videoColor = Color(0xFFEC4899);
  static const Color audioColor = Color(0xFF8B5CF6);
  static const Color articleColor = Color(0xFF06B6D4);
  static const Color eventColor = Color(0xFFF59E0B);
  static const Color bookColor = Color(0xFF10B981);

  // Church Colors
  static const Color churchPrimary = Color(0xFF1A3A6E);
  static const Color donationColor = Color(0xFF10B981);
  static const Color testimonyColor = Color(0xFFF59E0B);

  // Border Colors
  static const Color border = Color(0xFFD1E0EE);
  static const Color borderDark = Color(0xFF243B53);

  // Divider Colors
  static const Color divider = Color(0xFFD1E0EE);
  static const Color dividerDark = Color(0xFF243B53);

  // Shadow Colors
  static const Color shadow = Color(0x1A1A3A6E);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Gradient Colors
  /// Full brand gradient: navy → sky blue (mirrors the logo)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6E), Color(0xFF3BA8D5)],
  );

  /// Primary gradient: navy → royal blue
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6E), Color(0xFF2864BC)],
  );

  /// Secondary gradient: royal blue → sky blue
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2864BC), Color(0xFF3BA8D5)],
  );

  /// Vertical brand gradient (top → bottom) for headers
  static const LinearGradient verticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3A6E), Color(0xFF2864BC)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  // Content Type Gradients
  static const LinearGradient videoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
  );

  static const LinearGradient audioGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );

  static const LinearGradient articleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
  );

  static const LinearGradient eventGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );
}
