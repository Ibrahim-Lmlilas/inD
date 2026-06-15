// Location Input Card Component - Fixed Version
//
// Fixes:
// - Smooth typing without interruption
// - Proper text deletion without refocusing
// - Consistent UI behavior
// - Better state management
// - No focus loss during typing

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/providers/map_provider.dart';
import 'package:srrfrr_app_front/core/utils/map_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationInputCard extends StatefulWidget {
  final String? pickupLocation;
  final String? destinationLocation;

  const LocationInputCard({
    super.key,
    this.pickupLocation,
    this.destinationLocation,
  });

  @override
  State<LocationInputCard> createState() => _LocationInputCardState();
}

class _LocationInputCardState extends State<LocationInputCard> {
  // API Configuration
  late final String _apiKey;
  bool _isInitialized = false;

  // Stable TextEditingControllers
  late final TextEditingController _pickupSearchController;
  late final TextEditingController _destinationSearchController;

  // Focus Nodes for proper focus management
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  // Request Management
  Timer? _placeDetailsTimer;
  bool _isLoadingPlaceDetails = false;
  static const Duration _placeDetailsTimeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    _pickupSearchController = TextEditingController();
    _destinationSearchController = TextEditingController();

    _initializeApiKey();
  }

  @override
  void dispose() {
    _placeDetailsTimer?.cancel();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    _pickupSearchController.dispose();
    _destinationSearchController.dispose();
    super.dispose();
  }

  // Initialize and validate Google Maps API key
  void _initializeApiKey() {
    _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    if (_apiKey.isEmpty) {
      debugPrint('❌ GOOGLE_MAPS_API_KEY not found in environment');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final l10n = AppLocalizations.of(context)!;
          _showError(l10n.errorOccurred);
        });
      }
    } else {
      _isInitialized = true;
      debugPrint('✅ Google Maps API key initialized');
    }
  }

  // Get place details with timeout protection
  Future<void> _getPlaceDetails(String placeId, bool isPickup) async {
    if (!_isInitialized || !mounted) return;

    // Prevent concurrent requests
    if (_isLoadingPlaceDetails) {
      debugPrint('⚠️ Place details request already in progress, skipping');
      return;
    }

    setState(() => _isLoadingPlaceDetails = true);

    // Setup timeout protection
    _placeDetailsTimer?.cancel();
    bool timedOut = false;

    _placeDetailsTimer = Timer(_placeDetailsTimeout, () {
      if (mounted && _isLoadingPlaceDetails) {
        timedOut = true;
        setState(() => _isLoadingPlaceDetails = false);
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.errorOccurred);
        debugPrint('⏱️ Place details request timed out');
      }
    });

    try {
      debugPrint('🔍 Fetching place details for: $placeId');

      final result = await MapUtils.getPlaceDetails(placeId);

      // Cancel timeout timer
      _placeDetailsTimer?.cancel();

      if (timedOut || !mounted) {
        debugPrint('⚠️ Request completed but context no longer valid');
        return;
      }

      setState(() => _isLoadingPlaceDetails = false);

      if (result != null && result['success'] == true) {
        final mapProvider = context.read<MapProvider>();
        final latLng = LatLng(
          result['latitude'] as double,
          result['longitude'] as double,
        );
        final address = result['address'] as String;
        final city = result['city'] as String?;

        debugPrint('✅ Place details retrieved: $address');

        if (isPickup) {
          mapProvider.setPickupLocation(address, latLng, city: city);
        } else {
          mapProvider.setDestinationLocation(address, latLng, city: city);
        }

        // Close the bottom sheet
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showError(
          result?['message'] ?? AppLocalizations.of(context)!.errorOccurred,
        );
        debugPrint('❌ Place details failed: ${result?['message']}');
      }
    } catch (e) {
      _placeDetailsTimer?.cancel();

      if (!timedOut && mounted) {
        setState(() => _isLoadingPlaceDetails = false);
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.networkError);
        debugPrint('❌ Place details error: $e');
      }
    }
  }

  // Show place picker modal
  Future<void> _showPlacePicker({
    required BuildContext context,
    required bool isPickup,
  }) async {
    if (!_isInitialized) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.errorOccurred);
      return;
    }

    final controller = isPickup
        ? _pickupSearchController
        : _destinationSearchController;

    final focusNode = isPickup ? _pickupFocusNode : _destinationFocusNode;

    // Clear controller before showing picker
    controller.clear();

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: !_isLoadingPlaceDetails,
        enableDrag: !_isLoadingPlaceDetails,
        builder: (context) => PopScope(
          canPop: !_isLoadingPlaceDetails,
          child: _buildPlacePickerSheet(
            context: context,
            controller: controller,
            focusNode: focusNode,
            isPickup: isPickup,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing place picker: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.errorOccurred);
      }
    }
  }

  // Build place picker bottom sheet
  Widget _buildPlacePickerSheet({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isPickup,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXS),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXXS),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isPickup ? l10n.pickupLocation : l10n.destination,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoadingPlaceDetails
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Search field with Google Places autocomplete
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                ),
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: controller,
                  googleAPIKey: _apiKey,
                  focusNode: focusNode,
                  inputDecoration: InputDecoration(
                    hintText: l10n.searchPlace,
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                      vertical: AppSizes.paddingM,
                    ),
                  ),
                  debounceTime: 600,
                  countries: const ["ma"],
                  isLatLngRequired: true,

                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    if (prediction.placeId != null && !_isLoadingPlaceDetails) {
                      debugPrint(
                        '🔍 Place selected: ${prediction.description}',
                      );
                      focusNode.unfocus();
                      _getPlaceDetails(prediction.placeId!, isPickup);
                    }
                  },

                  itemClick: (Prediction prediction) {
                    // Leave empty to prevent interference with typing
                  },

                  seperatedBuilder: Divider(
                    color: AppColors.grey200,
                    height: 1,
                    thickness: 1,
                  ),

                  itemBuilder: (context, index, Prediction prediction) {
                    return _buildPredictionItem(
                      prediction,
                      isPickup,
                      focusNode,
                    );
                  },

                  isCrossBtnShown: true,
                  containerHorizontalPadding: 0,
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // Map selection button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                ),
                child: _buildMapSelectionButton(context, isPickup),
              ),

              const SizedBox(height: AppSizes.paddingM),

              Divider(color: AppColors.grey200, height: 1, thickness: 1),

              Expanded(
                child: Container(
                  color: AppColors.grey50,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 48, color: AppColors.grey400),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          l10n.searchAddress,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          l10n.orSelectOnMap,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isLoadingPlaceDetails)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          l10n.loading,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build map selection button
  Widget _buildMapSelectionButton(BuildContext context, bool isPickup) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: InkWell(
        onTap: _isLoadingPlaceDetails
            ? null
            : () {
                Navigator.pop(context);
                final mapProvider = context.read<MapProvider>();
                mapProvider.startMapSelection(
                  isPickup ? 'pickup' : 'destination',
                );
              },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_searching,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                l10n.selectOnMap,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build prediction item
  Widget _buildPredictionItem(
    Prediction prediction,
    bool isPickup,
    FocusNode focusNode,
  ) {
    return InkWell(
      onTap: _isLoadingPlaceDetails
          ? null
          : () {
              if (prediction.placeId != null) {
                debugPrint('🎯 Prediction tapped: ${prediction.description}');
                // Unfocus before fetching
                focusNode.unfocus();
                _getPlaceDetails(prediction.placeId!, isPickup);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.structuredFormatting?.mainText ??
                        prediction.description ??
                        "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (prediction.structuredFormatting?.secondaryText !=
                      null) ...[
                    const SizedBox(height: 2),
                    Text(
                      prediction.structuredFormatting!.secondaryText!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show error message
  void _showError(String message) {
    if (!mounted) return;
    SnackBarService(context).showError(message);
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pickup location
          _buildLocationInput(
            context: context,
            icon: Icons.radio_button_checked,
            iconColor: AppColors.success,
            label: l10n.departure,
            hint: l10n.yourCurrentPosition,
            value: widget.pickupLocation,
            onTap: () => _showPlacePicker(context: context, isPickup: true),
            onClear: () => mapProvider.clearPickupLocation(),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            child: Row(
              children: [
                const SizedBox(width: 42),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXXS),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Destination location
          _buildLocationInput(
            context: context,
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: l10n.arrival,
            hint: l10n.whereAreYouGoing,
            value: widget.destinationLocation,
            onTap: () => _showPlacePicker(context: context, isPickup: false),
            onClear: () => mapProvider.clearDestinationLocation(),
          ),
        ],
      ),
    );
  }

  // Build location input field
  Widget _buildLocationInput({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required String? value,
    required VoidCallback onTap,
    required VoidCallback? onClear,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: hasValue
              ? iconColor.withValues(alpha: 0.05)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: hasValue
                ? iconColor.withValues(alpha: 0.2)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSizes.paddingM),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Action button
            if (hasValue && onClear != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onClear,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              )
            else
              Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
