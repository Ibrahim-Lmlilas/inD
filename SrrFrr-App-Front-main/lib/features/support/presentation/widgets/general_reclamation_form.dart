// General Reclamation Form Widget
// Form for submitting general complaints/reclamations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/features/support/data/models/support_models.dart';
import 'package:srrfrr_app_front/features/support/data/repositories/support_repository.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class GeneralReclamationForm extends StatefulWidget {
  final SupportRepository repository;

  const GeneralReclamationForm({super.key, required this.repository});

  @override
  State<GeneralReclamationForm> createState() => _GeneralReclamationFormState();
}

class _GeneralReclamationFormState extends State<GeneralReclamationForm> {
  final TextEditingController _contentController = TextEditingController();
  ReportCategory _selectedCategory = ReportCategory.technique;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReclamation() async {
    final l10n = AppLocalizations.of(context)!;
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      SnackBarService(context).showError(l10n.pleaseDescribeProblem);
      return;
    }

    if (content.length < 10) {
      SnackBarService(context).showError(l10n.provideMoreDetails);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      HapticFeedback.lightImpact();

      final report = Report(
        content: content,
        category: _selectedCategory.value,
        rideId: '', // No ride ID for general reclamation
      );

      await widget.repository.sendReport(report);

      if (mounted) {
        _contentController.clear();
        SnackBarService(context).showSuccess(l10n.complaintSent);
      }
    } on SupportException catch (e) {
      if (mounted) {
        SnackBarService(context).showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService(context).showError(l10n.connectionError);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCategorySelector(l10n),
        const SizedBox(height: 16),
        _buildContentField(l10n),
        const SizedBox(height: 16),
        _buildSubmitButton(l10n),
      ],
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.grey300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReportCategory>(
              value: _selectedCategory,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              items: ReportCategory.all.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedCategory = value);
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.description,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 6,
          maxLength: 500,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: l10n.describeYourProblem,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 14,
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
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.all(AppSizes.paddingL),
            counterStyle: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitReclamation,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        elevation: 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              l10n.sendComplaintButton,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }
}
