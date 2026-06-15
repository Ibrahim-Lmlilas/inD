// Wallet Repository - Simplified
//
// Handles wallet data access with clean, simple logic
// Path: lib/features/wallet/data/repositories/wallet_repository.dart

import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_transaction.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_statistics.dart';
import 'package:srrfrr_app_front/features/wallet/data/services/wallet_service.dart';

// Result wrapper for repository operations
class WalletResult<T> {
  final T? data;
  final String? error;
  final bool success;

  const WalletResult._({this.data, this.error, required this.success});

  factory WalletResult.success(T data) {
    return WalletResult._(data: data, success: true);
  }

  factory WalletResult.failure(String error) {
    return WalletResult._(error: error, success: false);
  }
}

// Wallet repository handling data operations
class WalletRepository {
  final WalletService _service;

  WalletRepository(this._service);

  // ============================================================================
  // DATA FETCHING
  // ============================================================================

  Future<WalletResult<Wallet>> getDriverWallet() async {
    try {
      logDebug('[WalletRepository]', '🔄 Fetching driver wallet...');

      final response = await _service.getDriverWalletData();

      if (response['success'] == true && response['wallet'] != null) {
        final wallet = Wallet.fromJson(response['wallet']);

        logSuccess(
          '[WalletRepository]',
          '✅ Wallet loaded: ${wallet.balance} DH, ${wallet.transactions.length} transactions',
        );

        return WalletResult.success(wallet);
      } else {
        final errorMsg = response['message'] ?? 'Erreur lors du chargement';
        logError('[WalletRepository]', '❌ Failed: $errorMsg');
        return WalletResult.failure(errorMsg);
      }
    } catch (e, stackTrace) {
      logError('[WalletRepository]', '❌ Exception: $e');
      logError('[WalletRepository]', 'Stack: $stackTrace');
      return WalletResult.failure('Erreur lors du chargement du portefeuille');
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  WalletStatistics calculateStatistics(Wallet wallet) {
    return WalletStatistics.fromWallet(wallet);
  }

  // ============================================================================
  // TRANSACTION FILTERING
  // ============================================================================

  List<WalletTransaction> filterByType(
    List<WalletTransaction> transactions,
    WalletTransactionType type,
  ) {
    return transactions.where((tx) => tx.type == type).toList();
  }

  List<WalletTransaction> filterByDateRange(
    List<WalletTransaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions.where((tx) {
      return tx.createdAt.isAfter(startDate) && tx.createdAt.isBefore(endDate);
    }).toList();
  }

  List<WalletTransaction> getThisMonthTransactions(
    List<WalletTransaction> transactions,
  ) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return filterByDateRange(transactions, startOfMonth, endOfMonth);
  }

  List<WalletTransaction> getLastMonthTransactions(
    List<WalletTransaction> transactions,
  ) {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
    return filterByDateRange(transactions, startOfLastMonth, endOfLastMonth);
  }

  // ============================================================================
  // WEEKLY DATA
  // ============================================================================

  List<Map<String, dynamic>> getWeeklyEarnings(
    List<WalletTransaction> transactions,
  ) {
    final now = DateTime.now();
    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    // Initialize all days with 0
    final dailyEarnings = <String, double>{};
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayName = weekDays[day.weekday - 1];
      dailyEarnings[dayName] = 0.0;
    }

    // Sum CREDIT transactions per day for the last 7 days
    final weekAgo = now.subtract(const Duration(days: 7));
    for (final tx in transactions) {
      if (tx.type == WalletTransactionType.credit &&
          tx.createdAt.isAfter(weekAgo)) {
        final dayName = weekDays[tx.createdAt.weekday - 1];
        dailyEarnings[dayName] = (dailyEarnings[dayName] ?? 0.0) + tx.amount;
      }
    }

    return dailyEarnings.entries
        .map((entry) => {'day': entry.key, 'amount': entry.value})
        .toList();
  }

  // ============================================================================
  // TRANSACTION GROUPING
  // ============================================================================

  Map<String, List<WalletTransaction>> groupTransactionsByDate(
    List<WalletTransaction> transactions,
  ) {
    // Sort transactions by date (most recent first)
    final sortedTransactions = List<WalletTransaction>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final grouped = <String, List<WalletTransaction>>{};

    for (final tx in sortedTransactions) {
      final dateKey = _formatDateKey(tx.createdAt);
      grouped[dateKey] = [...(grouped[dateKey] ?? []), tx];
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return "Aujourd'hui";
    } else if (txDate == yesterday) {
      return 'Hier';
    } else if (date.year == now.year) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}