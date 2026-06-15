/// Unified Ride History Page
///
/// Single page that handles both passenger and driver views
/// Uses `isDriverMode` parameter to switch between contexts

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/services/api_interceptor.dart';
import 'package:srrfrr_app_front/core/services/snackbar_service.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/ride_history/data/services/ride_history_service.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/shared/providers/rating_provider.dart';
import 'package:srrfrr_app_front/shared/models/rating.dart';
import 'package:srrfrr_app_front/shared/widgets/rating_dialog.dart';
import 'package:srrfrr_app_front/shared/widgets/report_dialog.dart';
import 'package:srrfrr_app_front/features/ride_history/presentation/widgets/ride_filters.dart';
import 'package:srrfrr_app_front/features/ride_history/presentation/widgets/shared_widgets.dart';

class RideHistoryPage extends StatefulWidget {
  final bool isDriverMode;

  const RideHistoryPage({super.key, required this.isDriverMode});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  final RideHistoryService _apiService = RideHistoryService(ApiInterceptor());
  final ScrollController _scrollController = ScrollController();

  // Filter states
  String _selectedStatus = 'All';
  String _selectedPayment = 'All';
  String _selectedVehicle = 'All';
  String _sortBy = 'Price (high to low)';
  String? _searchName;
  DateTimeRange? _dateRange;
  RangeValues? _priceRange;
  bool _showFilters = false;
  String? _expandedRideId;

  // Data state
  List<RideHistoryItem> _rides = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _isDisposed = false;

