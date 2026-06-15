/// Notifications Feature Module
///
/// Provides real-time notification management with WebSocket and FCM integration.
///
/// Features
/// - Real-time notifications via WebSocket
/// - Push notifications via FCM
/// - Notification history with pagination
/// - Mark notifications as read (single/all)
/// - Mode switching (passenger/driver)

library;

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/notification.dart';
export 'data/models/notification_type.dart';

// Repository
export 'data/repositories/notifications_repository.dart';

// Services
export 'data/services/notification_service.dart';
export 'data/services/notification_api_service.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Providers
export 'presentation/providers/notification_provider.dart';

// Pages
export 'presentation/pages/notifications.dart';

// Widgets
export 'presentation/widgets/notification_card.dart';
export 'presentation/widgets/notification_empty_state.dart';
export 'presentation/widgets/notification_loading.dart';
export 'presentation/widgets/notification_app_bar.dart';
