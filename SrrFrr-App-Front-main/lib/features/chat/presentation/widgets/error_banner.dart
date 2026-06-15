/// Error banner widget
///
/// Path: lib/features/chat/presentation/widgets/error_banner.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

class ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const ErrorBanner({super.key, required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: AppColors.error),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
