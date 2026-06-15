/// Price Control Widget
///
/// Allows passengers to adjust their offer price after waiting period.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';

/// Widget for adjusting ride price
class PriceControlWidget extends StatelessWidget {
  final int currentPrice;
  final int minimumPrice;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onApply;

  const PriceControlWidget({
    super.key,
    required this.currentPrice,
    required this.minimumPrice,
    required this.onIncrease,
    required this.onDecrease,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding * 0.75),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: padding * 0.75),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajustez votre offre',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Min: $minimumPrice DH',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PriceButton(icon: Icons.remove, onPressed: onDecrease),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding * 0.75),
                    child: Text(
                      '$currentPrice DH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _PriceButton(icon: Icons.add, onPressed: onIncrease),
                ],
              ),
            ],
          ),
          SizedBox(height: padding * 0.75),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: padding * 0.875),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
              ),
              icon: const Icon(Icons.send, size: 18),
              label: const Text(
                'Appliquer le prix',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Price adjustment button
class _PriceButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _PriceButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Waiting widget shown before price control is enabled
class WaitingForOffersWidget extends StatelessWidget {
  final int secondsElapsed;
  final int secondsRemaining;

  const WaitingForOffersWidget({
    super.key,
    required this.secondsElapsed,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'En attente des offres des conducteurs...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: padding * 0.75),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            child: LinearProgressIndicator(
              value: secondsElapsed / 60,
              minHeight: 6,
              backgroundColor: AppColors.grey100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: padding * 0.5),
          Text(
            secondsRemaining > 0
                ? 'Vous pouvez ajuster le prix dans ${secondsRemaining}s'
                : 'Vous pouvez maintenant ajuster votre prix',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
