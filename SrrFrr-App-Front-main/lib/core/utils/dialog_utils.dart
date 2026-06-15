// Dialog Utilities
//
// Standard dialogs used across the application

library;

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/shared/widgets/notification_system.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class DialogUtils {
  DialogUtils._();

  // Show notification dialog (unified success/error/warning/info)
  static Future<void> showNotificationDialog({
    required BuildContext context,
    required NotificationType type,
    String? title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) {
    final config = NotificationConfig.fromType(type);

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: NotificationIconRow(
          icon: config.icon,
          color: config.backgroundColor,
          child: Text(title ?? config.defaultTitle),
        ),
        content: NotificationContent(message: message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: config.backgroundColor,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Convenience methods for common notification types
  static Future<void> showSuccessDialog({
    required BuildContext context,
    String? title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) => showNotificationDialog(
    context: context,
    type: NotificationType.success,
    title: title,
    message: message,
    buttonText: buttonText,
    onConfirm: onConfirm,
  );

  static Future<void> showErrorDialog({
    required BuildContext context,
    String? title,
    required String message,
    String buttonText = 'OK',
  }) => showNotificationDialog(
    context: context,
    type: NotificationType.error,
    title: title,
    message: message,
    buttonText: buttonText,
  );

  static Future<void> showWarningDialog({
    required BuildContext context,
    String? title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) => showNotificationDialog(
    context: context,
    type: NotificationType.warning,
    title: title,
    message: message,
    buttonText: buttonText,
    onConfirm: onConfirm,
  );

  static Future<void> showInfoDialog({
    required BuildContext context,
    String? title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) => showNotificationDialog(
    context: context,
    type: NotificationType.info,
    title: title,
    message: message,
    buttonText: buttonText,
    onConfirm: onConfirm,
  );

  // Show standard confirmation dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: icon != null
            ? NotificationIconRow(
                icon: icon,
                color: confirmColor ?? AppColors.primary,
                child: Text(title),
              )
            : Text(title),
        content: NotificationContent(message: content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Show selection dialog with radio buttons
  static Future<String?> showSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    String? selectedOption,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _SelectionDialog(
        title: title,
        options: options,
        selectedOption: selectedOption,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  // Show price adjustment dialog
  static Future<int?> showPriceDialog({
    required BuildContext context,
    required int currentPrice,
    required int minimumPrice,
    String title = 'Ajuster le prix',
    String? subtitle,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => _PriceDialog(
        title: title,
        subtitle: subtitle,
        currentPrice: currentPrice,
        minimumPrice: minimumPrice,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  // Show loading dialog
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'Chargement...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: AppSizes.paddingM),
                NotificationContent(message: message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRIVATE DIALOG WIDGETS
// ============================================================================

class _SelectionDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final String confirmText;
  final String cancelText;

  const _SelectionDialog({
    required this.title,
    required this.options,
    this.selectedOption,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  State<_SelectionDialog> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<_SelectionDialog> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.options.map((option) {
          final isSelected = _selected == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selected = option),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected ? AppColors.primary : AppColors.grey400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

class _PriceDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int currentPrice;
  final int minimumPrice;
  final String confirmText;
  final String cancelText;

  const _PriceDialog({
    required this.title,
    this.subtitle,
    required this.currentPrice,
    required this.minimumPrice,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late int _price;

  @override
  void initState() {
    super.initState();
    _price = widget.currentPrice;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _price > widget.minimumPrice
                    ? () => setState(() => _price--)
                    : null,
                icon: Icon(
                  Icons.remove_circle,
                  size: 32,
                  color: _price > widget.minimumPrice
                      ? AppColors.primary
                      : AppColors.grey400,
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              Text(
                '$_price DH',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              IconButton(
                onPressed: () => setState(() => _price++),
                icon: Icon(
                  Icons.add_circle,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: _price == widget.currentPrice
              ? null
              : () => Navigator.pop(context, _price),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
