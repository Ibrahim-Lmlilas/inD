// Wallet Model
//
// Represents wallet data matching backend WalletDTO
// Path: lib/features/wallet/data/models/wallet.dart

import 'package:flutter/foundation.dart';
import 'wallet_transaction.dart';

// Wallet data model matching backend WalletDTO
@immutable
class Wallet {
  final double balance;
  final List<WalletTransaction> transactions;

  const Wallet({required this.balance, required this.transactions});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final transactionsList = json['transactions'] as List<dynamic>? ?? [];

    return Wallet(
      balance: (json['wallet'] as num).toDouble(),
      transactions: transactionsList
          .map((tx) => WalletTransaction.fromJson(tx as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet': balance,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
    };
  }

  Wallet copyWith({double? balance, List<WalletTransaction>? transactions}) {
    return Wallet(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }

  // Convenience getters
  bool get hasTransactions => transactions.isNotEmpty;

  int get transactionCount => transactions.length;

  List<WalletTransaction> get recentTransactions =>
      transactions.take(10).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Wallet &&
        other.balance == balance &&
        listEquals(other.transactions, transactions);
  }

  @override
  int get hashCode => balance.hashCode ^ transactions.hashCode;

  @override
  String toString() {
    return 'Wallet(balance: $balance, transactions: ${transactions.length})';
  }
}
