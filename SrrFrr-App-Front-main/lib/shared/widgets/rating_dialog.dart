/// Rating Dialog Component
///
/// Reusable rating dialog for both passenger-to-driver and driver-to-passenger ratings.
/// Features:
/// - Star rating selector (1-5 stars)
/// - Category-based feedback options from backend
/// - Optional comment field
/// - Responsive design
/// - Haptic feedback
/// - Loading states

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/shared/models/rating.dart';
import 'package:srrfrr_app_front/shared/providers/rating_provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class RatingDialog extends StatefulWidget {
  final String rideId;
  final String receiverId;
  final String receiverName;
  final RatingType ratingType;
  final VoidCallback? onSuccess;

  const RatingDialog({
    super.key,
    required this.rideId,
    required this.receiverId,
    required this.receiverName,
    required this.ratingType,
    this.onSuccess,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  int _selectedStars = 0;
  String? _selectedOptionId;
  final TextEditingController _commentController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingProvider>().loadRatingValues();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _selectStar(int stars) {
    setState(() {
      _selectedStars = stars;
      _selectedOptionId = null;
    });
    HapticFeedback.selectionClick();

    final provider = context.read<RatingProvider>();
    provider.loadRatingValues(level: stars);
  }

  Future<void> _submitRating() async {

    if (_selectedStars == 0) {
      SnackBarService(context).showError(AppLocalizations.of(context)!.pleaseSelectRating);
      return;
    }

    if (_selectedOptionId == null) {
      SnackBarService(context).showError(AppLocalizations.of(context)!.pleaseSelectOption);
      return;
    }

    HapticFeedback.mediumImpact();

    final provider = context.read<RatingProvider>();
    final success = await provider.submitRating(
      rideId: widget.rideId,
      receiverId: widget.receiverId,
      ratingValueId: _selectedOptionId!,
      ratingType: widget.ratingType,
      comment: _commentController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
      widget.onSuccess?.call();
    } else if (mounted) {
      SnackBarService(context).showError(provider.errorMessage ?? AppLocalizations.of(context)!.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxDialogHeight = screenHeight * 0.85; // Max 85% of screen height

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxDialogHeight,
            maxWidth: 500, // Max width for larger screens
          ),
          child: Consumer<RatingProvider>(
            builder: (context, provider, _) {
              final currentOptions = _selectedStars > 0
                  ? provider.getOptionsForLevel(_selectedStars)
                  : <RatingValueOption>[];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingXL),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            _buildHeader(l10n),

                            const SizedBox(height: AppSizes.paddingL),

                            // Star Rating
                            _buildStarRating(),

                            const SizedBox(height: AppSizes.paddingL),

                            // Rating Options
                            if (_selectedStars > 0 && provider.isLoading)
                              const Padding(
                                padding: EdgeInsets.all(AppSizes.paddingL),
                                child: CircularProgressIndicator(),
                              ),

                            if (_selectedStars > 0 &&
                                !provider.isLoading &&
                                currentOptions.isNotEmpty)
                              _buildRatingOptions(currentOptions, l10n),

                            if (_selectedStars > 0 &&
                                !provider.isLoading &&
                                currentOptions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppSizes.paddingL,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.noOptionsAvailable,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        provider.loadRatingValues(
                                          level: _selectedStars,
                                        );
                                      },
                                      child: Text(l10n.tryAgain),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingXL,
                      AppSizes.paddingM,
                      AppSizes.paddingXL,
                      AppSizes.paddingXL,
                    ),
                    child: _buildActions(provider, l10n),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final isDriverRating = widget.ratingType == RatingType.driverToPassenger;

    final displayName = widget.receiverName.trim().isEmpty
        ? l10n.user
        : widget.receiverName;
    final initial = displayName.substring(0, 1).toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          isDriverRating ? l10n.ratePassenger : l10n.rateDriver,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          l10n.howWasYourExperience(displayName),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Wrap(
      spacing: 4,
      alignment: WrapAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= _selectedStars;

        return GestureDetector(
          onTap: () => _selectStar(starNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 40,
              color: isSelected ? const Color(0xFFFBBF24) : AppColors.grey400,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRatingOptions(
    List<RatingValueOption> options,
    AppLocalizations l10n,
  ) {
    logDebug('RatingDialog', 'Building ${options.length} rating options');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.selectCategory,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        ...options.map((option) {
          final isSelected = _selectedOptionId == option.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  logInfo('RatingDialog', 'Option selected: ${option.id}');
                  setState(() => _selectedOptionId = option.id);
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
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
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.grey400,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: Text(
                          option.getLabel(context),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActions(RatingProvider provider, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: provider.isSubmitting
                ? null
                : () {
                    Navigator.of(context).pop(false);
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              side: const BorderSide(color: AppColors.grey400),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: FilledButton(
            onPressed: provider.isSubmitting || _selectedStars == 0
                ? null
                : _submitRating,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            child: provider.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.send,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

Future<bool?> showRatingDialog({
  required BuildContext context,
  required String rideId,
  required String receiverId,
  required String receiverName,
  required RatingType ratingType,
  VoidCallback? onSuccess,
}) {
  logInfo('RatingDialog', 'Showing rating dialog');
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => RatingDialog(
      rideId: rideId,
      receiverId: receiverId,
      receiverName: receiverName,
      ratingType: ratingType,
      onSuccess: onSuccess,
    ),
  );
}
