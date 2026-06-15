/// Date separator widget
///
/// Path: lib/features/chat/presentation/widgets/date_separator.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String label;
    if (messageDate == today) {
      label = 'Aujourd\'hui';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      label = 'Hier';
    } else {
      label = DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
