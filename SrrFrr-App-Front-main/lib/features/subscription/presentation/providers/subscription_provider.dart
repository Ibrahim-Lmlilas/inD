// Subscription Provider
//
// Manages driver subscription state and operations with backend integration.
// Handles subscription plans, active subscriptions, and paginated history.
//
// KEY CHANGES:
// 1. Clear promo flags after first subscription
// 2. Promo banner disappears when user subscribes
// 3. Active subscription card appears immediately

library;

import 'dart:convert';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/subscription/data/services/subscription_service.dart';
import 'package:srrfrr_app_front/shared/providers/disposable_provider.dart';

class SubscriptionProvider extends DisposableProvider {
  final SubscriptionService _apiService = SubscriptionService(ApiInterceptor());

  // State
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Plans
  List<SubscriptionPlan> _availablePlans = [];
  bool _isFirstTimeEligible = false;
  int? _promoDurationDays;
  String? _promoMessage;

  // Active subscription
  SubscriptionData? _activeSubscription;

  // History with pagination
  List<SubscriptionData> _subscriptionHistory = [];
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  SubscriptionData? get activeSubscription => _activeSubscription;
  List<SubscriptionData> get subscriptionHistory => _subscriptionHistory;
  bool get isFirstTimeEligible => _isFirstTimeEligible;
  int? get promoDurationDays => _promoDurationDays;
  String? get promoMessage => _promoMessage;
  bool get hasPromotion => _isFirstTimeEligible && _promoMessage != null;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;

  bool get hasActiveSubscription => _activeSubscription != null;
  bool get isSubscriptionActive => _activeSubscription?.status == 'ACTIVE';

  String? get currentPlanType => _activeSubscription?.planType;
  int get ridesUsed => _activeSubscription?.ridesUsed ?? 0;
  int get maxRides => _activeSubscription?.maxRides ?? 0;
  DateTime? get renewalDate => _activeSubscription?.endDate;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  // Initialize subscription data
  Future<void> initialize() async {
    try {
      logInfo('[SubscriptionProvider]', '🚀 Initializing...');

      await Future.wait([fetchAvailablePlans(), fetchActiveSubscription()]);

      logSuccess('[SubscriptionProvider]', '✅ Initialized successfully');
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Initialization error: $e');
      _setError('Erreur lors de l\'initialisation');
    }
  }

  // ============================================================================
  // FETCH OPERATIONS
  // ============================================================================

  // Fetch available subscription plans
  Future<bool> fetchAvailablePlans() async {
    try {
      logDebug('[SubscriptionProvider]', '📋 Fetching available plans...');

      _setLoading(true);

      final response = await _apiService.getSubscriptionPlans();

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle new response format with promo info
        if (responseBody is Map<String, dynamic>) {
          // Extract plans
          final List<dynamic> plansJson =
              responseBody['plans'] as List<dynamic>;

          _availablePlans = plansJson
              .map(
                (json) =>
                    SubscriptionPlan.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // Extract promo info
          _isFirstTimeEligible =
              responseBody['firstTimePromoEligible'] as bool? ?? false;
          _promoDurationDays = responseBody['promoDurationDays'] as int?;

          // Extract French promo message
          if (responseBody['promoMessage'] != null) {
            final promoMessages =
                responseBody['promoMessage'] as Map<String, dynamic>;
            _promoMessage = promoMessages['fr'] as String?; // Default to French
          } else {
            _promoMessage = null;
          }

          // Sort plans: BASIC, PREMIUM, PRO
          _availablePlans.sort((a, b) {
            const order = {'BASIC': 0, 'PREMIUM': 1, 'PRO': 2};
            return (order[a.type] ?? 999).compareTo(order[b.type] ?? 999);
          });

          logSuccess(
            '[SubscriptionProvider]',
            '✅ Loaded ${_availablePlans.length} plans${_isFirstTimeEligible ? " (Promo eligible: $_promoDurationDays days)" : ""}',
          );

          _setLoading(false);
          return true;
        } else {
          // Fallback for old format (just array)
          final List<dynamic> plansJson = responseBody as List<dynamic>;

          _availablePlans = plansJson
              .map(
                (json) =>
                    SubscriptionPlan.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          _isFirstTimeEligible = false;
          _promoDurationDays = null;
          _promoMessage = null;

          _setLoading(false);
          return true;
        }
      } else {
        _setError('Erreur lors du chargement des plans');
        return false;
      }
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Error fetching plans: $e');
      _setError('Erreur lors du chargement des plans');
      return false;
    }
  }

  // Fetch active subscription for current driver
  Future<bool> fetchActiveSubscription() async {
    try {
      logDebug('[SubscriptionProvider]', '🔍 Fetching active subscription...');

      final response = await _apiService.getActiveSubscription();

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final data = responseBody as Map<String, dynamic>;

        // Check if subscription exists
        if (data['subscriptionId'] != null) {
          _activeSubscription = SubscriptionData.fromJson(data);

          logSuccess(
            '[SubscriptionProvider]',
            '✅ Active subscription: ${_activeSubscription!.planType}',
          );
        } else {
          _activeSubscription = null;
          logDebug('[SubscriptionProvider]', 'ℹ️ No active subscription');
        }
        safeNotify();
        return true;
      } else {
        _activeSubscription = null;
        safeNotify();
        return false;
      }
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Error fetching subscription: $e');
      _activeSubscription = null;
      safeNotify();
      return false;
    }
  }

