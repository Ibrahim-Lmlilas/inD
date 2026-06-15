// Map Utils - Centralized Google Maps Operations
//
// Single source of truth for ALL map-related operations:
// - Distance calculation (Google Maps Distance Matrix API)
// - ETA calculation (Google Maps Directions API)
// - Route trajectory (Google Maps Directions API with polyline)
// - Marker creation (standardized markers for all use cases)
// - Polyline rendering (consistent styling)
// - Camera positioning (bounds calculation)

library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:srrfrr_app_front/core/constants/app_colors.dart';

// Main MapUtils class - all methods are static
class MapUtils {
  MapUtils._(); // Private constructor - utility class

  // ==========================================================================
  // GOOGLE MAPS API CONFIGURATION
  // ==========================================================================

  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static bool get _hasApiKey => _apiKey.isNotEmpty;

  static const Duration _apiTimeout = Duration(seconds: 15);

  // Simple cache for geocoding results
  static final Map<String, Map<String, dynamic>> _geocodeCache = {};
  static const int _maxCacheSize = 50;

  // ==========================================================================
  // ROUTE CALCULATION (Google Maps Directions API)
  // ==========================================================================

  // Calculate complete route with trajectory, distance, and ETA
  //
  // Uses Google Maps Directions API for accurate results
  // Returns null if API fails - NO FALLBACK CALCULATIONS
  //
  // Response format:
  // ```dart
  // {
  //   'success': true,
  //   'points': [LatLng(lat1, lng1), LatLng(lat2, lng2), ...],
  //   'distance': 15.3, // kilometers
  //   'distanceText': '15.3 km',
  //   'duration': 1800, // seconds
  //   'durationText': '30 min',
  // }
  // ```
  static Future<Map<String, dynamic>?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    String? mode, // driving (default), walking, bicycling, transit
  }) async {
    if (!_hasApiKey) {
      debugPrint('❌ MapUtils: Google Maps API key not configured');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=${mode ?? 'driving'}&'
        'key=$_apiKey',
      );

      debugPrint('🗺️  MapUtils: Calculating route via Google Maps API');

      final response = await http
          .get(url)
          .timeout(
            _apiTimeout,
            onTimeout: () => throw TimeoutException('API timeout'),
          );

      if (response.statusCode != 200) {
        debugPrint('❌ MapUtils: API returned ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK' || data['routes'] == null) {
        debugPrint('❌ MapUtils: API status: ${data['status']}');
        return null;
      }

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        debugPrint('❌ MapUtils: No routes found');
        return null;
      }

      final route = routes[0] as Map<String, dynamic>;
      final leg = (route['legs'] as List<dynamic>)[0] as Map<String, dynamic>;

      // Decode polyline for trajectory
      final polylinePoints = _decodePolyline(
        route['overview_polyline']['points'] as String,
      );

      // Extract distance (meters -> kilometers)
      final distanceMeters = leg['distance']['value'] as int;
      final distanceKm = distanceMeters / 1000.0;
      final distanceText = leg['distance']['text'] as String;

      // Extract duration (seconds)
      final durationSeconds = leg['duration']['value'] as int;
      final durationText = leg['duration']['text'] as String;

      debugPrint(
        '✅ MapUtils: Route calculated - '
        'Distance: $distanceKm km, Duration: $durationText',
      );

      return {
        'success': true,
        'points': polylinePoints,
        'distance': distanceKm,
        'distanceText': distanceText,
        'duration': durationSeconds,
        'durationText': durationText,
      };
    } catch (e) {
      debugPrint('❌ MapUtils: Route calculation failed - $e');
      return null;
    }
  }

  // Calculate distance between two points using Distance Matrix API
  //
  // More accurate than route calculation for simple distance checks
  // Returns null if API fails
  static Future<Map<String, dynamic>?> calculateDistance({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (!_hasApiKey) {
      debugPrint('❌ MapUtils: Google Maps API key not configured');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?'
        'origins=${origin.latitude},${origin.longitude}&'
        'destinations=${destination.latitude},${destination.longitude}&'
        'key=$_apiKey',
      );

      debugPrint('🗺️  MapUtils: Calculating distance via Distance Matrix API');

      final response = await http
          .get(url)
          .timeout(
            _apiTimeout,
            onTimeout: () => throw TimeoutException('API timeout'),
          );

      if (response.statusCode != 200) {
        debugPrint('❌ MapUtils: API returned ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK') {
        debugPrint('❌ MapUtils: API status: ${data['status']}');
        return null;
      }

      final rows = data['rows'] as List<dynamic>;
      if (rows.isEmpty) return null;

      final elements =
          (rows[0] as Map<String, dynamic>)['elements'] as List<dynamic>;
      if (elements.isEmpty) return null;

      final element = elements[0] as Map<String, dynamic>;

      if (element['status'] != 'OK') {
        debugPrint('❌ MapUtils: Element status: ${element['status']}');
        return null;
      }

      final distanceMeters = element['distance']['value'] as int;
      final distanceKm = distanceMeters / 1000.0;
      final distanceText = element['distance']['text'] as String;

      final durationSeconds = element['duration']['value'] as int;
      final durationText = element['duration']['text'] as String;

      debugPrint(
        '✅ MapUtils: Distance calculated - $distanceKm km, $durationText',
      );

      return {
        'success': true,
        'distance': distanceKm,
        'distanceText': distanceText,
        'duration': durationSeconds,
        'durationText': durationText,
      };
    } catch (e) {
      debugPrint('❌ MapUtils: Distance calculation failed - $e');
      return null;
    }
  }

  // ==========================================================================
  // GEOCODING (Address <-> Coordinates)
  // ==========================================================================

  // Reverse geocode coordinates to address
  //
  // Uses Google Maps Geocoding API
  static Future<Map<String, dynamic>?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? countryCode,
  }) async {
    if (!_hasApiKey) {
      debugPrint('Google Maps API key not configured');
      return null;
    }

    // Create simple cache key (rounded to 4 decimals ~11m accuracy)
    final cacheKey =
        '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

    // Check cache first
    if (_geocodeCache.containsKey(cacheKey)) {
      // debugPrint('✅ MapUtils: Using cached geocode result');
      return _geocodeCache[cacheKey];
    }

    try {
      // Build URL with optional country restriction
      String urlString =
          'https://maps.googleapis.com/maps/api/geocode/json?'
          'latlng=$latitude,$longitude&'
          'key=$_apiKey';

      if (countryCode != null) {
        urlString += '&region=$countryCode';
      }

      final url = Uri.parse(urlString);

      // debugPrint('🗺️  MapUtils: Reverse geocoding coordinates');

      final response = await http
          .get(url)
          .timeout(
            _apiTimeout,
            onTimeout: () => throw TimeoutException('API timeout'),
          );

      if (response.statusCode != 200) {
        // debugPrint('❌ MapUtils: API returned ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK' || data['results'] == null) {
        // debugPrint('❌ MapUtils: API status: ${data['status']}');
        return null;
      }

      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) {
        // debugPrint('❌ MapUtils: No results found');
        return null;
      }

      final result = results[0] as Map<String, dynamic>;
      final address = result['formatted_address'] as String;

      // Validate country if restriction was applied
      if (countryCode != null) {
        final country = _extractCountryCode(result);
        if (country?.toUpperCase() != countryCode.toUpperCase()) {
          // debugPrint('❌ MapUtils: Location outside restricted country');
          return null;
        }
      }

      // debugPrint('✅ MapUtils: Address found: $address');

      final geocodeResult = {
        'success': true,
        'address': address,
        'city': _extractCity(result),
        'country': _extractCountry(result),
        'country_code': _extractCountryCode(result),
      };

      // Cache the result (simple LRU: remove oldest if full)
      if (_geocodeCache.length >= _maxCacheSize) {
        _geocodeCache.remove(_geocodeCache.keys.first);
      }
      _geocodeCache[cacheKey] = geocodeResult;

      return geocodeResult;
    } catch (e) {
      // debugPrint('❌ MapUtils: Reverse geocoding failed - $e');
      return null;
    }
  }

  // Forward geocode address to coordinates with country restriction
  //
  // Uses Google Maps Geocoding API
  static Future<Map<String, dynamic>?> geocodeAddress(
    String address, {
    String? countryCode,
  }) async {
    if (!_hasApiKey) {
      debugPrint('Google Maps API key not configured');
      return null;
    }

    try {
      // Build URL with optional country restriction
      String urlString =
          'https://maps.googleapis.com/maps/api/geocode/json?'
          'address=${Uri.encodeComponent(address)}&'
          'key=$_apiKey';

      if (countryCode != null) {
        urlString +=
            '&components=country:$countryCode';
      }

      final url = Uri.parse(urlString);

      // debugPrint('🗺️  MapUtils: Geocoding address: $address');

      final response = await http
          .get(url)
          .timeout(
            _apiTimeout,
            onTimeout: () => throw TimeoutException('API timeout'),
          );

      if (response.statusCode != 200) {
        debugPrint('❌ MapUtils: API returned ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK' || data['results'] == null) {
        debugPrint('❌ MapUtils: API status: ${data['status']}');
        return null;
      }

      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) {
        debugPrint('❌ MapUtils: No results found');
        return null;
      }

      final result = results[0] as Map<String, dynamic>;
      final location = result['geometry']['location'] as Map<String, dynamic>;

      final lat = location['lat'] as double;
      final lng = location['lng'] as double;

      debugPrint('Coordinates found: $lat, $lng');

      return {
        'success': true,
        'latitude': lat,
        'longitude': lng,
        'address': result['formatted_address'] as String,
        'city': _extractCity(result),
        'country': _extractCountry(result),
        'country_code': _extractCountryCode(result),
      };
    } catch (e) {
      debugPrint('❌ MapUtils: Geocoding failed - $e');
      return null;
    }
  }

  // Extract country code from geocoding result
  static String? _extractCountryCode(Map<String, dynamic> result) {
    final components = result['address_components'] as List<dynamic>?;
    if (components == null) return null;

    for (final component in components) {
      final types = component['types'] as List<dynamic>;
      if (types.contains('country')) {
        return component['short_name'] as String; // Returns ISO code like "MA"
      }
    }
    return null;
  }

  // Get place details from place ID
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    if (!_hasApiKey) {
      debugPrint('❌ MapUtils: Google Maps API key not configured');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId&'
        'key=$_apiKey',
      );

      debugPrint('🗺️  MapUtils: Fetching place details for $placeId');

      final response = await http
          .get(url)
          .timeout(
            _apiTimeout,
            onTimeout: () => throw TimeoutException('API timeout'),
          );

      if (response.statusCode != 200) {
        debugPrint('❌ MapUtils: API returned ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK' || data['result'] == null) {
        debugPrint('❌ MapUtils: API status: ${data['status']}');
        return null;
      }

      final result = data['result'] as Map<String, dynamic>;
      final location = result['geometry']['location'] as Map<String, dynamic>;

      final lat = location['lat'] as double;
      final lng = location['lng'] as double;
      final address = result['formatted_address'] as String;

      debugPrint('✅ MapUtils: Place details found');

      return {
        'success': true,
        'latitude': lat,
        'longitude': lng,
        'address': address,
        'city': _extractCity(result),
        'country': _extractCountry(result),
      };
    } catch (e) {
      debugPrint('❌ MapUtils: Place details fetch failed - $e');
      return null;
    }
  }

  // ==========================================================================
  // MARKER CREATION
  // ==========================================================================

  // Create pickup marker (green pin)
  static Marker createPickupMarker({
    required LatLng position,
    String? address,
    double alpha = 1.0,
  }) {
    return Marker(
      markerId: const MarkerId('pickup'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      alpha: alpha,
      infoWindow: InfoWindow(title: 'Départ', snippet: address ?? ''),
    );
  }

  // Create destination marker (red pin)
  static Marker createDestinationMarker({
    required LatLng position,
    String? address,
    double alpha = 1.0,
  }) {
    return Marker(
      markerId: const MarkerId('destination'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      alpha: alpha,
      infoWindow: InfoWindow(title: 'Arrivée', snippet: address ?? ''),
    );
  }

  // Create passenger marker (blue person icon)
  static Marker createPassengerMarker({
    required LatLng position,
    String? passengerName,
  }) {
    return Marker(
      markerId: const MarkerId('passenger'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: passengerName ?? 'Passager'),
    );
  }

  // Create driver marker (yellow car icon)
  static Marker createDriverMarker({
    required LatLng position,
    String? driverName,
    String? vehicleModel,
  }) {
    return Marker(
      markerId: const MarkerId('driver'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
        title: driverName ?? 'Chauffeur',
        snippet: vehicleModel,
      ),
    );
  }

  // Create temporary selection marker (for map-based location selection)
  static Marker createTempSelectionMarker({
    required LatLng position,
    required bool isPickup,
  }) {
    return Marker(
      markerId: const MarkerId('temp_selection'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        isPickup ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
      ),
      alpha: 0.7, // Semi-transparent to indicate temporary
    );
  }

  // ==========================================================================
  // POLYLINE CREATION
  // ==========================================================================


  static Polyline createPolyline({
    required String id,
    required List<LatLng> points,
    Color? color,
    int width = 4,
    bool dashed = true,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color ?? AppColors.primary,
      width: width,
      patterns: dashed
          ? [PatternItem.dash(10), PatternItem.gap(8)]
          : [], // Solid line when not dashed
    );
  }

  // ==========================================================================
  // CAMERA POSITIONING
  // ==========================================================================

  // Fit camera to show all coordinates
  static Future<void> fitBounds({
    required GoogleMapController controller,
    required List<LatLng> coordinates,
    double padding = 80.0,
  }) async {
    if (coordinates.isEmpty) {
      debugPrint('⚠️  MapUtils: Cannot fit bounds - empty coordinates');
      return;
    }

    if (coordinates.length == 1) {
      // Single point - just zoom to it
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(coordinates.first, 15.0),
      );
      return;
    }

    try {
      // Calculate bounds
      double minLat = coordinates.first.latitude;
      double maxLat = coordinates.first.latitude;
      double minLng = coordinates.first.longitude;
      double maxLng = coordinates.first.longitude;

      for (final point in coordinates) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );

      debugPrint('✅ MapUtils: Camera fitted to bounds');
    } catch (e) {
      debugPrint('❌ MapUtils: Error fitting bounds - $e');
    }
  }

  // Move camera to specific position
  static Future<void> moveTo({
    required GoogleMapController controller,
    required LatLng position,
    double zoom = 15.0,
  }) async {
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(position, zoom),
      );
      debugPrint('✅ MapUtils: Camera moved to position');
    } catch (e) {
      debugPrint('❌ MapUtils: Error moving camera - $e');
    }
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  // Decode Google Maps polyline encoding
  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Extract city from geocoding result
  static String? _extractCity(Map<String, dynamic> result) {
    final components = result['address_components'] as List<dynamic>?;
    if (components == null) return null;

    for (final component in components) {
      final types = component['types'] as List<dynamic>;
      if (types.contains('locality')) {
        return component['long_name'] as String;
      }
    }
    return null;
  }

  // Extract country from geocoding result
  static String? _extractCountry(Map<String, dynamic> result) {
    final components = result['address_components'] as List<dynamic>?;
    if (components == null) return null;

    for (final component in components) {
      final types = component['types'] as List<dynamic>;
      if (types.contains('country')) {
        return component['long_name'] as String;
      }
    }
    return null;
  }

  // Check if two coordinates are close (within 100 meters)
  //
  // Useful to avoid unnecessary camera animations
  static bool areCoordinatesClose(LatLng point1, LatLng point2) {
    // Simple lat/lng difference check (approximately 100m at equator)
    const threshold = 0.001; // ~111 meters at equator

    final latDiff = (point1.latitude - point2.latitude).abs();
    final lngDiff = (point1.longitude - point2.longitude).abs();

    return latDiff < threshold && lngDiff < threshold;
  }

  // ==========================================================================
  // ARC GENERATION (Visual indicator without API calls)
  // ==========================================================================

  // Generate a curved arc between two points for visual representation
  //
  // Creates a smooth curved path without making API calls
  // Perfect for preview states before actual route calculation
  static List<LatLng> generateArc({
    required LatLng origin,
    required LatLng destination,
    int segments = 30,
    double arcHeightDegrees = 0.004, // Fixed arc height in degrees (~2km)
  }) {
    final points = <LatLng>[];

    final latDiff = destination.latitude - origin.latitude;
    final lngDiff = destination.longitude - origin.longitude;

    // Generate points along the arc
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;

      // Linear interpolation
      final lat = origin.latitude + (latDiff * t);
      final lng = origin.longitude + (lngDiff * t);

      // Add fixed curve using parabola formula
      // Arc height is constant regardless of distance
      final curve = 4 * arcHeightDegrees * t * (1 - t);

      points.add(LatLng(lat + curve, lng));
    }

    return points;
  }
  
}

// Timeout exception for API calls
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
