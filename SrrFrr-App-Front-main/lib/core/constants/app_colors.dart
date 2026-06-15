// Application Color Palette
// 
// Provides color schemes for both regular (blue) and ladies (pink) interfaces.
// Uses a three-color system: Primary (blue/pink) + White + Grey

import 'package:flutter/material.dart';

class AppColors {
  // Regular Interface Colors (Blue theme)
  static const Color primaryBlue = Color(0xFF4AC1F7);
  static const Color secondaryBlue = Color(0xFF1C7ED6);
  static const Color accentBlue = Color(0xFF339AF0);
  
  // Ladies Interface Colors (Pink theme)
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color secondaryPink = Color(0xFFC2185B);
  static const Color accentPink = Color(0xFFF06292);

  // Dynamic primary color (changes based on interface)
  static Color primary = primaryBlue;
  static Color secondary = secondaryBlue;
  static Color accent = accentBlue;

  // White
  static const Color white = Colors.white;
  static const Color offWhite = Color(0xFFFAFAFA);

  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FA);
  static const Color surfaceWhite = Colors.white;
  static Color surfaceGrey = grey100;

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color textDisabled = Color(0xFFCBD5E0);

  // Feedback Colors
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
  static const Color info = Color(0xFF4299E1);

  // Map Colors
  static const Color mapPinOrigin = Color(0xFF48BB78);
  static const Color mapPinDestination = Color(0xFFE53E3E);
  static Color mapRouteColor = primary;

  // Border / Divider
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFEDF2F7);

  // Set the app theme to regular (blue) interface
  static void setRegularTheme() {
    primary = primaryBlue;
    secondary = secondaryBlue;
    accent = accentBlue;
    mapRouteColor = primaryBlue;
  }

  // Set the app theme to ladies (pink) interface
  static void setLadiesTheme() {
    primary = primaryPink;
    secondary = secondaryPink;
    accent = accentPink;
    mapRouteColor = primaryPink;
  }

  // Get color based on interface type
  static Color getPrimaryColor(bool isLadiesInterface) {
    return isLadiesInterface ? primaryPink : primaryBlue;
  }

  static Color getSecondaryColor(bool isLadiesInterface) {
    return isLadiesInterface ? secondaryPink : secondaryBlue;
  }

  static Color getAccentColor(bool isLadiesInterface) {
    return isLadiesInterface ? accentPink : accentBlue;
  }
}