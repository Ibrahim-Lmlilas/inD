// features/ride_tracking/presentation/widgets/map/top_info_card.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/features/ride_tracking/data/models/ride_tracking_state.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/cards/glass_card.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/common/info_chip.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/common/status_badge.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/profile_picture_widgets.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class InfoCard extends StatelessWidget {
  final RideTrackingState state;

  const InfoCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: GlassCard(
        child: Column(
          children: [
            Row(
              children: [
                _buildUserAvatar(),
                const SizedBox(width: 12),
                Expanded(child: _buildUserInfo(l10n)),
                StatusBadge(
                  rideHasStarted: state.rideHasStarted,
                  driverHasArrived: state.driverHasArrived,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InfoChip(
                    icon: Icons.access_time_rounded,
                    label: l10n.time,
                    value: state.etaMinutes != null
                        ? l10n.etaMinutes(state.etaMinutes!)
                        : '...',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoChip(
                    icon: Icons.straighten_rounded,
                    label: l10n.distance,
                    value: state.distanceKm != null
                        ? '${state.distanceKm!.toStringAsFixed(1)} km'
                        : '...',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final isPassenger = state.isPassengerMode;
    final profilePicture = isPassenger
        ? state.driverProfilePicture
        : state.passengerProfilePicture;
    final name = isPassenger ? state.driverName : state.passengerName;
    final fallbackInitial = (name?.substring(0, 1).toUpperCase() ?? 'U');
    final isVerified = isPassenger ? state.driverIsValidated : false;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfilePictureAvatar(
          imageUrl: profilePicture,
          fallbackText: fallbackInitial,
          size: 56,
          showBorder: true,
          borderColor: Colors.white,
          borderWidth: 3,
          backgroundColor: AppColors.primary,
        ),
        if (isVerified == null)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(AppLocalizations l10n) {
    final name = state.isPassengerMode ? state.driverName : state.passengerName;
    final rating = state.isPassengerMode
        ? state.driverRating
        : state.passengerRating;
    final totalRides = state.isPassengerMode
        ? state.driverTotalRides
        : state.passengerTotalRides;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name ?? (state.isPassengerMode ? l10n.driver : l10n.passengerLabel),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
            const SizedBox(width: 4),
            Text(
              rating != null ? rating.toStringAsFixed(1) : '5.0',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (totalRides != null) ...[
              const SizedBox(width: 4),
              Text(
                '($totalRides)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
