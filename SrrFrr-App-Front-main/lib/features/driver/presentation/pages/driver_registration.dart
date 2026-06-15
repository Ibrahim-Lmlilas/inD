// Driver Registration Page
//
// Multi-step registration flow for drivers:
// Step 1: CIN Information (front, back, code, selfie, expiration date)
// Step 2: Vehicle Information (type, picture, registration, brand, model, color, year)
// Step 3: Review & Submit

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'dart:io';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/features/driver/data/services/driver_service.dart';
import 'package:srrfrr_app_front/shared/models/vehicle_type.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/shared/widgets/vehicle_type_selector.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

enum DriverRegistrationStep { cinInformation, vehicleInformation, reviewSubmit }

class DriverRegistrationPage extends StatefulWidget {
  final bool isReapplying;

  const DriverRegistrationPage({super.key, this.isReapplying = false});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  DriverRegistrationStep _currentStep = DriverRegistrationStep.cinInformation;

  // CIN Information
  final _cinCodeController = TextEditingController();
  DateTime? _expirationDate;
  String? _cinRectoPath;
  String? _cinVersoPath;
  String? _selfiePath;

  // Vehicle Information
  final _vehicleRegistrationCodeController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _productionYearController = TextEditingController();
  VehicleType _vehicleType = VehicleType.car;

