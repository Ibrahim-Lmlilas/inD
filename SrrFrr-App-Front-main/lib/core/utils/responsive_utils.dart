// Responsive Utilities
//
// Helper utilities for responsive design across different screen sizes.
// Supports phone, tablet, and desktop breakpoints.

import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Prevent instantiation
  ResponsiveUtils._();

  // Breakpoints
  static const double _phoneBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;

  // ============================================================================
  // MARK: - Screen Type Checks
  // ============================================================================

  // Check if current screen is phone size
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < _phoneBreakpoint;

  // Check if current screen is tablet size
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _phoneBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;

  // Check if current screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletBreakpoint;

  // ============================================================================
  // MARK: - Responsive Padding
  // ============================================================================

  // Get responsive padding based on screen size
  // Returns: 16.0 (phone), 24.0 (tablet), 32.0 (desktop)
  static double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  // Get responsive card padding with centered content for larger screens
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return EdgeInsets.symmetric(horizontal: (width - 800) / 2, vertical: 32);
    } else if (width > 600) {
      return EdgeInsets.symmetric(horizontal: (width - 500) / 2, vertical: 24);
    }
    return const EdgeInsets.all(16);
  }

  // ============================================================================
  // MARK: - Responsive Font Sizes
  // ============================================================================

  // Get responsive font size based on screen size
  // Multipliers: 1.0 (phone), 1.05 (tablet), 1.1 (desktop)
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.1;
    if (isTablet(context)) return baseSize * 1.05;
    return baseSize;
  }

  // ============================================================================
  // MARK: - Responsive Icon Sizes
  // ============================================================================

  // Get responsive icon size based on screen size
  // Multipliers: 1.0 (phone), 1.1 (tablet), 1.2 (desktop)
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.2;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize;
  }

  // ============================================================================
  // MARK: - Responsive Spacing
  // ============================================================================

  // Get responsive spacing based on screen size
  // Multipliers: 1.0 (phone), 1.25 (tablet), 1.5 (desktop)
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isDesktop(context)) return baseSpacing * 1.5;
    if (isTablet(context)) return baseSpacing * 1.25;
    return baseSpacing;
  }

  // ============================================================================
  // MARK: - Content Width
  // ============================================================================

  // Get maximum width for content
  // Returns: infinity (phone), 800 (tablet), 1200 (desktop)
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  // ============================================================================
  // MARK: - Grid Columns
  // ============================================================================

  // Get number of grid columns based on screen size
  // Returns: 2 (phone), 3 (tablet), 4 (desktop)
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  // ============================================================================
  // MARK: - Additional Utilities
  // ============================================================================

  // Get screen width
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Get screen height
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // Check if screen is in portrait mode
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // Get responsive button height
  // Returns: 48.0 (phone), 52.0 (tablet), 56.0 (desktop)
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isDesktop(context)) return 56.0;
    if (isTablet(context)) return 52.0;
    return 48.0;
  }

  // Get responsive border radius
  // Multipliers: 1.0 (phone), 1.1 (tablet), 1.2 (desktop)
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    if (isDesktop(context)) return baseRadius * 1.2;
    if (isTablet(context)) return baseRadius * 1.1;
    return baseRadius;
  }

  // Get safe area padding (accounts for notches, system bars)
  static EdgeInsets getSafeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  // Get responsive dialog width
  // Returns: 90% (phone), 500 (tablet), 600 (desktop)
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return screenWidth * 0.9;
  }

  // Get responsive card elevation
  // Returns: 2.0 (phone), 3.0 (tablet), 4.0 (desktop)
  static double getResponsiveElevation(BuildContext context) {
    if (isDesktop(context)) return 4.0;
    if (isTablet(context)) return 3.0;
    return 2.0;
  }
}
