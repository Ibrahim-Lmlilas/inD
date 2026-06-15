/// Widget de sélection du type de véhicule
///
/// Sélecteur déroulant moderne pour les types de véhicules avec animations
/// Supports : VOITURE, MOTO, CAMION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/vehicle_type.dart';

class VehicleTypeSelector extends StatefulWidget {
  final VehicleType selectedType;
  final Function(VehicleType) onTypeChanged;

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  State<VehicleTypeSelector> createState() => _VehicleTypeSelectorState();
}

class _VehicleTypeSelectorState extends State<VehicleTypeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vehicleType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: _toggleExpansion,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: _isExpanded ? AppColors.primary : AppColors.grey300,
                width: _isExpanded ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isExpanded ? AppColors.primary : Colors.black)
                      .withValues(alpha: _isExpanded ? 0.1 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildVehicleIcon(widget.selectedType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedType.label(l10n),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.selectedType.subtitle(l10n),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: VehicleType.values.map((type) {
                  final isLast = type == VehicleType.values.last;
                  return Column(
                    children: [
                      _buildVehicleTypeOption(type, l10n), // Pass l10n here
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleIcon(VehicleType type) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Icon(type.icon, color: type.color, size: 22),
    );
  }

  Widget _buildVehicleTypeOption(VehicleType type, AppLocalizations l10n) {
    final isSelected = widget.selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onTypeChanged(type);
          HapticFeedback.selectionClick();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _toggleExpansion();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(type.icon, color: type.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label(l10n), // Pass l10n here
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.subtitle(l10n), // Pass l10n here
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: type.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}