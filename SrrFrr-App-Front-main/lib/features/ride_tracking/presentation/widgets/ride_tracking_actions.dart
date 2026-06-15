// Ride Tracking Actions Handler
//
// Contains all business logic and action handlers

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/features/chat/presentation/providers/chat_provider.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/providers/ride_tracking_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/rating.dart';
import 'package:srrfrr_app_front/shared/providers/rating_provider.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart' show UserProvider;
import 'package:srrfrr_app_front/shared/widgets/report_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'ride_tracking_dialogs.dart';

class RideTrackingActions {
  final BuildContext context;

  RideTrackingActions(this.context);

  // ==========================================================================
  // DRIVER ACTIONS
  // ==========================================================================

  Future<void> onDriverConfirmArrival() async {
    HapticFeedback.mediumImpact();

    final provider = context.read<RideTrackingProvider>();
    await provider.confirmDriverArrival();

    if (context.mounted) {
      SnackBarService(
        context,
      ).showSuccess(AppLocalizations.of(context)!.confirmationSentToPassenger);
    }
  }

  Future<void> onDriverStartRide() async {
    HapticFeedback.heavyImpact();

    final provider = context.read<RideTrackingProvider>();
    await provider.startRide();

    if (context.mounted) {
      SnackBarService(
        context,
      ).showSuccess(AppLocalizations.of(context)!.rideStarted);
    }
  }

  Future<void> onDriverFinishRide() async {
    final confirmed = await showFinishRideConfirmation(context);

    if (confirmed != true || !context.mounted) return;

    HapticFeedback.heavyImpact();

    final provider = context.read<RideTrackingProvider>();
    await provider.finishRide();
  }

  // ==========================================================================
  // PASSENGER ACTIONS
  // ==========================================================================

  Future<void> onPassengerNotifyComing() async {
    HapticFeedback.mediumImpact();

    final provider = context.read<RideTrackingProvider>();
    await provider.notifyDriverPassengerComing();

    if (context.mounted) {
      SnackBarService(
        context,
      ).showSuccess(AppLocalizations.of(context)!.confirmationSentToPassenger);
    }
  }

  // ==========================================================================
  // COMMUNICATION ACTIONS
  // ==========================================================================

