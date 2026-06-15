import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/config/request_permissions.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/utils/log_utils.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onInitComplete;

  const AppInitializer({super.key, required this.child, this.onInitComplete});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitializing = true;
  bool _hasLocationPermission = false;
  bool _showPermissionError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final hasPermission = await RequestPermissions.requestLocationPermission();

      if (!hasPermission) {
        logWarning('AppInitializer', 'Location permission denied');
        setState(() {
          _hasLocationPermission = false;
          _showPermissionError = true;
          _isInitializing = false;
        });
        return;
      }

      logSuccess('AppInitializer', 'Location permission granted');

      final serviceEnabled = await RequestPermissions.isLocationServiceEnabled();

      if (!serviceEnabled) {
        logWarning('AppInitializer', 'Location service disabled');
        setState(() {
          _hasLocationPermission = false;
          _showPermissionError = true;
          _isInitializing = false;
        });
        return;
      }

      logSuccess('AppInitializer', 'Initialization complete');

      setState(() {
        _hasLocationPermission = true;
        _isInitializing = false;
      });

      widget.onInitComplete?.call();
    } catch (e) {
      logError('AppInitializer', 'Initialization error: $e');
      setState(() {
        _hasLocationPermission = false;
        _showPermissionError = true;
        _isInitializing = false;
      });
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _isInitializing = true;
      _showPermissionError = false;
    });
    await _initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return widget.child;
    }

    if (_showPermissionError || !_hasLocationPermission) {
      return _buildPermissionErrorScreen();
    }

    return widget.child;
  }

  Widget _buildPermissionErrorScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    size: 50,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Permission Requise',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'Cette application nécessite l\'accès à votre localisation pour fonctionner.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nous utilisons votre localisation pour :',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        Icons.my_location_rounded,
                        'Détecter votre position actuelle',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.route_rounded,
                        'Calculer les itinéraires optimaux',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.local_taxi_rounded,
                        'Trouver des chauffeurs à proximité',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.navigation_rounded,
                        'Naviguer vers votre destination',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _retryInitialization,
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    label: const Text(
                      'Réessayer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Si le problème persiste, activez la localisation dans les paramètres de votre appareil.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}