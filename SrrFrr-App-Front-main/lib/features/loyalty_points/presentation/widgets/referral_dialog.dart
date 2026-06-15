/// Referral Invitation Dialog
///
/// A dialog for inviting friends via phone number or sharing link
/// Features:
/// - Submit phone number for validation and referral
/// - Copy referral link independently
/// - Cancel action
///
/// Usage:
/// ```dart
/// showReferralDialog(
///   context: context,
/// );
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/loyalty_points/data/services/loyalty_service.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

/// Shows a referral invitation dialog
Future<void> showReferralDialog({required BuildContext context}) {
  return showDialog(
    context: context,
    builder: (context) => const _ReferralInvitationDialog(),
  );
}

class _ReferralInvitationDialog extends StatefulWidget {
  const _ReferralInvitationDialog();

  @override
  State<_ReferralInvitationDialog> createState() =>
      _ReferralInvitationDialogState();
}

class _ReferralInvitationDialogState extends State<_ReferralInvitationDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final LoyaltyService loyaltyService = LoyaltyService(ApiInterceptor());
  bool _isProcessing = false;

  // Replace with your actual app URL or Play Store/App Store link
  static const String referralLink = 'https://srrfrr.app';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-numeric characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with +212 or 0
    if (cleaned.startsWith('0')) {
      cleaned = '+212${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+212')) {
      cleaned = '+212$cleaned';
    }

    return cleaned;
  }

  bool _isValidPhoneNumber(String phone) {
    // Check if phone number is valid Moroccan format
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 9 && cleaned.length <= 13;
  }

  Future<void> _submitReferral(AppLocalizations l10n) async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      SnackBarService(context).showError(l10n.pleaseEnterPhoneNumber);
      return;
    }

    if (!_isValidPhoneNumber(phone)) {
      SnackBarService(context).showError(l10n.invalidPhoneNumber);
      return;
    }

    final formattedPhone = _formatPhoneNumber(phone);

    setState(() => _isProcessing = true);

    try {
      HapticFeedback.lightImpact();

      // Call backend API to validate and save referral
      final response = await loyaltyService.sendInvitation(
        phoneNumber: formattedPhone,
      );

      if (mounted) {
        if (response['success'] == true) {
          // Backend validated and saved the referral
          SnackBarService(context).showSuccess(l10n.invitationRegistered);
          _phoneController.clear();
        } else {
          SnackBarService(
            context,
          ).showError(response['message'] ?? l10n.phoneNotEligible);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(l10n.networkError);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _copyReferralLink(AppLocalizations l10n) async {
    try {
      HapticFeedback.lightImpact();

      await Clipboard.setData(const ClipboardData(text: referralLink));

      if (mounted) {
        SnackBarService(context).showSuccess(l10n.linkCopied);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(l10n.errorCopyingLink);
      }
    }
  }

  Future<void> _shareReferralLink(AppLocalizations l10n) async {
    try {
      HapticFeedback.lightImpact();


      // Share using the share_plus package
      await Share.share(l10n.referralShareMessage(referralLink), subject: l10n.referralInvitationSubject);

      if (mounted) {
        SnackBarService(context).showSuccess(l10n.linkSharedSuccess);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(l10n.errorSharing);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.referAFriend,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.earnPointsPerFriend,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // IconButton(
                //   icon: Icon(Icons.close, color: AppColors.textSecondary),
                //   onPressed: () => Navigator.of(context).pop(),
                //   padding: EdgeInsets.zero,
                //   constraints: const BoxConstraints(),
                // ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingXL),

            // Info message
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.referralInfoMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingXL),

            // Phone number input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.phoneNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isProcessing,
                  decoration: InputDecoration(
                    hintText: "+212 6XX XXX XXX",
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                      vertical: AppSizes.paddingM,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingL),

            // Submit phone button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _submitReferral(l10n),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
              label: Text(
                _isProcessing ? l10n.verifying : l10n.savePhoneNumber,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                elevation: 0,
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),

            // Divider with "OU"
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.grey300)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: Text(
                    l10n.or,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.grey300)),
              ],
            ),

            const SizedBox(height: AppSizes.paddingL),

            // Copy link section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.referralLink,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    referralLink,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingM),

            // Action buttons row: Share and Copy
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareReferralLink(l10n),
                    icon: const Icon(Icons.share, size: 20, color: Colors.white),
                    label: Text(
                      l10n.share,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyReferralLink(l10n),
                    icon: const Icon(Icons.copy, size: 20, color: Colors.white),
                    label: Text(
                      l10n.copy,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingL),

            // Cancel button
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                l10n.close,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
