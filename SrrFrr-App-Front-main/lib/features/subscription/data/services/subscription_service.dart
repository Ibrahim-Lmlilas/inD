// Subscription Service
//
// Handles driver subscription operations with proper data extraction.
// Backend wraps responses in { success, message, data, timestamp } format.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class SubscriptionService {
  final ApiInterceptor _interceptor;

  SubscriptionService(this._interceptor);

  // ===========================================================================
  // MARK: - Subscription Plans
  // ===========================================================================

  // Get all available subscription plans
  // Backend: GET /subscriptions/plans
  // Response: { success, message, data: [...plans], timestamp }
  Future<http.Response> getSubscriptionPlans() async {
    try {
      final response = await _interceptor.get(
        'subscriptions/plans',
        requiresAuth: true,
      );

      // Extract data array from wrapper
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final plans = body['data']; // This is the array

        // Return a new response with just the plans array
        return http.Response(
          jsonEncode(plans),
          response.statusCode,
          headers: response.headers,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      logError(
        '[SubscriptionService]',
        'Failed to get subscription plans - $e',
      );
      rethrow;
    }
  }

  // ===========================================================================
  // MARK: - Subscribe
  // ===========================================================================

  // Subscribe driver to a plan
  // Backend: POST /subscriptions/subscribe
  // Request body: { "planType": "PRO" | "PREMIUM" | "BASIC" }
  Future<http.Response> subscribeDriver({required String planType}) async {
    try {
      final response = await _interceptor.post(
        'subscriptions/subscribe',
        body: {'planType': planType},
        requiresAuth: true,
      );

      // Extract data from wrapper if successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        return http.Response(
          jsonEncode(data),
          response.statusCode,
          headers: response.headers,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      logError('[SubscriptionService]', 'Failed to subscribe - $e');
      rethrow;
    }
  }

  // ===========================================================================
  // MARK: - Active Subscription
  // ===========================================================================

  // Get active subscription for current driver
  // Backend: GET /subscriptions/active
  // Response: { success, message, data: {...subscription}, timestamp }
  Future<http.Response> getActiveSubscription() async {
    try {
      final response = await _interceptor.get(
        'subscriptions/active',
        requiresAuth: true,
      );

      // Extract data object from wrapper
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data']; // This is the subscription object

        return http.Response(
          jsonEncode(data),
          response.statusCode,
          headers: response.headers,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      logError(
        '[SubscriptionService]',
        'Failed to get active subscription - $e',
      );
      rethrow;
    }
  }

  // ===========================================================================
  // MARK: - Subscription History
  // ===========================================================================

  // Get subscription history for current driver
  // Backend: GET /subscriptions/history?page=0&size=20
  // Response: { success, message, data: Page<Subscription>, timestamp }
  Future<http.Response> getSubscriptionHistory({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _interceptor.get(
        'subscriptions/history?page=$page&size=$size',
        requiresAuth: true,
      );

      // Extract data (Page object) from wrapper
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data']; // This is the Page object or array

        return http.Response(
          jsonEncode(data),
          response.statusCode,
          headers: response.headers,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      logError(
        '[SubscriptionService]',
        'Failed to get subscription history - $e',
      );
      rethrow;
    }
  }

  // ===========================================================================
  // MARK: - Change Subscription
  // ===========================================================================

  // Change driver subscription to a different plan
  // Backend: PUT /subscriptions/change
  // Request body: { "planType": "PRO" | "PREMIUM" | "BASIC" }
  Future<http.Response> changeSubscription({required String planType}) async {
    try {
      final response = await _interceptor.request(
        method: 'PUT',
        endpoint: 'subscriptions/change',
        body: {'planType': planType},
        requiresAuth: true,
      );

      // Extract data from wrapper if successful
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        return http.Response(
          jsonEncode(data),
          response.statusCode,
          headers: response.headers,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      logError('[SubscriptionService]', 'Failed to change subscription - $e');
      rethrow;
    }
  }

  // ===========================================================================
  // MARK: - Stop Subscription
  // ===========================================================================

  // Stop/cancel current subscription plan
  // Backend: PUT /subscriptions/stop
  Future<http.Response> stopSubscriptionPlan() async {
    try {
      final response = await _interceptor.request(
        method: 'PUT',
        endpoint: 'subscriptions/stop',
        requiresAuth: true,
      );

      // Extract data from wrapper if successful
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        return http.Response(
          jsonEncode(data),
          response.statusCode,
          headers: response.headers,
          request: response.request,
        );
      }

      return response;
    } catch (e) {
      logError('[SubscriptionService]', 'Failed to cancel plan - $e');
      rethrow;
    }
  }
}
