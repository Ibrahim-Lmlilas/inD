/// Chat Feature - Barrel File
///
/// Single export point for the chat feature
/// Path: lib/features/chat/chat_feature.dart

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/chat_models.dart';

// Repositories
export 'data/repositories/chat_repository.dart';

// Services
export 'data/services/chat_ws_service.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Pages
export 'presentation/pages/chat.dart';

// Providers
export 'presentation/providers/chat_provider.dart';

// Widgets
export 'presentation/widgets/connection_banner.dart';
export 'presentation/widgets/date_separator.dart';
export 'presentation/widgets/empty_chat_state.dart';
export 'presentation/widgets/message_bubble.dart';
export 'presentation/widgets/error_banner.dart';
export 'presentation/widgets/loading_indicator.dart';
export 'presentation/widgets/quick_reply_chip.dart';
export 'presentation/widgets/scroll_to_bottom_button.dart';


