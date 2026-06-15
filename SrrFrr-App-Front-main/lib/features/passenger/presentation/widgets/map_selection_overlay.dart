// Map Selection Overlay Component
//
// Displays UI controls when user is selecting a location on the map.
// Shows instructions, cancel and confirm buttons, and loading state during geocoding.
// Overlay allows map interaction (tap, zoom, pan) to pass through.

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class MapSelectionOverlay extends StatelessWidget {
  final String selectionTarget;
  final bool isGeocoding;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const MapSelectionOverlay({
    super.key,
    required this.selectionTarget,
    required this.isGeocoding,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPickup = selectionTarget == 'pickup';
    final targetLabel = isPickup
        ? l10n.selectingPickup
        : l10n.selectingDestination;
    final targetColor = isPickup ? AppColors.success : AppColors.error;

    return Stack(
      children: [
        // Semi-transparent background - allows map interaction
        IgnorePointer(
          child: Container(color: Colors.black.withValues(alpha: 0.2)),
        ),

        // Top instruction card - blocks interaction
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: targetColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        isPickup
                            ? Icons.radio_button_checked
                            : Icons.location_on,
                        color: targetColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.selectingLocationFor(targetLabel),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.tapOrDragMarker,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.zoomForPrecision,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom action buttons - blocks interaction
        Positioned(
          bottom: 32,
          left: 16,
          right: 16,
          child: isGeocoding
              ? _buildLoadingIndicator(context)
              : _buildActionButtons(context, targetColor),
        ),
      ],
    );
  }

  // Build loading indicator during geocoding
  Widget _buildLoadingIndicator(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Text(
            l10n.retrievingAddress,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Build action buttons (Cancel and Confirm)
  Widget _buildActionButtons(BuildContext context, Color targetColor) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Cancel button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  side: BorderSide(color: AppColors.grey300, width: 1.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    l10n.cancel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSizes.paddingM),

        // Confirm button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: targetColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: targetColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 20),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    l10n.confirmLocation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
