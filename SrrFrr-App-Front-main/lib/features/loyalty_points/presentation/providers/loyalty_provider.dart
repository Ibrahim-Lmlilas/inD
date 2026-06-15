// Loyalty Provider - Simplified & Clean
//
// Responsibilities:
// - Transaction history with pagination
// - Loyalty rewards catalog
// - Level calculations (using points from UserProvider)
// - Referral sharing
//
// Note: Points come from UserProvider, not stored here

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/loyalty_points/data/model/loyalty_reward.dart';
import 'package:srrfrr_app_front/features/loyalty_points/data/services/loyalty_service.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';
import 'package:share_plus/share_plus.dart';

class LoyaltyProvider extends DisposableProvider {
  final LoyaltyService loyaltyService;

  LoyaltyProvider({required this.loyaltyService});

  // State
  List<LoyaltyTransaction> _transactions = [];
  List<LoyaltyReward> _rewards = [];
  String? _referralLink;
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination state
  int _currentPage = 0;
  int _totalElements = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Getters
  List<LoyaltyTransaction> get transactions => List.unmodifiable(_transactions);
  List<LoyaltyReward> get rewards => List.unmodifiable(_rewards);
  String? get referralLink => _referralLink;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get totalElements => _totalElements;
  bool get hasMore => _hasMore;

  // ============================================================================
  // LEVEL CALCULATIONS (require points parameter from UserProvider)
  // ============================================================================

  String currentLevel(int points) {
    if (points >= 20000) return 'Platinum';
    if (points >= 10000) return 'Gold';
    if (points >= 5000) return 'Silver';
    return 'Bronze';
  }

  int nextLevelPoints(int points) {
    if (points < 5000) return 5000;
    if (points < 10000) return 10000;
    if (points < 20000) return 20000;
    return 30000;
  }

  String nextLevel(int points) {
    if (points < 5000) return 'Silver';
    if (points < 10000) return 'Gold';
    if (points < 20000) return 'Platinum';
    return 'Legend';
  }

  int getPointsToNextLevel(int points) {
    return nextLevelPoints(points) - points;
  }

  double getLevelProgress(int points) {
    int currentLevelMin = 0;

    if (points >= 20000) return 1.0;
    if (points >= 10000) {
      currentLevelMin = 10000;
    } else if (points >= 5000) {
      currentLevelMin = 5000;
    }

    final nextPoints = nextLevelPoints(points);
    final progress =
        (points - currentLevelMin) / (nextPoints - currentLevelMin);
    return progress.clamp(0.0, 1.0);
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      await Future.wait([loadLoyaltyPoints(), loadRewards()]);

      _setLoading(false);
      logSuccess('LoyaltyProvider', '✅ Loyalty data loaded');
    } catch (e) {
      _setError('Erreur lors du chargement');
      logError('LoyaltyProvider', 'Initialization error: $e');
      _setLoading(false);
    }
  }

  // ============================================================================
  // TRANSACTIONS (with pagination)
  // ============================================================================

  Future<void> loadLoyaltyPoints({int page = 0, int size = 20}) async {
    try {
      final response = await loyaltyService.getLoyaltyPoints(
        page: page,
        size: size,
      );

      if (response['success'] == true) {
        _totalElements = response['totalElements'] ?? 0;
        _currentPage = response['currentPage'] ?? 0;
        _hasMore = response['hasNext'] ?? false;

        if (response['transactions'] != null) {
          _transactions = (response['transactions'] as List)
              .map((json) => LoyaltyTransaction.fromJson(json))
              .toList();
        }

        _safeNotify();
        logSuccess(
          'LoyaltyProvider',
          '✅ Loaded ${_transactions.length} transactions',
        );
      }
    } catch (e) {
      logError('LoyaltyProvider', 'Error loading transactions: $e');
      rethrow;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    try {
      _isLoadingMore = true;
      _safeNotify();

      final nextPage = _currentPage + 1;
      final response = await loyaltyService.getLoyaltyPoints(
        page: nextPage,
        size: 20,
      );

      if (response['success'] == true) {
        _currentPage = response['currentPage'] ?? 0;
        _hasMore = response['hasNext'] ?? false;

        if (response['transactions'] != null) {
          final newTransactions = (response['transactions'] as List)
              .map((json) => LoyaltyTransaction.fromJson(json))
              .toList();

          _transactions.addAll(newTransactions);
        }

        _isLoadingMore = false;
        _safeNotify();
        logSuccess('LoyaltyProvider', '✅ Loaded page $nextPage');
      }
    } catch (e) {
      logError('LoyaltyProvider', 'Error loading more: $e');
      _isLoadingMore = false;
      _safeNotify();
    }
  }

  // ============================================================================
  // REWARDS
  // ============================================================================

  Future<void> loadRewards() async {
    try {
      logInfo('LoyaltyProvider', 'Loading rewards...');
      final response = await loyaltyService.getLoyaltyRewards();
      debugPrint('Rewards response: $response');
      _rewards = (response['rewards'] as List<dynamic>)
          .map((json) => LoyaltyReward.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('Loaded ${_rewards.length} rewards');

      _safeNotify();
      logSuccess('LoyaltyProvider', '✅ Loaded ${_rewards.length} rewards');
    } catch (e, stackTrace) {
      logError('LoyaltyProvider', 'Error loading rewards: $e');
      logError('LoyaltyProvider', 'Stack: $stackTrace');
      _rewards = [];
      _safeNotify();
    }
  }

  // ============================================================================
  // REFERRAL
  // ============================================================================

  Future<void> shareReferralLink() async {
    try {
      await Share.share(
        'Rejoignez SrrFrr et gagnez des points ! '
        'Téléchargez l\'application maintenant.\n'
        'Lien: $_referralLink',
        subject: 'Invitation SrrFrr',
      );

      logSuccess('LoyaltyProvider', '✅ Referral link shared');
    } catch (e) {
      logError('LoyaltyProvider', 'Share error: $e');
      _setError('Erreur lors du partage');
    }
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotify();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    _safeNotify();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _safeNotify();
    }
  }

  void _safeNotify() {
    scheduleMicrotask(() {
      if (!isDisposed) {
        safeNotify();
      }
    });
  }

  Future<void> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    await initialize();
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class LoyaltyTransaction {
  final String id;
  final TransactionType type;
  final int points;
  final String description;
  final DateTime createdAt;

  LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] ?? '',
      type: _parseTransactionType(json['type']),
      points: json['points'] ?? 0,
      description: _generateDescription(json),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type?.toUpperCase()) {
      case 'DEBIT':
        return TransactionType.debit;
      case 'PARRAINAGE':
        return TransactionType.parrainage;
      case 'TRAJET':
        return TransactionType.trajet;
      case 'RATING':
        return TransactionType.rating;
      default:
        return TransactionType.trajet;
    }
  }

  static String _generateDescription(Map<String, dynamic> json) {
    final type = _parseTransactionType(json['type']);

    switch (type) {
      case TransactionType.rating:
        return 'Evaluation complétée';
      case TransactionType.trajet:
        return 'Trajet complété';
      case TransactionType.parrainage:
        return 'Parrainage réussi';
      case TransactionType.debit:
        return 'Points utilisés';
    }
  }

  String get formattedPoints {
    return type == TransactionType.debit ? '-$points' : '+$points';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  bool get isEarned => type != TransactionType.debit;
}
