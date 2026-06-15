/// Empty chat state widget
///
/// Path: lib/features/chat/presentation/widgets/empty_chat_state.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Commencez la conversation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les messages sont chiffrés de bout en bout',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
