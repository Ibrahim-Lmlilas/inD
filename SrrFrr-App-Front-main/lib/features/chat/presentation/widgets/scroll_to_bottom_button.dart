/// Scroll to bottom button widget
///
/// Path: lib/features/chat/presentation/widgets/scroll_to_bottom_button.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;

  const ScrollToBottomButton({
    super.key,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 110,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
