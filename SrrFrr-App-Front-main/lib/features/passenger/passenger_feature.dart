/// Passenger Feature Module
///
/// Handles passenger ride booking flow including location selection,
/// ride configuration, driver matching, and price negotiation.
///
/// Features
/// - GPS location detection and map-based selection
/// - Google Places autocomplete search
/// - Automatic ride type detection
/// - Dynamic pricing with minimum fare calculation
/// - Real-time driver offers via WebSocket
/// - Payment method selection (Cash/Free Ride)

library passenger_feature;

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/driver_offer.dart';
export 'data/models/ride_request.dart';

// Repositories
export 'data/repositories/ride_repository.dart';

// Services (WebSocket communication)
export 'data/services/passenger_ws_service.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Providers
export 'presentation/providers/driver_provider.dart';
export 'presentation/providers/passenger_ws_provider.dart';
export 'presentation/providers/ride_config_provider.dart';

// Pages
export 'presentation/pages/home.dart';
export 'presentation/pages/drivers_offers.dart';

// Widgets - Home Page
export 'presentation/widgets/location_input_card.dart';
export 'presentation/widgets/map_widget.dart';
export 'presentation/widgets/map_selection_overlay.dart';
export 'presentation/widgets/ride_options_panel.dart';
export 'presentation/widgets/payment_section.dart';
export 'presentation/widgets/passenger_drawer.dart';

// Widgets - Driver Offers Page
export 'presentation/widgets/price_control_widget.dart';
