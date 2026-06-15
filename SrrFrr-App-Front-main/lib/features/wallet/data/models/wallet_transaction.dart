// Wallet Transaction Model
//
// Represents a single wallet transaction matching backend WalletTransactionDTO
// Path: lib/features/wallet/data/models/wallet_transaction.dart

import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

// Transaction types matching backend TransactionType enum
enum WalletTransactionType {
  credit,
  debit,
  commission,
  subscription,
  init;

  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case WalletTransactionType.credit:
        return l10n.transactionTypeCredit;
      case WalletTransactionType.debit:
        return l10n.transactionTypeDebit;
      case WalletTransactionType.commission:
        return l10n.transactionTypeCommission;
      case WalletTransactionType.subscription:
        return l10n.transactionTypeSubscription;
      case WalletTransactionType.init:
        return l10n.transactionTypeInit;
    }
  }

  static WalletTransactionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CREDIT':
        return WalletTransactionType.credit;
      case 'DEBIT':
        return WalletTransactionType.debit;
      case 'COMMISSION':
        return WalletTransactionType.commission;
      case 'SUBSCRIPTION':
        return WalletTransactionType.subscription;
      case 'INIT':
        return WalletTransactionType.init;
      default:
        return WalletTransactionType.init;
    }
  }

  String toBackendString() => name.toUpperCase();
}

// Wallet transaction model matching backend WalletTransactionDTO
@immutable
class WalletTransaction {
  final String id;
  final WalletTransactionType type;
  final double amount;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      type: WalletTransactionType.fromString(json['transactionType'] as String),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionType': type.toBackendString(),
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isCredit => type == WalletTransactionType.credit;
  bool get isDebit => type == WalletTransactionType.debit;
  bool get isInit => type == WalletTransactionType.init;
  bool get isCommission => type == WalletTransactionType.commission;
  bool get isSubscription => type == WalletTransactionType.subscription;

  bool get isPositive =>
      type == WalletTransactionType.credit ||
      type == WalletTransactionType.init;

  WalletTransaction copyWith({
    String? id,
    WalletTransactionType? type,
    double? amount,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletTransaction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ amount.hashCode ^ createdAt.hashCode;
  }

  @override
  String toString() {
    return 'WalletTransaction(id: $id, type: $type, amount: $amount, createdAt: $createdAt)';
  }
}