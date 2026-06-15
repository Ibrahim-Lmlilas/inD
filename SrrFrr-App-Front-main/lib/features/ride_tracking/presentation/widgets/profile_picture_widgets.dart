/// Reusable Profile Picture Widgets
///
/// Provides consistent profile picture display with fallback to initials

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';

class ProfilePictureAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const ProfilePictureAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 56,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Use centralized helpers
    final hasValidPicture = UserProvider.isValidProfilePicture(imageUrl);
    final pictureUrl = UserProvider.getProfilePictureUrl(imageUrl);
    final initial = UserProvider.getInitial(fallbackText);

    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasValidPicture ? null : effectiveBackgroundColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
      ),
      child: hasValidPicture && pictureUrl != null
          ? ClipOval(
              child: Image.network(
                pictureUrl,
                fit: BoxFit.cover,
                headers: const {'Accept': 'image/*'},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveBackgroundColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                ),
              ),
            ),
    );
  }
}

/// Square/rounded profile picture with gradient background
class ProfilePictureCard extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;
  final double borderRadius;
  final List<Color>? gradientColors;
  final Color? textColor;
  final bool showShadow;

  const ProfilePictureCard({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 80,
    this.borderRadius = 16,
    this.gradientColors,
    this.textColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use centralized helpers
    final hasValidPicture = UserProvider.isValidProfilePicture(imageUrl);
    final pictureUrl = UserProvider.getProfilePictureUrl(imageUrl);
    final initial = UserProvider.getInitial(fallbackText);

    final effectiveGradientColors =
        gradientColors ??
        [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)];
    final effectiveTextColor = textColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: hasValidPicture
            ? null
            : LinearGradient(colors: effectiveGradientColors),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: effectiveGradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: hasValidPicture && pictureUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.network(
                pictureUrl,
                fit: BoxFit.cover,
                headers: const {'Accept': 'image/*'},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveGradientColors.first.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.w700,
                        color: effectiveTextColor,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w700,
                  color: effectiveTextColor,
                ),
              ),
            ),
    );
  }
}