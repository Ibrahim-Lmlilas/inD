// features/ride_tracking/presentation/widgets/buttons/communication_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommunicationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const CommunicationButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Material(
      color: isDisabled ? color.withValues(alpha: 0.3) : color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
