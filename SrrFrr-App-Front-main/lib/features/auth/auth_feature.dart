/// Auth Feature - Barrel File
///
/// Single export point for the authentication feature
/// Path: lib/features/auth/auth_feature.dart

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/auth_models.dart';

// Repositories
export 'data/repositories/auth_repository.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Pages
export 'presentation/pages/auth.dart';
export 'presentation/pages/pwd_reset.dart';
export 'presentation/pages/registration.dart';

// Providers
export 'presentation/providers/auth_provider.dart';

// Widgets
export 'presentation/widgets/common.dart';
export 'presentation/widgets/kyc_input.dart';
export 'presentation/widgets/otp_verification.dart';
