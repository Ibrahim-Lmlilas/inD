/// Quick reply chip widget
///
/// Path: lib/features/chat/presentation/widgets/quick_reply_chip.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

class QuickReplyChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const QuickReplyChip({super.key, required this.text, required this.onTap});

  @override
  State<QuickReplyChip> createState() => _QuickReplyChipState();
}

class _QuickReplyChipState extends State<QuickReplyChip> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _isSending
            ? null
            : () async {
                if (_isSending) return;

                setState(() => _isSending = true);

                // Small delay to prevent double-tap
                await Future.delayed(const Duration(milliseconds: 100));
                widget.onTap();

                // Reset after 1 second
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() => _isSending = false);
                  }
                });
              },
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: _isSending ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isSending ? AppColors.grey400 : AppColors.grey300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSending) ...[
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isSending
                        ? AppColors.grey400
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
