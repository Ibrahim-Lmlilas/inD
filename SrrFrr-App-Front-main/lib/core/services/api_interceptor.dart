// API Interceptor - Backend Integrated
//
// Handles:
// - Automatic authentication header injection
// - Token refresh on 401 errors
// - Request/response logging in debug mode
// - Error handling and retry logic

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiInterceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Configuration
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
  final Duration timeout;

  ApiInterceptor({this.timeout = const Duration(seconds: 30)});

  // Get headers with authentication token
  Future<Map<String, String>> getHeaders({
    bool includeAuth = true,
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // Make an HTTP request with automatic retry and token refresh
  Future<http.Response> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    int maxRetries = 1,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final requestHeaders = await getHeaders(
        includeAuth: requiresAuth,
        additionalHeaders: headers,
      );

      if (kDebugMode) {
        _logRequest(method, endpoint, body);
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: requestHeaders)
              .timeout(timeout);
          break;
        case 'PATCH':
          response = await http
              .patch(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      if (kDebugMode) {
        _logResponse(response);
      }

      // Handle 401 Unauthorized - attempt token refresh
      if (response.statusCode == 401 && requiresAuth && maxRetries > 0) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return await request(
            method: method,
            endpoint: endpoint,
            body: body,
            headers: headers,
            requiresAuth: requiresAuth,
            maxRetries: maxRetries - 1,
          );
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        _logError(method, endpoint, e);
      }
      rethrow;
    }
  }

  // Convenient GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return await request(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Convenient POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return await request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Convenient PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return await request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Convenient DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return await request(
      method: 'DELETE',
      endpoint: endpoint,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  // Make a multipart request with file uploads
  // Supports automatic authentication and token refresh
  Future<http.Response> multipartRequest({
    required String method,
    required String endpoint,
    required Map<String, String> fields,
    required Map<String, String> files, // filepath -> field name
    bool requiresAuth = true,
    int maxRetries = 1,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      // Add headers with authentication
      final requestHeaders = await getHeaders(
        includeAuth: requiresAuth,
        additionalHeaders: {},
      );

      // Remove Content-Type - multipart will set it with boundary
      requestHeaders.remove('Content-Type');
      request.headers.addAll(requestHeaders);

      // Add form fields
      request.fields.addAll(fields);

      // Add files
      for (final entry in files.entries) {
        final filePath = entry.key;
        final fieldName = entry.value;

        final file = File(filePath);
        if (await file.exists()) {
          final fileStream = http.ByteStream(file.openRead());
          final fileLength = await file.length();

          final multipartFile = http.MultipartFile(
            fieldName,
            fileStream,
            fileLength,
            filename: path.basename(filePath),
          );

          request.files.add(multipartFile);
        } else {
          debugPrint('⚠️  File not found: $filePath');
        }
      }

      if (kDebugMode) {
        debugPrint('');
        debugPrint('→ $method /$endpoint (multipart)');
        debugPrint('  Fields: ${request.fields}');
        debugPrint('  Files: ${request.files.map((f) => f.field).join(', ')}');
      }

      // Send request
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        _logResponse(response);
      }

      // Handle 401 Unauthorized - attempt token refresh
      if (response.statusCode == 401 && requiresAuth && maxRetries > 0) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return await multipartRequest(
            method: method,
            endpoint: endpoint,
            fields: fields,
            files: files,
            requiresAuth: requiresAuth,
            maxRetries: maxRetries - 1,
          );
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        _logError(method, endpoint, e);
      }
      rethrow;
    }
  }

  // MARK: - Token Management

  // Get access token from secure storage
  Future<String?> _getAuthToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      debugPrint('Error reading access token: $e');
      return null;
    }
  }

  // Refresh expired access token using backend endpoint
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);

      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return false;
      }

      // Make refresh request without authentication (backend endpoint: POST /auth/refresh)
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _storage.write(key: _accessTokenKey, value: newAccessToken);
        }

        if (newRefreshToken != null) {
          await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
        }

        if (kDebugMode) {
          debugPrint('✓ Token refreshed successfully');
        }

        return true;
      } else {
        if (kDebugMode) {
          debugPrint('✗ Token refresh failed: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  // Save tokens to secure storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);

      if (kDebugMode) {
        debugPrint('✓ Tokens saved successfully');
      }
    } catch (e) {
      debugPrint('Error saving tokens: $e');
    }
  }

  // Clear all stored tokens
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);

      if (kDebugMode) {
        debugPrint('✓ Tokens cleared successfully');
      }
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }
  }

  // MARK: - Logging

  // Log HTTP request in debug mode
  void _logRequest(String method, String endpoint, Map<String, dynamic>? body) {
    debugPrint('');
    debugPrint('→ $method /$endpoint');
    if (body != null) {
      debugPrint('  Body: ${jsonEncode(body)}');
    }
  }

  // Log HTTP response in debug mode
  void _logResponse(http.Response response) {
    final statusEmoji = response.statusCode >= 200 && response.statusCode < 300
        ? '✓'
        : '✗';

    debugPrint('← $statusEmoji ${response.statusCode}');

    // Only log response body if it's not too large
    if (response.body.length < 1000) {
      try {
        final prettyJson = JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(response.body));
        debugPrint('  Response: $prettyJson');
      } catch (e) {
        debugPrint('  Response: ${response.body}');
      }
    } else {
      debugPrint('  Response: [${response.body.length} bytes]');
    }
    debugPrint('');
  }

  // Log HTTP errors in debug mode
  void _logError(String method, String endpoint, Object error) {
    debugPrint('');
    debugPrint('✗ Error: $method /$endpoint');
    debugPrint('  ${error.toString()}');
    debugPrint('');
  }
}
