/// Connection banner widget
///
/// Path: lib/features/chat/presentation/widgets/connection_banner.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.warning),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Reconnexion en cours...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