  // Pagination state
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadRides(isInitial: true);
    _setupScrollListener();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMore && !_isLoading) {
          _loadMoreRides();
        }
      }
    });
  }

  String? _mapStatusToBackend(String status) {
    if (status == 'All') return null;
    return status.toUpperCase();
  }

  String? _mapPaymentToBackend(String payment) {
    if (payment == 'All') return null;

    switch (payment) {
      case 'Cash':
        return 'CASH';
      case 'Wallet':
        return 'WALLET';
      case 'CreditCard':
        return 'CARD';
      case 'LoyaltyPoints':
        return 'REDUCTION';
      case 'FreeRide':
        return 'FREERIDE';
      default:
        return payment.toUpperCase();
    }
  }

  String? _mapVehicleToBackend(String vehicle) {
    if (vehicle == 'All') return null;

    switch (vehicle) {
      case 'Voiture':
        return 'CAR';
      case 'Moto':
        return 'MOTORCYCLE';
      case 'Camion':
        return 'TRUCK';
      default:
        return vehicle.toUpperCase();
    }
  }

  Future<void> _loadRides({bool isInitial = false}) async {
    if (_isDisposed) return;

    if (isInitial) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 0;
        _rides.clear();
      });
    }

    try {
      final response = widget.isDriverMode
          ? await _apiService.getDriverRideHistory(
              page: _currentPage,
              size: _pageSize,
              status: _mapStatusToBackend(_selectedStatus),
              paymentType: _mapPaymentToBackend(_selectedPayment),
              vehicleType: _mapVehicleToBackend(_selectedVehicle),
              driverName: _searchName,
              startDate: _dateRange?.start,
              endDate: _dateRange?.end,
              minPrice: _priceRange?.start,
              maxPrice: _priceRange?.end,
            )
          : await _apiService.getPassengerRideHistory(
              page: _currentPage,
              size: _pageSize,
              status: _mapStatusToBackend(_selectedStatus),
              paymentType: _mapPaymentToBackend(_selectedPayment),
              vehicleType: _mapVehicleToBackend(_selectedVehicle),
              driverName: _searchName,
              startDate: _dateRange?.start,
              endDate: _dateRange?.end,
              minPrice: _priceRange?.start,
              maxPrice: _priceRange?.end,
            );

      if (_isDisposed) return;

      if (response['success'] == true) {
        final ridesData = response['rides'] as List<dynamic>;
        final newRides = ridesData.map((rideJson) {
          return RideHistoryItem.fromJson(
            rideJson as Map<String, dynamic>,
            isDriverMode: widget.isDriverMode,
            l10n: AppLocalizations.of(context)!,
          );
        }).toList();

        _totalPages = response['totalPages'] ?? 0;
        _totalElements = response['totalElements'] ?? 0;
        _hasMore = !response['last'];

        if (mounted && !_isDisposed) {
          setState(() {
            if (isInitial) {
              _rides = newRides;
            } else {
              _rides.addAll(newRides);
            }
            _isLoading = false;
            _isLoadingMore = false;
          });
        }

        debugPrint(
          '✅ Loaded ${newRides.length} rides (page $_currentPage/$_totalPages)',
        );
      } else {
        if (mounted && !_isDisposed) {
          setState(() {
            _errorMessage = response['message'] ?? 'Erreur de chargement';
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading rides: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMessage = 'Erreur de connexion';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreRides() async {
    if (_isLoadingMore || !_hasMore || _isDisposed) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _loadRides(isInitial: false);
  }

  Future<void> _refreshRides() async {
    HapticFeedback.lightImpact();
    await _loadRides(isInitial: true);
  }

  List<RideHistoryItem> get _filteredRides {
    var rides = List<RideHistoryItem>.from(_rides);

    // Apply client-side sorting
    switch (_sortBy) {
      case 'Price (high to low)':
        rides.sort((a, b) => b.fareAmount.compareTo(a.fareAmount));
        break;
      case 'Price (low to high)':
        rides.sort((a, b) => a.fareAmount.compareTo(b.fareAmount));
        break;
      case 'Distance':
        rides.sort((a, b) => b.distance.compareTo(a.distance));
        break;
    }

    return rides;
  }

  double get _totalAmount {
    return _rides
        .where((ride) => ride.status == RideStatus.completed)
        .fold(0.0, (sum, ride) => sum + ride.fareAmount);
  }

  int get _totalRides {
    return _rides.where((ride) => ride.status == RideStatus.completed).length;
  }

  void _toggleExpanded(String rideId) {
    if (_isDisposed) return;
    setState(() {
      _expandedRideId = _expandedRideId == rideId ? null : rideId;
    });
  }

  void _rateRide(RideHistoryItem ride) {
    HapticFeedback.lightImpact();

    final receiverId = widget.isDriverMode ? ride.passengerId : ride.driverId;
    final receiverName = widget.isDriverMode
        ? ride.passengerName
        : ride.driverName;
    final ratingType = widget.isDriverMode
        ? RatingType.driverToPassenger
        : RatingType.passengerToDriver;

    showRatingDialog(
      context: context,
      rideId: ride.id,
      receiverId: receiverId,
      receiverName: receiverName,
      ratingType: ratingType,
      onSuccess: () {
        final ratingProvider = context.read<RatingProvider>();
        ratingProvider.clearRideRatingStatus(ride.id);
        final l10n = AppLocalizations.of(context)!;
        SnackBarService(context).showSuccess(l10n.thankYouForRating);
      },
    );
  }

  void _contactSupport(RideHistoryItem ride) {
    HapticFeedback.lightImpact();

    showReportBottomSheet(
      context: context,
      rideId: ride.id,
      onSuccess: () {
        final l10n = AppLocalizations.of(context)!;
        SnackBarService(context).showSuccess(l10n.complaintSent);
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedPayment = 'All';
      _selectedVehicle = 'All';
      _sortBy = 'Price (high to low)';
      _searchName = null;
      _dateRange = null;
      _priceRange = null;
    });
    _loadRides(isInitial: true);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.rideHistory,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (!_isDisposed) {
                setState(() => _showFilters = !_showFilters);
              }
            },
            tooltip: l10n.filters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(padding, l10n)
          : RefreshIndicator(
              onRefresh: _refreshRides,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Stats Header
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: padding),
                        StatsHeader(
                          totalRides: _totalRides,
                          totalAmount: _totalAmount,
                          isDriver: widget.isDriverMode,
                          padding: padding,
                        ),

                        // Pagination Info
                        if (_totalElements > 0)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: padding,
                              vertical: padding * 0.5,
                            ),
                            child: Text(
                              l10n.ridesLoaded(_rides.length, _totalElements),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Filters Section
                        if (_showFilters)
                          RideFiltersSection(
                            selectedStatus: _selectedStatus,
                            selectedPayment: _selectedPayment,
                            selectedVehicle: _selectedVehicle,
                            sortBy: _sortBy,
                            searchName: _searchName,
                            dateRange: _dateRange,
                            priceRange: _priceRange,
                            onStatusChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _selectedStatus = value);
                                _loadRides(isInitial: true);
                              }
                            },
                            onPaymentChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _selectedPayment = value);
                                _loadRides(isInitial: true);
                              }
                            },
                            onVehicleChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _selectedVehicle = value);
                                _loadRides(isInitial: true);
                              }
                            },
                            onSortChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _sortBy = value);
                              }
                            },
                            onNameChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _searchName = value);
                                _loadRides(isInitial: true);
                              }
                            },
                            onDateRangeChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _dateRange = value);
                                _loadRides(isInitial: true);
                              }
                            },
                            onPriceRangeChanged: (value) {
                              if (!_isDisposed) {
                                setState(() => _priceRange = value);
                                _loadRides(isInitial: true);
                              }
                            },
                            onClearFilters: _clearAllFilters,
                            padding: padding,
                          ),

                        SizedBox(height: padding),
                      ],
                    ),
                  ),

                  // Rides List or Empty State
                  if (_filteredRides.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(padding: padding),
                    )
                  else
                    Consumer<RatingProvider>(
                      builder: (context, ratingProvider, _) {
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == _filteredRides.length) {
                                  return _isLoadingMore
                                      ? _buildLoadingMoreIndicator(l10n)
                                      : const SizedBox.shrink();
                                }

                                final ride = _filteredRides[index];
                                final isExpanded = _expandedRideId == ride.id;
                                final canRate =
                                    ride.status == RideStatus.completed &&
                                    !ride.isRated;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: padding),
                                  child: RideCard(
                                    ride: ride,
                                    isExpanded: isExpanded,
                                    canRate: canRate,
                                    isDriverMode: widget.isDriverMode,
                                    onToggleExpanded: () =>
                                        _toggleExpanded(ride.id),
                                    onRate: () => _rateRide(ride),
                                    onSupport: () => _contactSupport(ride),
                                  ),
                                );
                              },
                              childCount:
                                  _filteredRides.length +
                                  (_isLoadingMore ? 1 : 0),
                            ),
                          ),
                        );
                      },
                    ),

                  // Bottom Padding
                  SliverToBoxAdapter(child: SizedBox(height: padding)),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingMoreIndicator(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loading,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(double padding, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadingError,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? l10n.connectionError,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadRides(isInitial: true),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}