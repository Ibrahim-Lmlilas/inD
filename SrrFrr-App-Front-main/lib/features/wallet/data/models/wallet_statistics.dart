// Wallet Statistics Model
//
// Simplified statistics calculation based on actual backend transaction types
// Path: lib/features/wallet/data/models/wallet_statistics.dart

import 'package:flutter/foundation.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet.dart';
import 'package:srrfrr_app_front/features/wallet/data/models/wallet_transaction.dart';

// Wallet statistics computed from transaction history
@immutable
class WalletStatistics {
  final double totalEarnings; // Sum of CREDIT transactions
  final double totalDebits; // Sum of DEBIT, COMMISSION, SUBSCRIPTION
  final double currentBalance; // Current wallet balance
  final double thisMonthEarnings; // This month's CREDIT
  final double thisMonthCommissions; // This month's COMMISSION + SUBSCRIPTION
  final double thisMonthNet; // thisMonthEarnings - thisMonthCommissions
  final int totalTransactions; // Total transaction count
  final int creditTransactions; // Count of CREDIT transactions
  final int debitTransactions; // Count of DEBIT/COMMISSION/SUBSCRIPTION
  final double averagePerTransaction; // Average per CREDIT transaction

  const WalletStatistics({
    required this.totalEarnings,
    required this.totalDebits,
    required this.currentBalance,
    required this.thisMonthEarnings,
    required this.thisMonthCommissions,
    required this.thisMonthNet,
    required this.totalTransactions,
    required this.creditTransactions,
    required this.debitTransactions,
    required this.averagePerTransaction,
  });

  // Factory method to calculate statistics from Wallet
  factory WalletStatistics.fromWallet(Wallet wallet) {
    debugPrint('\n========================================');
    debugPrint('📊 WALLET STATISTICS CALCULATION START');
    debugPrint('========================================');
    debugPrint('Current Balance: ${wallet.balance} DH');
    debugPrint('Total Transactions: ${wallet.transactions.length}');

    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    debugPrint('Current Month Start: $currentMonthStart');

    double totalCredits = 0.0;
    double totalDebits = 0.0;
    double thisMonthCredits = 0.0;
    double thisMonthDebits = 0.0;
    int creditCount = 0;
    int debitCount = 0;

    debugPrint('\n--- Processing Transactions ---');
    for (final tx in wallet.transactions) {
      final isCurrentMonth =
          tx.createdAt.isAfter(currentMonthStart) ||
          tx.createdAt.isAtSameMomentAs(currentMonthStart);

      debugPrint('\nTransaction: ${tx.id}');
      debugPrint('  Type: ${tx.type.name.toUpperCase()}');
      debugPrint('  Amount: ${tx.amount} DH');
      debugPrint('  Date: ${tx.createdAt}');
      debugPrint('  Current Month: $isCurrentMonth');

      // CREDIT transactions add money
      if (tx.type == WalletTransactionType.credit) {
        totalCredits += tx.amount;
        creditCount++;
        if (isCurrentMonth) {
          thisMonthCredits += tx.amount;
          debugPrint('  ✅ Added to thisMonthCredits: $thisMonthCredits DH');
        }
        debugPrint('  ✅ CREDIT - Total Credits: $totalCredits DH');
      }
      // DEBIT, COMMISSION, SUBSCRIPTION remove money
      else if (tx.type == WalletTransactionType.debit ||
          tx.type == WalletTransactionType.commission ||
          tx.type == WalletTransactionType.subscription) {
        totalDebits += tx.amount;
        debitCount++;
        if (isCurrentMonth) {
          thisMonthDebits += tx.amount;
          debugPrint('  ❌ Added to thisMonthDebits: $thisMonthDebits DH');
        }
        debugPrint('  ❌ DEBIT/COMMISSION/SUB - Total Debits: $totalDebits DH');
      }
      // INIT doesn't count towards earnings or debits (initial balance)
      else if (tx.type == WalletTransactionType.init) {
        debugPrint('  ℹ️ INIT - Ignored (initial balance)');
      }
    }

    final avgPerCredit = creditCount > 0 ? totalCredits / creditCount : 0.0;
    final thisMonthNet = thisMonthCredits - thisMonthDebits;

    debugPrint('\n========================================');
    debugPrint('📈 FINAL STATISTICS');
    debugPrint('========================================');
    debugPrint('Total Earnings (Credits): $totalCredits DH');
    debugPrint('Total Debits: $totalDebits DH');
    debugPrint('Current Balance: ${wallet.balance} DH');
    debugPrint('This Month Earnings: $thisMonthCredits DH');
    debugPrint('This Month Commissions: $thisMonthDebits DH');
    debugPrint('This Month Net: $thisMonthNet DH');
    debugPrint('Total Transactions: ${wallet.transactions.length}');
    debugPrint('Credit Transactions: $creditCount');
    debugPrint('Debit Transactions: $debitCount');
    debugPrint('Average per Credit: $avgPerCredit DH');
    debugPrint('========================================\n');

    return WalletStatistics(
      totalEarnings: totalCredits,
      totalDebits: totalDebits,
      currentBalance: wallet.balance,
      thisMonthEarnings: thisMonthCredits,
      thisMonthCommissions: thisMonthDebits,
      thisMonthNet: thisMonthNet,
      totalTransactions: wallet.transactions.length,
      creditTransactions: creditCount,
      debitTransactions: debitCount,
      averagePerTransaction: avgPerCredit,
    );
  }

