// Ride Tracking Dialogs
//
// Contains all dialog widgets for ride tracking

library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/ride_tracking_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/models/rating.dart';
import '../../../../shared/widgets/rating_dialog.dart';

// =============================================================================
// RIDE CANCELLATION DIALOG
// =============================================================================

class RideCancellationDialog extends StatelessWidget {
  final String? cancelledBy;
  final String? reason;

  const RideCancellationDialog({
    super.key,
    required this.cancelledBy,
    required this.reason,
  });

  void _navigateToHome(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final destination = userProvider.isDriverMode ? '/driver-home' : '/home';
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Course annulée',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La course a été annulée',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (reason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Raison: $reason',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToHome(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// RIDE COMPLETION DIALOG
// =============================================================================

class RideCompletionDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool hasRatedDuringRide;

  const RideCompletionDialog({
    super.key,
    required this.data,
    required this.hasRatedDuringRide,
  });

  @override
  State<RideCompletionDialog> createState() => _RideCompletionDialogState();
}

class _RideCompletionDialogState extends State<RideCompletionDialog> {
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    _hasRated = widget.hasRatedDuringRide;
  }

  @override
  Widget build(BuildContext context) {
    final rideId = widget.data['rideId'] as String?;

    final rideProvider = context.read<RideTrackingProvider>();
    final userProvider = context.read<UserProvider>();

    final isPassenger = rideProvider.isPassengerMode;
    final receiverId = isPassenger
        ? rideProvider.driverId
        : rideProvider.passengerId;
    final receiverName = isPassenger
        ? rideProvider.driverName
        : rideProvider.passengerName;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Course terminée !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Merci d\'avoir voyagé avec nous',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!_hasRated && rideId != null && receiverId != null) ...[
              const Text(
                'Notez votre expérience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final result = await showRatingDialog(
                    context: context,
                    rideId: rideId,
                    receiverId: receiverId,
                    receiverName: receiverName ?? 'Utilisateur',
                    ratingType: isPassenger
                        ? RatingType.passengerToDriver
                        : RatingType.driverToPassenger,
                    onSuccess: () {
                      setState(() => _hasRated = true);
                    },
                  );

                  if (result == true) {
                    setState(() => _hasRated = true);
                  }
                },
                icon: const Icon(Icons.star_rounded),
                label: Text(
                  isPassenger ? 'Noter le chauffeur' : 'Noter le passager',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_hasRated) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Text(
                      'Merci pour votre évaluation!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  final destination = userProvider.isDriverMode
                      ? '/driver-home'
                      : '/home';
                  context.go(destination);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Terminer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CONFIRMATION DIALOG
// =============================================================================

Future<bool?> showFinishRideConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Terminer la course?'),
      content: const Text(
        'Confirmez-vous être arrivé à destination et vouloir terminer cette course?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );
}

// =============================================================================
// NAVIGATION APP SELECTOR DIALOG
// =============================================================================

Future<String?> showNavigationAppSelector(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Choisir une application de navigation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavigationOption(
            label: 'Waze',
            icon: Icons.navigation_rounded,
            color: const Color(0xFF33CCFF),
            onTap: () => Navigator.pop(context, 'waze'),
          ),
          const SizedBox(height: 12),
          _NavigationOption(
            label: 'Google Maps',
            icon: Icons.map_rounded,
            color: const Color(0xFF4285F4),
            onTap: () => Navigator.pop(context, 'google'),
          ),
        ],
      ),
    ),
  );
}

class _NavigationOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
