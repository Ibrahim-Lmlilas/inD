// Map Provider
//
// Manages map state and delegates all calculations to MapUtils
// No longer contains any calculation logic or marker creation

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/map_utils.dart';
import 'disposable_provider.dart';

class MapProvider extends DisposableProvider {
  GoogleMapController? _mapController;

  // Location State
  LatLng? _currentLocation;
  String? _pickupLocation;
  String? _destinationLocation;
  String? _pickupCity;
  String? _destinationCity;
  LatLng? _pickupLatLng;
  LatLng? _destinationLatLng;

  // Route State
  List<LatLng> _routePoints = [];
  double? _distance;
  String? _estimatedTime;

  // Markers and Polylines
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Loading States
  bool _isLoadingLocation = true;
  bool _isCalculatingRoute = false;
  bool _hasInitialZoom = false;

  // Map Selection State
  bool _isSelectingLocation = false;
  String? _selectionTarget;
  LatLng? _tempSelectionLatLng;
  bool _isGeocodingSelection = false;

  // Route Preview State
  int _routeCalculationId = 0;
  Timer? _previewDebounceTimer;
  static const Duration _previewDebounce = Duration(milliseconds: 800);

  // Arc Mode
  bool _useArcMode = true;

  // Constants
  static const double _cameraPadding = 80.0;

  String? _errorMessage;

  // Getters
  GoogleMapController? get mapController => _mapController;
  LatLng? get currentLocation => _currentLocation;
  String? get pickupLocation => _pickupLocation;
  String? get destinationLocation => _destinationLocation;
  String? get pickupCity => _pickupCity;
  String? get destinationCity => _destinationCity;
  LatLng? get pickupLatLng => _pickupLatLng;
  LatLng? get destinationLatLng => _destinationLatLng;
  List<LatLng> get routePoints => _routePoints;
  double? get distance => _distance;
  String? get estimatedTime => _estimatedTime;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isCalculatingRoute => _isCalculatingRoute;
  String? get errorMessage => _errorMessage;
  bool get hasRoute => _routePoints.isNotEmpty;
  bool get canCalculateRoute =>
      _pickupLatLng != null && _destinationLatLng != null;
  bool get isSelectingLocation => _isSelectingLocation;
  String? get selectionTarget => _selectionTarget;
  LatLng? get tempSelectionLatLng => _tempSelectionLatLng;
  bool get isGeocodingSelection => _isGeocodingSelection;
  bool get useArcMode => _useArcMode;

  // ==========================================================================
  // ARC MODE MANAGEMENT
  // ==========================================================================
  void setArcMode(bool useArc) {
    if (isDisposed) return;
    if (_useArcMode == useArc) return;

    _useArcMode = useArc;

    // Redraw based on mode
    if (canCalculateRoute) {
      calculateRoute(); // Full route
    }
    safeNotify();
  }

  void _drawArc() {
    if (_pickupLatLng == null || _destinationLatLng == null) {
      _polylines = {};
      return;
    }

    final arcPoints = MapUtils.generateArc(
      origin: _pickupLatLng!,
      destination: _destinationLatLng!,
    );

    if (_isSelectingLocation) {
      _polylines = {
        MapUtils.createPolyline(
          id: 'preview_arc',
          points: arcPoints,
          color: const Color(0xFF2196F3).withValues(alpha: 0.4),
          width: 3,
        ),
      };
    } else {
      _polylines = {
        MapUtils.createPolyline(
          id: 'arc',
          points: arcPoints,
          color: const Color(0xFF2196F3).withValues(alpha: 0.7),
          width: 4,
          dashed: false,
        ),
      };
    }
  }

  // ==========================================================================
  // BATCHED UPDATES
  // ==========================================================================

  void _batchUpdate(VoidCallback updates) {
    updates();
    safeNotify();
  }

  void _silentUpdate(VoidCallback updates) {
    updates();
  }

  // ==========================================================================
  // MAP CONTROLLER
  // ==========================================================================

  void setMapController(GoogleMapController controller) {
    if (isDisposed) return;
    _mapController = controller;
    safeNotify();
  }

  // ==========================================================================
  // LOCATION INITIALIZATION
  // ==========================================================================

