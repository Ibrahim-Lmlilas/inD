// features/ride_tracking/presentation/widgets/rating/embedded_rating_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/models/rating.dart';
import 'package:srrfrr_app_front/shared/providers/rating_provider.dart';


class RatingWidget extends StatefulWidget {
  final bool hasRated;
  final String? otherUserName;
  final Function(int) onStarSelected;
  final Function(String) onOptionSelected;
  final Function() onSubmit;
  final int selectedStars;
  final String? selectedOptionId;

  const RatingWidget({
    super.key,
    required this.hasRated,
    required this.otherUserName,
    required this.onStarSelected,
    required this.onOptionSelected,
    required this.onSubmit,
    required this.selectedStars,
    required this.selectedOptionId,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.hasRated) {
      return _RatingSuccessCard();
    }

    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, _) {
        final currentOptions = widget.selectedStars > 0
            ? ratingProvider.getOptionsForLevel(widget.selectedStars)
            : <RatingValueOption>[];

        return _RatingInputCard(
          otherUserName: widget.otherUserName,
          selectedStars: widget.selectedStars,
          selectedOptionId: widget.selectedOptionId,
          currentOptions: currentOptions,
          isLoading: ratingProvider.isLoading,
          isSubmitting: ratingProvider.isSubmitting,
          onStarSelected: widget.onStarSelected,
          onOptionSelected: widget.onOptionSelected,
          onSubmit: widget.onSubmit,
        );
      },
    );
  }
}

class _RatingSuccessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.thankYouForYourFeedback,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingInputCard extends StatelessWidget {
  final String? otherUserName;
  final int selectedStars;
  final String? selectedOptionId;
  final List<RatingValueOption> currentOptions;
  final bool isLoading;
  final bool isSubmitting;
  final Function(int) onStarSelected;
  final Function(String) onOptionSelected;
  final VoidCallback onSubmit;

  const _RatingInputCard({
    required this.otherUserName,
    required this.selectedStars,
    required this.selectedOptionId,
    required this.currentOptions,
    required this.isLoading,
    required this.isSubmitting,
    required this.onStarSelected,
    required this.onOptionSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFBBF24).withValues(alpha: 0.15),
            const Color(0xFFF59E0B).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.rateUser(otherUserName!),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _StarRating(
            selectedStars: selectedStars,
            onStarSelected: onStarSelected,
          ),
          if (selectedStars > 0) ...[
            const SizedBox(height: 16),
            _RatingOptions(
              currentOptions: currentOptions,
              selectedOptionId: selectedOptionId,
              isLoading: isLoading,
              onOptionSelected: onOptionSelected,
            ),
            if (selectedOptionId != null) ...[
              const SizedBox(height: 12),
              _SubmitButton(isSubmitting: isSubmitting, onSubmit: onSubmit),
            ],
          ],
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int selectedStars;
  final Function(int) onStarSelected;

  const _StarRating({
    required this.selectedStars,
    required this.onStarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= selectedStars;

        return GestureDetector(
          onTap: () {
            onStarSelected(starNumber);
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 36,
              color: isSelected ? const Color(0xFFFBBF24) : AppColors.grey400,
            ),
          ),
        );
      }),
    );
  }
}

class _RatingOptions extends StatelessWidget {
  final List<RatingValueOption> currentOptions;
  final String? selectedOptionId;
  final bool isLoading;
  final Function(String) onOptionSelected;

  const _RatingOptions({
    required this.currentOptions,
    required this.selectedOptionId,
    required this.isLoading,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }

    if (currentOptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          AppLocalizations.of(context)!.noOptionsAvailable,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: currentOptions.map((option) {
        final isSelected = selectedOptionId == option.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onOptionSelected(option.id);
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.grey50,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFBBF24)
                        : AppColors.grey300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? const Color(0xFFFBBF24)
                          : AppColors.grey400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.getLabel(context),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitButton({required this.isSubmitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFBBF24),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.sendEvaluation,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}