  // Fetch subscription history with pagination (initial load)
  Future<bool> fetchSubscriptionHistory({bool isInitial = true}) async {
    if (_isLoading || (_isLoadingMore && !isInitial)) return false;

    try {
      logDebug(
        '[SubscriptionProvider]',
        '📜 Fetching subscription history (page: ${isInitial ? 0 : _currentPage})...',
      );

      if (isInitial) {
        _setLoading(true);
        _currentPage = 0;
        _subscriptionHistory.clear();
      } else {
        _setLoadingMore(true);
      }

      final response = await _apiService.getSubscriptionHistory(
        page: _currentPage,
        size: _pageSize,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and paginated responses
        List<dynamic> historyJson;
        if (responseBody is List) {
          // Non-paginated response
          historyJson = responseBody;
          _totalPages = 1;
          _totalElements = historyJson.length;
          _hasMore = false;
        } else if (responseBody is Map<String, dynamic>) {
          // Paginated response
          historyJson = responseBody['content'] as List<dynamic>;
          _totalPages = responseBody['totalPages'] as int;
          _totalElements = responseBody['totalElements'] as int;
          _hasMore = !responseBody['last'];
        } else {
          throw Exception('Unexpected response format');
        }

        final newHistory = historyJson
            .map(
              (json) => SubscriptionData.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        if (isInitial) {
          _subscriptionHistory = newHistory;
        } else {
          _subscriptionHistory.addAll(newHistory);
        }

        logSuccess(
          '[SubscriptionProvider]',
          '✅ Loaded ${newHistory.length} history items (page $_currentPage/$_totalPages)',
        );

        if (isInitial) {
          _setLoading(false);
        } else {
          _setLoadingMore(false);
        }
        return true;
      } else {
        _setError('Erreur lors du chargement de l\'historique');
        return false;
      }
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Error fetching history: $e');
      _setError('Erreur lors du chargement de l\'historique');
      return false;
    }
  }

  // Load more subscription history
  Future<void> loadMoreHistory() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _currentPage++;
    await fetchSubscriptionHistory(isInitial: false);
  }

  // ============================================================================
  // SUBSCRIPTION OPERATIONS
  // ============================================================================