  factory WalletStatistics.empty() {
    return const WalletStatistics(
      totalEarnings: 0.0,
      totalDebits: 0.0,
      currentBalance: 0.0,
      thisMonthEarnings: 0.0,
      thisMonthCommissions: 0.0,
      thisMonthNet: 0.0,
      totalTransactions: 0,
      creditTransactions: 0,
      debitTransactions: 0,
      averagePerTransaction: 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalEarnings': totalEarnings,
      'totalDebits': totalDebits,
      'currentBalance': currentBalance,
      'thisMonthEarnings': thisMonthEarnings,
      'thisMonthCommissions': thisMonthCommissions,
      'thisMonthNet': thisMonthNet,
      'totalTransactions': totalTransactions,
      'creditTransactions': creditTransactions,
      'debitTransactions': debitTransactions,
      'averagePerTransaction': averagePerTransaction,
    };
  }

  WalletStatistics copyWith({
    double? totalEarnings,
    double? totalDebits,
    double? currentBalance,
    double? thisMonthEarnings,
    double? thisMonthCommissions,
    double? thisMonthNet,
    int? totalTransactions,
    int? creditTransactions,
    int? debitTransactions,
    double? averagePerTransaction,
  }) {
    return WalletStatistics(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDebits: totalDebits ?? this.totalDebits,
      currentBalance: currentBalance ?? this.currentBalance,
      thisMonthEarnings: thisMonthEarnings ?? this.thisMonthEarnings,
      thisMonthCommissions: thisMonthCommissions ?? this.thisMonthCommissions,
      thisMonthNet: thisMonthNet ?? this.thisMonthNet,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      creditTransactions: creditTransactions ?? this.creditTransactions,
      debitTransactions: debitTransactions ?? this.debitTransactions,
      averagePerTransaction:
          averagePerTransaction ?? this.averagePerTransaction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletStatistics &&
        other.totalEarnings == totalEarnings &&
        other.totalDebits == totalDebits &&
        other.currentBalance == currentBalance &&
        other.thisMonthEarnings == thisMonthEarnings &&
        other.thisMonthCommissions == thisMonthCommissions &&
        other.thisMonthNet == thisMonthNet &&
        other.totalTransactions == totalTransactions &&
        other.creditTransactions == creditTransactions &&
        other.debitTransactions == debitTransactions &&
        other.averagePerTransaction == averagePerTransaction;
  }

  @override
  int get hashCode {
    return totalEarnings.hashCode ^
        totalDebits.hashCode ^
        currentBalance.hashCode ^
        thisMonthEarnings.hashCode ^
        thisMonthCommissions.hashCode ^
        thisMonthNet.hashCode ^
        totalTransactions.hashCode ^
        creditTransactions.hashCode ^
        debitTransactions.hashCode ^
        averagePerTransaction.hashCode;
  }

  @override
  String toString() {
    return 'WalletStatistics('
        'balance: $currentBalance, '
        'earnings: $totalEarnings, '
        'debits: $totalDebits, '
        'thisMonth: $thisMonthEarnings, '
        'commissions: $thisMonthCommissions'
        ')';
  }
}