  Future<void> callUser(String? phone) async {
    if (phone == null || phone.isEmpty) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.phoneNotAvailable);
      return;
    }

    try {
      final uri = Uri.parse('tel:$phone');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        SnackBarService(
          context,
        ).showError(AppLocalizations.of(context)!.cannotOpenPhoneApp);
      }
    }
  }

  void navigateToChat(String? userId, String? userName, String? rideId) {
    if (userId == null) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.userInfoNotAvailable);
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.currentUser?.id;

    if (currentUserId == null) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.userNotAuthenticated);
      return;
    }

    final rideProvider = context.read<RideTrackingProvider>();
    final wsToken = rideProvider.wsToken;
    final channelId = rideProvider.channelId;

    context.push(
      '/chat',
      extra: {
        'chatData': {
          'chatId': 'chat_$rideId',
          'channelId': channelId,
          'wsToken': wsToken,
          'current_user_id': currentUserId,
          'other_user_id': userId,
          'other_user_name': userName ?? 'Utilisateur',
        },
        'rideData': {'ride_id': rideId},
      },
    );
  }

  Future<void> openNavigation({
    required bool isPassengerMode,
    required bool rideHasStarted,
    required Map<String, dynamic>? destination,
  }) async {
    final rideProvider = context.read<RideTrackingProvider>();

    LatLng? targetLocation;

    if (isPassengerMode) {
      targetLocation = rideProvider.driverLocation;
    } else {
      targetLocation = rideHasStarted && destination != null
          ? LatLng(
              destination['latitude'] as double,
              destination['longitude'] as double,
            )
          : rideProvider.passengerLocation;
    }

    if (targetLocation == null) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.locationNotAvailable);
      return;
    }

    final choice = await showNavigationAppSelector(context);

    if (choice == null || !context.mounted) return;

    try {
      final lat = targetLocation.latitude;
      final lng = targetLocation.longitude;

      Uri uri;
      if (choice == 'waze') {
        uri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
      } else {
        uri = Uri.parse('google.navigation:q=$lat,$lng');
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        uri = choice == 'waze'
            ? Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes')
            : Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
              );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService(
          context,
        ).showError(AppLocalizations.of(context)!.cannotOpenNavigation);
      }
    }
  }

  // ==========================================================================
  // CANCELLATION
  // ==========================================================================

  Future<void> showCancelDialog() async {
    final rideProvider = context.read<RideTrackingProvider>();
    final rideId = rideProvider.rideId;

    if (rideId == null) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.rideInfoNotAvailable);
      return;
    }

    await showReportBottomSheet(
      context: context,
      rideId: rideId,
      onSuccess: () => _confirmCancellation(),
    );
  }

  Future<void> _confirmCancellation() async {
    final provider = context.read<RideTrackingProvider>();
    final success = await provider.cancelRide('User reported issue');

    if (success && context.mounted) {
      _clearChatCache();
      final userProvider = context.read<UserProvider>();
      final destination = userProvider.isDriverMode ? '/driver-home' : '/home';
      context.go(destination);
      SnackBarService(
        context,
      ).showInfo(AppLocalizations.of(context)!.rideCancelled);
    } else if (context.mounted) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.cancellationError);
    }
  }

  // ==========================================================================
  // RATING
  // ==========================================================================

  Future<bool> submitRating({
    required int selectedStars,
    required String? selectedOptionId,
  }) async {
    logInfo('RideTracking', 'Attempting to submit embedded rating');

    if (selectedStars == 0) {
      logWarning('RideTracking', 'No stars selected');
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.pleaseSelectRating);
      return false;
    }

    if (selectedOptionId == null) {
      logWarning('RideTracking', 'No option selected');
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.pleaseSelectOption);
      return false;
    }

    HapticFeedback.mediumImpact();

    final rideProvider = context.read<RideTrackingProvider>();
    final ratingProvider = context.read<RatingProvider>();

    final isPassenger = rideProvider.isPassengerMode;
    final rideId = rideProvider.rideId;
    final receiverId = isPassenger
        ? rideProvider.driverId
        : rideProvider.passengerId;

    if (rideId == null || receiverId == null) {
      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.rideInfoNotAvailable);
      return false;
    }

    final success = await ratingProvider.submitRating(
      rideId: rideId,
      receiverId: receiverId,
      ratingValueId: selectedOptionId,
      ratingType: isPassenger
          ? RatingType.passengerToDriver
          : RatingType.driverToPassenger,
      comment: null,
    );

    if (success && context.mounted) {
      logSuccess('RideTracking', 'Rating submitted successfully');
      SnackBarService(
        context,
      ).showSuccess(AppLocalizations.of(context)!.thankYouForRating);
      return true;
    } else if (context.mounted) {
      logError('RideTracking', 'Rating submission failed');
      SnackBarService(context).showError(
        ratingProvider.errorMessage ??
            AppLocalizations.of(context)!.ratingError,
      );
      return false;
    }

    return false;
  }

  // ==========================================================================
  // UTILITY
  // ==========================================================================

  void _clearChatCache() {
    try {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.clearCurrentChannelCache();
      logSuccess('RideTracking', '✅ Chat cache cleared for ended ride');
    } catch (e) {
      logWarning('RideTracking', '⚠️ Could not clear chat cache: $e');
    }
  }

  Future<bool> handleBackPress(DateTime? lastBackPress) async {
    final now = DateTime.now();

    if (lastBackPress == null ||
        now.difference(lastBackPress) > const Duration(seconds: 2)) {
      SnackBarService(
        context,
      ).showWarning(AppLocalizations.of(context)!.pressAgainToExit);
      HapticFeedback.mediumImpact();
      return false;
    }

    logInfo('RideTracking', '🚪 User double-tapped back - exiting app');
    _exitApp();
    return false;
  }

  void _exitApp() {
    try {
      _clearChatCache();

      final rideProvider = context.read<RideTrackingProvider>();
      rideProvider.clearCallbacks();
      logSuccess('RideTracking', '🧹 Ride callbacks cleared');

      HapticFeedback.heavyImpact();
      SystemNavigator.pop();
      logSuccess('RideTracking', '✅ App exited successfully');
    } catch (e) {
      logError('RideTracking', '❌ Error during app exit: $e');

      try {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } catch (fallbackError) {
        logError('RideTracking', '❌ Fallback exit also failed: $fallbackError');
      }
    }
  }
}
