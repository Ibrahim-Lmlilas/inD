// features/ride_tracking/presentation/widgets/cards/route_info_card.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/features/ride_tracking/presentation/widgets/cards/glass_card.dart';
import '../../../../../core/constants/app_colors.dart';

class RouteInfoCard extends StatelessWidget {
  final String? departureAddress;
  final String? destinationAddress;

  const RouteInfoCard({
    super.key,
    required this.departureAddress,
    required this.destinationAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: GlassCard(
        child: Column(
          children: [
            _LocationRow(
              icon: Icons.trip_origin_rounded,
              text: departureAddress!,
              color: const Color(0xFF10B981),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 22),
                  Container(
                    width: 2,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.3),
                          const Color(0xFFDC2626).withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _LocationRow(
              icon: Icons.location_on_rounded,
              text: destinationAddress!,
              color: const Color(0xFFDC2626),
            ),
          ],
        ),        
      ),

    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _LocationRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
