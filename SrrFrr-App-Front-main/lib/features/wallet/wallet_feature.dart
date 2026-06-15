// Wallet Feature - Barrel File
//
// Single export point for the wallet feature
// Path: lib/features/wallet/wallet_feature.dart

// ============================================================================
// DATA LAYER
// ============================================================================

// Models
export 'data/models/wallet.dart';
export 'data/models/wallet_transaction.dart';
export 'data/models/wallet_statistics.dart';
export 'data/models/recharge_code.dart';

// Repositories
export 'data/repositories/wallet_repository.dart';

// Services
export 'data/services/wallet_service.dart';

// ============================================================================
// PRESENTATION LAYER
// ============================================================================

// Pages
export 'presentation/pages/wallet_page.dart';

// Providers
export 'presentation/providers/wallet_provider.dart';

// Widgets - Tabs
export 'presentation/widgets/tabs/overview_tab.dart';
export 'presentation/widgets/tabs/history_tab.dart';
export 'presentation/widgets/tabs/recharge_codes_tab.dart';

// Widgets - Components
export 'presentation/widgets/balance_card.dart';
export 'presentation/widgets/month_breakdown_card.dart';
export 'presentation/widgets/recent_transactions.dart';
export 'presentation/widgets/statistics_cards.dart';
export 'presentation/widgets/transaction_tile.dart';
export 'presentation/widgets/weekly_chart.dart';

// Widgets - Dialogs
export 'presentation/widgets/dialogs/recharge_dialogs.dart';