  String? _vehiclePicturePath;
  String? _vehicleRegistrationRectoPath;
  String? _vehicleRegistrationVersoPath;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _cinCodeController.dispose();
    _vehicleRegistrationCodeController.dispose();
    _vehicleBrandController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _productionYearController.dispose();
    super.dispose();
  }

  bool _canProceedFromCin() {
    return _cinCodeController.text.isNotEmpty &&
        _expirationDate != null &&
        _cinRectoPath != null &&
        _cinVersoPath != null &&
        _selfiePath != null;
  }

  bool _canProceedFromVehicle() {
    return _vehicleRegistrationCodeController.text.isNotEmpty &&
        _vehicleBrandController.text.isNotEmpty &&
        _vehicleModelController.text.isNotEmpty &&
        _vehicleColorController.text.isNotEmpty &&
        _productionYearController.text.isNotEmpty &&
        _vehiclePicturePath != null &&
        _vehicleRegistrationRectoPath != null &&
        _vehicleRegistrationVersoPath != null;
  }

  Future<void> _pickImage(Function(String) onImagePicked) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => onImagePicked(image.path));
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _expirationDate = picked);
      HapticFeedback.selectionClick();
    }
  }

  void _nextStep() {
    if (_currentStep == DriverRegistrationStep.cinInformation &&
        _canProceedFromCin()) {
      setState(() => _currentStep = DriverRegistrationStep.vehicleInformation);
    } else if (_currentStep == DriverRegistrationStep.vehicleInformation &&
        _canProceedFromVehicle()) {
      setState(() => _currentStep = DriverRegistrationStep.reviewSubmit);
    }
  }

  // FIX: Updated to properly handle back navigation with mode switching
  Future<void> _previousStep() async {
    if (_currentStep == DriverRegistrationStep.vehicleInformation) {
      setState(() => _currentStep = DriverRegistrationStep.cinInformation);
    } else if (_currentStep == DriverRegistrationStep.reviewSubmit) {
      setState(() => _currentStep = DriverRegistrationStep.vehicleInformation);
    } else {
      // FIX: Switch back to passenger mode when exiting registration
      await _switchToPassengerAndNavigate();
    }
  }

  // FIX: New method to handle mode switching and navigation
  Future<void> _switchToPassengerAndNavigate() async {
    try {
      final userProvider = context.read<UserProvider>();

      // Switch to passenger mode
      await userProvider.switchMode(UserMode.passenger);

      if (!mounted) return;

      // Navigate to home
      context.go('/home');
    } catch (e) {
      logError('driver_registration', 'Error switching mode: $e');

      // Fallback: just navigate to home
      if (!mounted) return;
      context.go('/home');
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    try {
      final driverService = DriverService(ApiInterceptor());

      // Format expiration date as YYYY-MM-DD
      final formattedDate = _expirationDate != null
          ? '${_expirationDate!.year}-${_expirationDate!.month.toString().padLeft(2, '0')}-${_expirationDate!.day.toString().padLeft(2, '0')}'
          : '';

      final response = await driverService.createDriverAccount(
        cinRecto: _cinRectoPath!,
        cinVerso: _cinVersoPath!,
        cinCode: _cinCodeController.text,
        selfie: _selfiePath!,
        expirationDate: formattedDate,
        vehicleType: _vehicleType.backendValue,
        vehiclePicture: _vehiclePicturePath!,
        vehicleRegistrationRecto: _vehicleRegistrationRectoPath!,
        vehicleRegistrationVerso: _vehicleRegistrationVersoPath!,
        vehicleRegistrationCode: _vehicleRegistrationCodeController.text,
        vehicleBrand: _vehicleBrandController.text,
        vehicleModel: _vehicleModelController.text,
        vehicleColor: _vehicleColorController.text,
        productionYear: _productionYearController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        // Refresh driver profile in UserProvider
        final userProvider = context.read<UserProvider>();
        await userProvider.fetchDriverProfile();

        if (!mounted) return;

        // Show success message
        SnackBarService(
          context,
        ).showSuccess(AppLocalizations.of(context)!.submittedSuccessfully);

        // Navigate back to driver status page
        context.go('/driver-status');
      } else {
        // Show error message
        logError(
          'driver_registration',
          response['message'] ?? AppLocalizations.of(context)!.submissionError,
        );
        SnackBarService(
          context,
        ).showError(AppLocalizations.of(context)!.submissionError);
      }
    } catch (e) {
      if (!mounted) return;

      SnackBarService(
        context,
      ).showError(AppLocalizations.of(context)!.submissionError);
      logError('driver_registration', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: _previousStep,
        ),
        title: Text(
          widget.isReapplying ? l10n.newApplication : l10n.driverRegistration,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: _buildCurrentStep(l10n),
            ),
          ),
          _buildBottomButton(l10n),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final currentIndex = _currentStep.index;
    const totalSteps = 3;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case DriverRegistrationStep.cinInformation:
        return _buildCinInformationStep(l10n);
      case DriverRegistrationStep.vehicleInformation:
        return _buildVehicleInformationStep(l10n);
      case DriverRegistrationStep.reviewSubmit:
        return _buildReviewSubmitStep(l10n);
    }
  }

  Widget _buildCinInformationStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cinInformationTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.cinInformationSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        _buildImageUpload(
          title: l10n.cinRectoPhoto,
          path: _cinRectoPath,
          onTap: () => _pickImage((path) => _cinRectoPath = path),
          l10n: l10n,
        ),
        const SizedBox(height: 16),

        _buildImageUpload(
          title: l10n.cinVersoPhoto,
          path: _cinVersoPath,
          onTap: () => _pickImage((path) => _cinVersoPath = path),
          l10n: l10n,
        ),
        const SizedBox(height: 16),

        _buildImageUpload(
          title: l10n.selfieWithCIN,
          path: _selfiePath,
          onTap: () => _pickImage((path) => _selfiePath = path),
          l10n: l10n,
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _cinCodeController,
          decoration: InputDecoration(
            labelText: l10n.cinCode,
            hintText: l10n.cinCodeHint,
            prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),

        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.expirationDate,
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            child: Text(
              _expirationDate != null
                  ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                  : l10n.selectDate,
              style: TextStyle(
                color: _expirationDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInformationStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vehicleInformationTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.vehicleInformationSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        VehicleTypeSelector(
          selectedType: _vehicleType,
          onTypeChanged: (type) => setState(() => _vehicleType = type),
        ),

        const SizedBox(height: 24),

        _buildImageUpload(
          title: l10n.vehiclePhoto,
          path: _vehiclePicturePath,
          onTap: () => _pickImage((path) => _vehiclePicturePath = path),
          l10n: l10n,
        ),
        const SizedBox(height: 16),

        _buildImageUpload(
          title: l10n.vehicleRegistrationRecto,
          path: _vehicleRegistrationRectoPath,
          onTap: () =>
              _pickImage((path) => _vehicleRegistrationRectoPath = path),
          l10n: l10n,
        ),
        const SizedBox(height: 16),

        _buildImageUpload(
          title: l10n.vehicleRegistrationVerso,
          path: _vehicleRegistrationVersoPath,
          onTap: () =>
              _pickImage((path) => _vehicleRegistrationVersoPath = path),
          l10n: l10n,
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _vehicleRegistrationCodeController,
          decoration: InputDecoration(
            labelText: l10n.registrationNumber,
            hintText: l10n.registrationNumberHint,
            prefixIcon: Icon(
              Icons.confirmation_number,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}), // Trigger validation update
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _vehicleBrandController,
          decoration: InputDecoration(
            labelText: l10n.brand,
            hintText: l10n.brandHint,
            prefixIcon: Icon(
              Icons.branding_watermark,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}), // Trigger validation update
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _vehicleModelController,
          decoration: InputDecoration(
            labelText: l10n.model,
            hintText: l10n.modelHint,
            prefixIcon: Icon(Icons.directions_car, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}), // Trigger validation update
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _vehicleColorController,
          decoration: InputDecoration(
            labelText: l10n.color,
            hintText: l10n.colorHint,
            prefixIcon: Icon(Icons.palette, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}), // Trigger validation update
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _productionYearController,
          decoration: InputDecoration(
            labelText: l10n.productionYear,
            hintText: l10n.productionYearHint,
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
          onChanged: (_) => setState(() {}), // Trigger validation update
        ),
      ],
    );
  }

  Widget _buildReviewSubmitStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.reviewSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        _buildReviewSection(
          title: l10n.cinInformationSection,
          items: [
            _buildReviewItem(l10n.cinCodeLabel, _cinCodeController.text),
            _buildReviewItem(
              l10n.expirationDateLabel,
              _expirationDate != null
                  ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                  : '',
            ),
            _buildReviewItem(
              l10n.cinRectoLabel,
              _cinRectoPath != null ? l10n.uploaded : '',
            ),
            _buildReviewItem(
              l10n.cinVersoLabel,
              _cinVersoPath != null ? l10n.uploaded : '',
            ),
            _buildReviewItem(
              l10n.selfieLabel,
              _selfiePath != null ? l10n.uploaded : '',
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildReviewSection(
          title: l10n.vehicleInformationSection,
          items: [
            _buildReviewItem(l10n.vehicleTypeLabel, _vehicleType.label(l10n)),
            _buildReviewItem(
              l10n.registrationNumberLabel,
              _vehicleRegistrationCodeController.text,
            ),
            _buildReviewItem(l10n.brandLabel, _vehicleBrandController.text),
            _buildReviewItem(l10n.modelLabel, _vehicleModelController.text),
            _buildReviewItem(l10n.colorLabel, _vehicleColorController.text),
            _buildReviewItem(l10n.yearLabel, _productionYearController.text),
            _buildReviewItem(
              l10n.vehiclePhotoLabel,
              _vehiclePicturePath != null ? l10n.uploaded : '',
            ),
            _buildReviewItem(
              l10n.vehicleRegistrationRectoLabel,
              _vehicleRegistrationRectoPath != null ? l10n.uploaded : '',
            ),
            _buildReviewItem(
              l10n.vehicleRegistrationVersoLabel,
              _vehicleRegistrationVersoPath != null ? l10n.uploaded : '',
            ),
          ],
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.verificationNotice,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload({
    required String title,
    required String? path,
    required VoidCallback onTap,
    required AppLocalizations l10n,
  }) {
    final hasImage = path != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: hasImage
              ? const Color(0xFF10B981).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: hasImage ? const Color(0xFF10B981) : AppColors.grey300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasImage
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    )
                  : Icon(Icons.camera_alt, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage ? l10n.photoAdded : l10n.tapToTakePhoto,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasImage
                          ? const Color(0xFF10B981)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasImage ? Icons.check_circle : Icons.add_circle_outline,
              color: hasImage
                  ? const Color(0xFF10B981)
                  : AppColors.textSecondary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    final canProceed = _currentStep == DriverRegistrationStep.cinInformation
        ? _canProceedFromCin()
        : _currentStep == DriverRegistrationStep.vehicleInformation
        ? _canProceedFromVehicle()
        : true;

    final buttonText = _currentStep == DriverRegistrationStep.reviewSubmit
        ? l10n.submitApplication
        : l10n.continueButton;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canProceed && !_isLoading
                ? (_currentStep == DriverRegistrationStep.reviewSubmit
                      ? _submitRegistration
                      : _nextStep)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed
                  ? AppColors.primary
                  : AppColors.grey300,
              foregroundColor: Colors.white,
              elevation: canProceed ? 2 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}