  Future<void> initializeLocation() async {
    _batchUpdate(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _batchUpdate(() {
          _errorMessage = 'Services de localisation désactivés';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _batchUpdate(() {
            _errorMessage = 'Permission de localisation refusée';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _batchUpdate(() {
          _errorMessage =
              'Veuillez activer la localisation dans les paramètres';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (isDisposed) return;

      _silentUpdate(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      try {
        final addressData = await MapUtils.reverseGeocode(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (isDisposed) return;

        _silentUpdate(() {
          if (addressData != null && addressData['success'] == true) {
            _pickupLocation = addressData['address'];
            _pickupCity = addressData['city'];
            _pickupLatLng = _currentLocation;
          } else {
            _pickupLocation = 'Ma position actuelle';
            _pickupLatLng = _currentLocation;
          }
        });
      } catch (e) {
        debugPrint('Geocoding error: $e');
        if (isDisposed) return;

        _silentUpdate(() {
          _pickupLocation = 'Ma position actuelle';
          _pickupLatLng = _currentLocation;
        });
      }

      _updateMarkers();

      if (!_hasInitialZoom &&
          _currentLocation != null &&
          _mapController != null) {
        await MapUtils.moveTo(
          controller: _mapController!,
          position: _currentLocation!,
          zoom: 15,
        );
        _hasInitialZoom = true;
      }

      _batchUpdate(() => _isLoadingLocation = false);
    } catch (e) {
      if (!isDisposed) {
        _batchUpdate(() {
          _errorMessage = 'Erreur de localisation: ${e.toString()}';
          _isLoadingLocation = false;
        });
      }
    }
  }

  // ==========================================================================
  // LOCATION MANAGEMENT
  // ==========================================================================

  void setPickupLocation(String location, LatLng latLng, {String? city}) {
    if (isDisposed) return;

    _batchUpdate(() {
      _pickupLocation = location;
      _pickupLatLng = latLng;
      _pickupCity = city;
      _errorMessage = null;
      _clearRoute();
      _updateMarkers();
    });
  }

void setDestinationLocation(String location, LatLng latLng, {String? city}) {
    if (isDisposed) return;

    _batchUpdate(() {
      _destinationLocation = location;
      _destinationLatLng = latLng;
      _destinationCity = city;
      _errorMessage = null;
      _updateMarkers();
    });

    if (canCalculateRoute) {
      calculateRoute();
    }
  }

  void clearPickupLocation() {
    if (isDisposed) return;

    _batchUpdate(() {
      _pickupLocation = null;
      _pickupLatLng = null;
      _pickupCity = null;
      _clearRoute();
      _updateMarkers();
    });
  }

  void clearDestinationLocation() {
    if (isDisposed) return;

    _batchUpdate(() {
      _destinationLocation = null;
      _destinationLatLng = null;
      _destinationCity = null;
      _clearRoute();
      _updateMarkers();
    });
  }

  // ==========================================================================
  // MAP SELECTION - OPTIMIZED
  // ==========================================================================

  void startMapSelection(String target) {
    if (isDisposed) return;

    _batchUpdate(() {
      _isSelectingLocation = true;
      _selectionTarget = target;

      if (target == 'pickup' && _pickupLatLng != null) {
        _tempSelectionLatLng = _pickupLatLng;
      } else if (target == 'destination' && _destinationLatLng != null) {
        _tempSelectionLatLng = _destinationLatLng;
      } else if (_currentLocation != null) {
        _tempSelectionLatLng = _currentLocation;
      }

      _updateMarkersForSelection();
    });

    _calculatePreviewRoute();
  }

  void updateTempSelection(LatLng position) {
    if (isDisposed) return;

    // Silent update - don't notify yet
    _tempSelectionLatLng = position;
    _updateMarkersForSelection();

    // Only notify after route calculation
    _calculatePreviewRoute();
  }

  void _calculatePreviewRoute() {
    if (isDisposed) return;
    if (_tempSelectionLatLng == null) return;

    _previewDebounceTimer?.cancel();

    LatLng? origin;
    LatLng? destination;

    if (_selectionTarget == 'pickup') {
      origin = _tempSelectionLatLng;
      destination = _destinationLatLng;
    } else if (_selectionTarget == 'destination') {
      origin = _pickupLatLng;
      destination = _tempSelectionLatLng;
    }

    if (origin == null || destination == null) {
      _silentUpdate(() {
        _routePoints = [];
        _distance = null;
        _estimatedTime = null;
        _updatePolylines();
      });
      safeNotify();
      return;
    }

    final capturedOrigin = origin;
    final capturedDestination = destination;
    final capturedPosition = _tempSelectionLatLng;
    final capturedCalculationId = ++_routeCalculationId;

    _previewDebounceTimer = Timer(_previewDebounce, () {
      if (isDisposed) return;
      if (!_isSelectingLocation) return;
      if (_tempSelectionLatLng != capturedPosition) return;
      if (_routeCalculationId != capturedCalculationId) return;

      if (_useArcMode) {
        // draw arc for preview
        _silentUpdate(() {
          final arcPoints = MapUtils.generateArc(
            origin: capturedOrigin,
            destination: capturedDestination,
          );
          _polylines = {
            MapUtils.createPolyline(
              id: 'preview_arc',
              points: arcPoints,
              color: const Color(0xFF2196F3).withValues(alpha: 0.4),
              width: 3,
            ),
          };
        });
        safeNotify();
      } else {
        // Full route preview
        _calculateRoutePreview(
          capturedOrigin,
          capturedDestination,
          capturedCalculationId,
        );
      }
    });
  }

  Future<void> _calculateRoutePreview(
    LatLng origin,
    LatLng destination,
    int calculationId,
  ) async {
    if (isDisposed) return;

    try {
      final routeData = await MapUtils.calculateRoute(
        origin: origin,
        destination: destination,
      );

      if (isDisposed) return;
      if (calculationId != _routeCalculationId) return;

      if (routeData != null && routeData['success'] == true) {
        // Single batched update
        _batchUpdate(() {
          _routePoints = routeData['points'] as List<LatLng>;
          _distance = routeData['distance'] as double?;
          _estimatedTime = routeData['durationText'] as String?;
          _updatePolylines();
        });
      }
    } catch (e) {
      if (isDisposed) return;
      debugPrint('Preview route calculation error: $e');
    }
  }

  Future<void> confirmMapSelection() async {
    if (isDisposed) return;
    if (_tempSelectionLatLng == null || _selectionTarget == null) {
      cancelMapSelection();
      return;
    }

    _batchUpdate(() => _isGeocodingSelection = true);

    try {
      final addressData = await MapUtils.reverseGeocode(
        latitude: _tempSelectionLatLng!.latitude,
        longitude: _tempSelectionLatLng!.longitude,
        // countryCode: 'MA',
      );

      if (isDisposed) return;

      if (addressData == null) {
        _batchUpdate(() {
          _errorMessage = 'Seuls les emplacements au Maroc sont autorisés';
          _isSelectingLocation = false;
          _selectionTarget = null;
          _tempSelectionLatLng = null;
          _isGeocodingSelection = false;
        });
        return;
      }

      String address = addressData['address'] as String;
      String? city = addressData['city'] as String?;

      if (_selectionTarget == 'pickup') {
        _pickupLocation = address;
        _pickupLatLng = _tempSelectionLatLng;
        _pickupCity = city;
      } else if (_selectionTarget == 'destination') {
        _destinationLocation = address;
        _destinationLatLng = _tempSelectionLatLng;
        _destinationCity = city;
      }

      _batchUpdate(() {
        _isSelectingLocation = false;
        _selectionTarget = null;
        _tempSelectionLatLng = null;
        _isGeocodingSelection = false;
        _errorMessage = null;
        _updateMarkers();
      });

      if (canCalculateRoute) {
        calculateRoute();
      }
    } catch (e) {
      debugPrint('Error confirming map selection: $e');
      if (!isDisposed) {
        _batchUpdate(() {
          _errorMessage = 'Erreur lors de la sélection';
          _isSelectingLocation = false;
          _selectionTarget = null;
          _tempSelectionLatLng = null;
          _isGeocodingSelection = false;
        });
      }
    }
  }

  void cancelMapSelection() {
    if (isDisposed) return;

    _previewDebounceTimer?.cancel();

    _batchUpdate(() {
      _isSelectingLocation = false;
      _selectionTarget = null;
      _tempSelectionLatLng = null;
      _updateMarkers();
    });

    if (canCalculateRoute) {
      calculateRoute();
    } else {
      _clearRoute();
    }
  }

  // ==========================================================================
  // ROUTE CALCULATION
  // ==========================================================================

Future<void> calculateRoute() async {
    if (!canCalculateRoute || isDisposed) return;

    _batchUpdate(() {
      _isCalculatingRoute = true;
      _errorMessage = null;
    });

    try {
      final routeData = await MapUtils.calculateRoute(
        origin: _pickupLatLng!,
        destination: _destinationLatLng!,
      );

      if (isDisposed) return;

      if (routeData != null && routeData['success'] == true) {
        _batchUpdate(() {
          _routePoints = routeData['points'] as List<LatLng>;
          _distance = routeData['distance'] as double?;
          _estimatedTime = routeData['durationText'] as String?;
          _isCalculatingRoute = false;

          if (_useArcMode) {
            _drawArc();
          } else {
            _updatePolylines();
          }
        });

        // Only fit view if not using arc mode
        if (!_useArcMode) {
          _fitRouteInView();
        }
      } else {
        _batchUpdate(() {
          _errorMessage = 'Erreur de calcul d\'itinéraire';
          _isCalculatingRoute = false;
        });
      }
    } catch (e) {
      if (!isDisposed) {
        _batchUpdate(() {
          _errorMessage = 'Erreur: ${e.toString()}';
          _isCalculatingRoute = false;
        });
      }
    }
  }

  void _clearRoute() {
    _routePoints = [];
    _distance = null;
    _estimatedTime = null;
    _polylines = {};
  }

  // ==========================================================================
  // MARKER & POLYLINE UPDATES
  // ==========================================================================

  void _updateMarkers() {
    final markers = <Marker>{};

    if (_pickupLatLng != null) {
      markers.add(
        MapUtils.createPickupMarker(
          position: _pickupLatLng!,
          address: _pickupLocation,
        ),
      );
    }

    if (_destinationLatLng != null) {
      markers.add(
        MapUtils.createDestinationMarker(
          position: _destinationLatLng!,
          address: _destinationLocation,
        ),
      );
    }

    _markers = markers;
  }

  void _updateMarkersForSelection() {
    final markers = <Marker>{};

    if (_pickupLatLng != null && _selectionTarget != 'pickup') {
      markers.add(
        MapUtils.createPickupMarker(
          position: _pickupLatLng!,
          address: _pickupLocation,
          alpha: 0.5,
        ),
      );
    }

    if (_destinationLatLng != null && _selectionTarget != 'destination') {
      markers.add(
        MapUtils.createDestinationMarker(
          position: _destinationLatLng!,
          address: _destinationLocation,
          alpha: 0.5,
        ),
      );
    }

    if (_tempSelectionLatLng != null && _selectionTarget != null) {
      markers.add(
        MapUtils.createTempSelectionMarker(
          position: _tempSelectionLatLng!,
          isPickup: _selectionTarget == 'pickup',
        ),
      );
    }

    _markers = markers;
  }

  void _updatePolylines() {
    if (_routePoints.isEmpty) {
      _polylines = {};
      return;
    }

    if (_isSelectingLocation) {
      _polylines = {
        MapUtils.createPolyline(
          id: 'preview_route',
          points: _routePoints,
          color: const Color(0xFF2196F3).withValues(alpha: 0.5),
          width: 4,
          dashed: true,
        ),
      };
    } else {
      _polylines = {
        MapUtils.createPolyline(
          id: 'route',
          points: _routePoints,
          color: const Color(0xFF2196F3),
          width: 5,
        ),
      };
    }
  }

  void _fitRouteInView() {
    if (isDisposed) return;
    if (_pickupLatLng == null || _destinationLatLng == null) return;
    if (_mapController == null) return;

    final coordinates = _routePoints.isNotEmpty
        ? _routePoints
        : [_pickupLatLng!, _destinationLatLng!];

    MapUtils.fitBounds(
      controller: _mapController!,
      coordinates: coordinates,
      padding: _cameraPadding,
    );
  }

  // ==========================================================================
  // ERROR HANDLING
  // ==========================================================================

  void clearError() {
    if (isDisposed) return;
    if (_errorMessage == null) return;

    _batchUpdate(() => _errorMessage = null);
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void reset() {
    if (isDisposed) return;

    _previewDebounceTimer?.cancel();

    _batchUpdate(() {
      _mapController = null;
      _currentLocation = null;
      _pickupLocation = null;
      _destinationLocation = null;
      _pickupCity = null;
      _destinationCity = null;
      _pickupLatLng = null;
      _destinationLatLng = null;
      _clearRoute();
      _markers = {};
      _polylines = {};
      _isLoadingLocation = true;
      _isCalculatingRoute = false;
      _hasInitialZoom = false;
      _isSelectingLocation = false;
      _selectionTarget = null;
      _tempSelectionLatLng = null;
      _isGeocodingSelection = false;
      _routeCalculationId = 0;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _previewDebounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