  // Subscribe to a plan
  // 🔑 KEY CHANGE: Clear promo flags after first subscription
  Future<bool> subscribeToPlan(String planType) async {
    try {
      logInfo('[SubscriptionProvider]', '💳 Subscribing to plan: $planType');

      _setLoading(true);
      _clearError();

      final response = await _apiService.subscribeDriver(planType: planType);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update active subscription
        await fetchActiveSubscription();

        // 🔑 CRITICAL: Clear promo eligibility after first subscription
        // This makes the promo banner disappear and shows the subscription card
        _isFirstTimeEligible = false;
        _promoDurationDays = null;
        _promoMessage = null;

        logSuccess(
          '[SubscriptionProvider]',
          '✅ Subscription activated: $planType (promo cleared)',
        );

        _setLoading(false);
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        final errorData = responseBody as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ?? 'Erreur lors de l\'activation';

        _setError(errorMessage);
        return false;
      }
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Error subscribing: $e');
      _setError('Erreur lors de l\'activation de l\'abonnement');
      return false;
    }
  }

  // Cancel active subscription
  // Backend: PUT /subscriptions/driver/stop
  Future<bool> cancelSubscription() async {
    try {
      logInfo('[SubscriptionProvider]', '🚫 Canceling subscription...');

      _setLoading(true);
      _clearError();

      final response = await _apiService.stopSubscriptionPlan();

      if (response.statusCode == 200) {
        // Update active subscription after cancellation
        await fetchActiveSubscription();

        logSuccess(
          '[SubscriptionProvider]',
          '✅ Subscription cancelled successfully',
        );

        _setLoading(false);
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        final errorData = responseBody as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ?? 'Erreur lors de l\'annulation';

        _setError(errorMessage);
        return false;
      }
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Error canceling: $e');
      _setError('Erreur lors de l\'annulation');
      return false;
    }
  }

  // Change subscription to a different plan
  Future<bool> changeSubscription(String newPlanType) async {
    try {
      logInfo(
        '[SubscriptionProvider]',
        '🔄 Changing subscription to: $newPlanType',
      );

      _setLoading(true);
      _clearError();

      final response = await _apiService.changeSubscription(
        planType: newPlanType,
      );

      if (response.statusCode == 200) {
        // Update active subscription after successful change
        await fetchActiveSubscription();

        logSuccess(
          '[SubscriptionProvider]',
          '✅ Subscription changed to: $newPlanType',
        );

        _setLoading(false);
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        final errorData = responseBody as Map<String, dynamic>?;
        final errorMessage =
            errorData?['message'] as String? ??
            'Erreur lors du changement d\'abonnement';

        _setError(errorMessage);
        return false;
      }
    } catch (e) {
      logError('[SubscriptionProvider]', '❌ Error changing subscription: $e');
      _setError('Erreur lors du changement d\'abonnement');
      return false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  // Get plan details by type
  SubscriptionPlan? getPlanByType(String type) {
    try {
      return _availablePlans.firstWhere((plan) => plan.type == type);
    } catch (e) {
      return null;
    }
  }

  // Check if user can subscribe to a plan
  bool canSubscribeTo(String planType) {
    // If no active subscription, can subscribe to any plan
    if (!hasActiveSubscription) {
      return getPlanByType(planType) != null;
    }

    // If has active subscription, can change to different plan
    if (_activeSubscription!.planType != planType) {
      return getPlanByType(planType) != null;
    }

    // Can't subscribe to same plan
    return false;
  }

  // Check if user can change to a different plan
  bool canChangeTo(String planType) {
    // Must have active subscription to change
    if (!hasActiveSubscription) return false;

    // Can't change to same plan
    if (_activeSubscription!.planType == planType) return false;

    // Check if target plan exists
    return getPlanByType(planType) != null;
  }

  // Get remaining rides for active subscription
  int getRemainingRides() {
    if (_activeSubscription == null) return 0;

    if (_activeSubscription!.maxRides == 0) {
      return -1; // Unlimited
    }

    final remaining =
        _activeSubscription!.maxRides - _activeSubscription!.ridesUsed;
    return remaining < 0 ? 0 : remaining;
  }

  // Get days until renewal
  int? getDaysUntilRenewal() {
    if (_activeSubscription?.endDate == null) return null;

    final now = DateTime.now();
    final endDate = _activeSubscription!.endDate!;

    return endDate.difference(now).inDays;
  }

  // Check if subscription is expiring soon (within 7 days)
  bool isExpiringSoon() {
    final days = getDaysUntilRenewal();
    return days != null && days <= 7 && days > 0;
  }

  // Check if subscription has expired
  bool isExpired() {
    final days = getDaysUntilRenewal();
    return days != null && days <= 0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    safeNotify();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    safeNotify();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    _isLoadingMore = false;
    safeNotify();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      safeNotify();
    }
  }

  // Clear all data
  void clear() {
    _availablePlans = [];
    _activeSubscription = null;
    _subscriptionHistory = [];
    _currentPage = 0;
    _totalPages = 0;
    _totalElements = 0;
    _hasMore = true;
    _errorMessage = null;
    _isLoading = false;
    _isLoadingMore = false;
    _isFirstTimeEligible = false;
    _promoDurationDays = null;
    _promoMessage = null;
    safeNotify();
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

// Subscription Plan Model
class SubscriptionPlan {
  final String id;
  final String type; // BASIC, PREMIUM, PRO
  final double price;
  final List<String> descriptions;

  SubscriptionPlan({
    required this.id,
    required this.type,
    required this.price,
    required this.descriptions,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      descriptions: (json['descriptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'price': price,
      'descriptions': descriptions,
    };
  }
}

// Subscription Data Model
class SubscriptionData {
  final String subscriptionId;
  final String driverId;
  final String planType;
  final double price;
  final List<String> descriptions;
  final DateTime? startDate;
  final DateTime? endDate;
  final int ridesUsed;
  final int maxRides; // 0 = unlimited
  final String status; // ACTIVE, EXPIRED, CANCELLED
  final String? message;

  SubscriptionData({
    required this.subscriptionId,
    required this.driverId,
    required this.planType,
    required this.price,
    required this.descriptions,
    this.startDate,
    this.endDate,
    required this.ridesUsed,
    required this.maxRides,
    required this.status,
    this.message,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      subscriptionId: json['subscriptionId'] as String,
      driverId: json['driverId'] as String,
      planType: json['planType'] as String,
      price: (json['price'] as num).toDouble(),
      descriptions: (json['descriptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      ridesUsed: json['ridesUsed'] as int,
      maxRides: json['maxRides'] as int,
      status: json['status'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'driverId': driverId,
      'planType': planType,
      'price': price,
      'descriptions': descriptions,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'ridesUsed': ridesUsed,
      'maxRides': maxRides,
      'status': status,
      'message': message,
    };
  }
}
