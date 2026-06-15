// Wallet Provider - Refactored with Repository Pattern
//
// Manages wallet state and coordinates with repository
// Path: lib/features/wallet/presentation/providers/wallet_provider.dart

import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_statistics.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_transaction.dart';
import 'package:srrfrr_app_front/features/wallet/data/repositories/wallet_repository.dart';
import 'package:srrfrr_app_front/features/wallet/data/services/wallet_service.dart';

// Wallet Provider for managing wallet state
//
// Coordinates between UI and WalletRepository
// Handles loading states, errors, and data transformations
class WalletProvider extends DisposableProvider {
  final WalletRepository _repository;

  WalletProvider({ApiInterceptor? interceptor})
    : _repository = WalletRepository(
        WalletService(interceptor ?? ApiInterceptor()),
      );

  // State
  Wallet? _wallet;
  WalletStatistics? _statistics;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  Wallet? get wallet => _wallet;
  WalletStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // Convenience getters
  double get balance => _wallet?.balance ?? 0.0;
  List<WalletTransaction> get transactions => _wallet?.transactions ?? [];
  bool get hasTransactions => transactions.isNotEmpty;
  List<WalletTransaction> get recentTransactions =>
      _wallet?.recentTransactions ?? [];

  // Statistics getters (with null safety)
  double get totalEarnings => _statistics?.totalEarnings ?? 0.0;
  double get totalDebits => _statistics?.totalDebits ?? 0.0;
  double get totalCredits => totalEarnings;
  double get thisMonthEarnings => _statistics?.thisMonthEarnings ?? 0.0;
  double get thisMonthCommissions => _statistics?.thisMonthCommissions ?? 0.0;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  // Initialize wallet provider
  Future<void> initialize() async {
    if (_isInitialized) {
      logDebug('[WalletProvider]', '⚠️ Already initialized, skipping...');
      return;
    }

    try {
      _isInitialized = true;
      await fetchWallet();
      logSuccess('[WalletProvider]', '✅ WalletProvider initialized');
    } catch (e) {
      logError('[WalletProvider]', '❌ Error initializing: $e');
      _isInitialized = true;
    }
  }

  // ============================================================================
  // WALLET OPERATIONS
  // ============================================================================

  // Fetch wallet data from repository
  Future<bool> fetchWallet() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _repository.getDriverWallet();

      if (result.success && result.data != null) {
        _wallet = result.data;
        _statistics = _repository.calculateStatistics(_wallet!);

        logSuccess(
          '[WalletProvider]',
          '✅ Wallet loaded: ${_wallet!.balance} DH, '
              '${_wallet!.transactions.length} transactions',
        );

        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Erreur lors du chargement');
        return false;
      }
    } catch (e) {
      logError('[WalletProvider]', '❌ Error fetching wallet: $e');
      _setError('Erreur lors du chargement du portefeuille');
      return false;
    }
  }

  // Refresh wallet data
  Future<void> refresh() async {
    logDebug('[WalletProvider]', '🔄 Refreshing wallet...');
    await fetchWallet();
  }

  // ============================================================================
  // TRANSACTION FILTERING
  // ============================================================================

  // Get transactions filtered by type
  List<WalletTransaction> getTransactionsByType(WalletTransactionType type) {
    return _repository.filterByType(transactions, type);
  }

  // Get transactions within date range
  List<WalletTransaction> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _repository.filterByDateRange(transactions, startDate, endDate);
  }

  // Get transactions for current month
  List<WalletTransaction> getThisMonthTransactions() {
    return _repository.getThisMonthTransactions(transactions);
  }

  // Get transactions for previous month
  List<WalletTransaction> getLastMonthTransactions() {
    return _repository.getLastMonthTransactions(transactions);
  }

  // ============================================================================
  // WEEKLY DATA
  // ============================================================================

  // Get weekly earnings data for chart
  List<Map<String, dynamic>> getWeeklyEarnings() {
    return _repository.getWeeklyEarnings(transactions);
  }

  // ============================================================================
  // TRANSACTION GROUPING
  // ============================================================================

  // Group transactions by date for history view
  Map<String, List<WalletTransaction>> groupTransactionsByDate() {
    return _repository.groupTransactionsByDate(transactions);
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  // Get wallet statistics summary
  Map<String, dynamic> getStatistics() {
    if (_statistics == null) return {};
    return _statistics!.toMap();
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    safeNotify();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    safeNotify();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      safeNotify();
    }
  }

  // Clear wallet data
  void clear() {
    _wallet = null;
    _statistics = null;
    _isInitialized = false;
    _clearError();
    safeNotify();
  }

  @override
  void dispose() {
    logDebug('[WalletProvider]', '🗑️ Disposing WalletProvider');
    clear();
    super.dispose();
  }
}
