/// Support Report Bottom Sheet - MODAL STYLE
///
/// A bottom sheet for submitting ride support reports
/// Matches RideOptionsPanel style with bottom-to-top animation
///
/// Usage:
/// ```dart
/// showReportBottomSheet(
///   context: context,
///   rideId: ride.id,
///   onSuccess: () {
///     SnackBarService(context).showSuccess('Réclamation envoyée avec succès');
///   },
/// );
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/support/data/services/support_service.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

/// Shows a support report bottom sheet for a specific ride
Future<void> showReportBottomSheet({
  required BuildContext context,
  required String rideId,
  VoidCallback? onSuccess,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SupportReportBottomSheet(
      rideId: rideId,
      onSuccess: onSuccess,
    ),
  );
}

class _SupportReportBottomSheet extends StatefulWidget {
  final String rideId;
  final VoidCallback? onSuccess;

  const _SupportReportBottomSheet({required this.rideId, this.onSuccess});

  @override
  State<_SupportReportBottomSheet> createState() =>
      _SupportReportBottomSheetState();
}

class _SupportReportBottomSheetState extends State<_SupportReportBottomSheet> {
  final TextEditingController _reportController = TextEditingController();
  final SupportService _apiService = SupportService(ApiInterceptor());
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final content = _reportController.text.trim();

    if (content.isEmpty) {
      SnackBarService(context).showError('Veuillez décrire votre problème');
      return;
    }

    if (content.length < 10) {
      SnackBarService(context).showError(
        'Veuillez fournir plus de détails (minimum 10 caractères)',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      HapticFeedback.lightImpact();

      final response = await _apiService.sendReport(
        content: content,
        rideId: widget.rideId,
        categorie: 'RIDE',
      );

      if (mounted) {
        if (response['success'] == true) {
          Navigator.of(context).pop();
          widget.onSuccess?.call();
        } else {
          logError(
            'ReportDialog',
            'Error sending report: ${response['message']}',
          );
          SnackBarService(context).showError(
            'Erreur lors de l\'envoi de la réclamation.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(
          'Erreur de connexion. Veuillez réessayer.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppSizes.radiusXS),
            ),
          ),

          // Header
          _buildHeader(context, l10n),

          // Divider
          Divider(height: 1, color: AppColors.grey200),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: AppSizes.paddingXL,
                right: AppSizes.paddingXL,
                top: AppSizes.paddingXL,
                bottom: keyboardHeight + AppSizes.paddingXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info message
                  _buildInfoMessage(l10n),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Text input field
                  _buildTextField(l10n),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Actions
                  _buildActions(l10n),

                  const SizedBox(height: AppSizes.paddingM),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactSupport,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.trajectoryRef(widget.rideId.substring(0, 8)),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 18,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              l10n.describeYourProblemInDetail,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.describeProblem,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.minCharacters,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.grey300, width: 1),
          ),
          child: TextField(
            controller: _reportController,
            maxLines: 6,
            maxLength: 500,
            enabled: !_isSubmitting,
            autofocus: false,
            decoration: InputDecoration(
              hintText: l10n.exampleReclamation,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(AppSizes.paddingL),
              counterStyle: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isSubmitting ? AppColors.grey300 : AppColors.primary,
              foregroundColor:
                  _isSubmitting ? AppColors.grey400 : Colors.white,
              elevation: 0,
              disabledBackgroundColor: AppColors.grey300,
              disabledForegroundColor: AppColors.grey400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 20),
                      SizedBox(width: AppSizes.paddingM),
                      Text(
                        l10n.sendComplaintButton,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.grey300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}