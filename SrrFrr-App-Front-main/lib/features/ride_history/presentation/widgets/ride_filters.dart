/// Ride History Filters Section
/// Enhanced scrollable filtering UI with modern UX
/// Filters only apply when user clicks "Appliquer les filtres"

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class RideFiltersSection extends StatefulWidget {
  final String selectedStatus;
  final String selectedPayment;
  final String selectedVehicle;
  final String sortBy;
  final String? searchName;
  final DateTimeRange? dateRange;
  final RangeValues? priceRange;
  final Function(String) onStatusChanged;
  final Function(String) onPaymentChanged;
  final Function(String) onVehicleChanged;
  final Function(String) onSortChanged;
  final Function(String?) onNameChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(RangeValues?) onPriceRangeChanged;
  final VoidCallback onClearFilters;
  final double padding;

  const RideFiltersSection({
    super.key,
    required this.selectedStatus,
    required this.selectedPayment,
    required this.selectedVehicle,
    required this.sortBy,
    this.searchName,
    this.dateRange,
    this.priceRange,
    required this.onStatusChanged,
    required this.onPaymentChanged,
    required this.onVehicleChanged,
    required this.onSortChanged,
    required this.onNameChanged,
    required this.onDateRangeChanged,
    required this.onPriceRangeChanged,
    required this.onClearFilters,
    required this.padding,
  });

  @override
  State<RideFiltersSection> createState() => _RideFiltersSectionState();
}

class _RideFiltersSectionState extends State<RideFiltersSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  final TextEditingController _nameController = TextEditingController();

  // Local state for pending changes
  String? _pendingName;
  String _pendingStatus = 'All';
  String _pendingPayment = 'All';
  String _pendingVehicle = 'All';
  String _pendingSortBy = 'Price (high to low)';
  DateTimeRange? _pendingDateRange;
  RangeValues? _pendingPriceRange;
  bool _hasPendingChanges = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _initializePendingFilters();
  }

  void _initializePendingFilters() {
    _nameController.text = widget.searchName ?? '';
    _pendingName = widget.searchName;
    _pendingStatus = widget.selectedStatus;
    _pendingPayment = widget.selectedPayment;
    _pendingVehicle = widget.selectedVehicle;
    _pendingSortBy = widget.sortBy;
    _pendingDateRange = widget.dateRange;
    _pendingPriceRange = widget.priceRange;
  }

  @override
  void didUpdateWidget(RideFiltersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update pending filters if parent state changes
    if (!_hasPendingChanges) {
      _initializePendingFilters();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  int get _activeFiltersCount {
    int count = 0;
    if (widget.selectedStatus != 'All') count++;
    if (widget.selectedPayment != 'All') count++;
    if (widget.selectedVehicle != 'All') count++;
    if (widget.searchName != null && widget.searchName!.isNotEmpty) count++;
    if (widget.dateRange != null) count++;
    if (widget.priceRange != null) count++;
    return count;
  }

  void _applyAllFilters() {
    widget.onStatusChanged(_pendingStatus);
    widget.onPaymentChanged(_pendingPayment);
    widget.onVehicleChanged(_pendingVehicle);
    widget.onSortChanged(_pendingSortBy);
    widget.onNameChanged(_pendingName);
    widget.onDateRangeChanged(_pendingDateRange);
    widget.onPriceRangeChanged(_pendingPriceRange);

    setState(() {
      _hasPendingChanges = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _clearAllPendingFilters() {
    setState(() {
      _nameController.clear();
      _pendingName = null;
      _pendingStatus = 'All';
      _pendingPayment = 'All';
      _pendingVehicle = 'All';
      _pendingSortBy = 'Price (high to low)';
      _pendingDateRange = null;
      _pendingPriceRange = null;
      _hasPendingChanges = false;
    });
    widget.onClearFilters();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Summary Card
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: _isExpanded ? AppColors.primary : AppColors.grey300,
                  width: _isExpanded ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isExpanded ? AppColors.primary : Colors.black)
                        .withValues(alpha: _isExpanded ? 0.1 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.filtersAndSort,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeFiltersCount > 0
                              ? l10n.activeFilters(_activeFiltersCount)
                              : l10n.noActiveFilters,
                          style: TextStyle(
                            fontSize: 12,
                            color: _activeFiltersCount > 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: _activeFiltersCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_activeFiltersCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        '$_activeFiltersCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween(
                      begin: 0.0,
                      end: 0.5,
                    ).animate(_expandAnimation),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Filters with Max Height and Scroll
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildDriverSearchField(l10n),
                        _buildDivider(),
                        _buildDateRangeFilter(l10n),
                        _buildDivider(),
                        _buildPriceRangeFilter(l10n),
                        _buildDivider(),
                        _buildModernFilterChip(
                          icon: Icons.info_outline_rounded,
                          color: const Color(0xFF3B82F6),
                          label: l10n.statusLabel,
                          value: _pendingStatus,
                          items: ['All', 'Completed', 'Cancelled'],
                          onChanged: (value) {
                            setState(() {
                              _pendingStatus = value;
                              _hasPendingChanges = true;
                            });
                          },
                        ),
                        _buildDivider(),
                        _buildModernFilterChip(
                          icon: Icons.payment_rounded,
                          color: const Color(0xFF10B981),
                          label: l10n.paymentLabel,
                          value: _pendingPayment,
                          items: [
                            'All',
                            'Cash',
                            'Wallet',
                            'CreditCard',
                            'LoyaltyPoints',
                            'FreeRide',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _pendingPayment = value;
                              _hasPendingChanges = true;
                            });
                          },
                        ),
                        _buildDivider(),
                        _buildModernFilterChip(
                          icon: Icons.directions_car_rounded,
                          color: const Color(0xFF8B5CF6),
                          label: l10n.vehicleLabel,
                          value: _pendingVehicle,
                          items: [
                            'All',
                            'Voiture',
                          ], // Add more vehicle types as needed
                          onChanged: (value) {
                            setState(() {
                              _pendingVehicle = value;
                              _hasPendingChanges = true;
                            });
                          },
                        ),
                        _buildDivider(),
                        _buildModernFilterChip(
                          icon: Icons.sort_rounded,
                          color: const Color(0xFFF59E0B),
                          label: l10n.sortByLabel,
                          value: _pendingSortBy,
                          items: [
                            'Price (high to low)',
                            'Price (low to high)',
                            'Distance',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _pendingSortBy = value;
                              _hasPendingChanges = true;
                            });
                          },
                        ),

                        // Action Buttons
                        if (_hasPendingChanges || _activeFiltersCount > 0) ...[
                          _buildDivider(),
                          _buildActionButtons(l10n),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.grey200);
  }

  Widget _buildDriverSearchField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.searchDriver,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: l10n.driverNameHint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: () {
                        _nameController.clear();
                        setState(() {
                          _pendingName = null;
                          _hasPendingChanges = true;
                        });
                        HapticFeedback.lightImpact();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _pendingName = value.isEmpty ? null : value;
                _hasPendingChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(AppLocalizations l10n) {
    final hasDateRange = _pendingDateRange != null;
    final dateText = hasDateRange
        ? '${_formatDate(_pendingDateRange!.start)} - ${_formatDate(_pendingDateRange!.end)}'
        : l10n.selectPeriod;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          await _showCustomCalendarDialog(l10n);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF06B6D4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateRange,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasDateRange
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: hasDateRange
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDateRange)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _pendingDateRange = null;
                      _hasPendingChanges = true;
                    });
                    HapticFeedback.lightImpact();
                  },
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter(AppLocalizations l10n) {
    final hasPriceRange = _pendingPriceRange != null;
    final priceText = hasPriceRange
        ? '${_pendingPriceRange!.start.round()} - ${_pendingPriceRange!.end.round()} DH'
        : l10n.allPriceRanges;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: const Icon(
                  Icons.attach_money_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.priceRange,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasPriceRange
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: hasPriceRange
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasPriceRange)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _pendingPriceRange = null;
                      _hasPendingChanges = true;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
            ],
          ),
          if (hasPriceRange) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFEF4444),
                inactiveTrackColor: const Color(
                  0xFFEF4444,
                ).withValues(alpha: 0.2),
                thumbColor: const Color(0xFFEF4444),
                overlayColor: const Color(0xFFEF4444).withValues(alpha: 0.2),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: RangeSlider(
                values: _pendingPriceRange!,
                min: 0,
                max: 500,
                divisions: 50,
                labels: RangeLabels(
                  '${_pendingPriceRange!.start.round()} DH',
                  '${_pendingPriceRange!.end.round()} DH',
                ),
                onChanged: (values) {
                  setState(() {
                    _pendingPriceRange = values;
                    _hasPendingChanges = true;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
          if (!hasPriceRange)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _pendingPriceRange = const RangeValues(0, 500);
                      _hasPendingChanges = true;
                    });
                    HapticFeedback.lightImpact();
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: Text(l10n.addPriceFilter),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.grey300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFilterBottomSheet(
          icon: icon,
          color: color,
          label: label,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDisplayValue(value),
                      style: TextStyle(
                        fontSize: 13,
                        color: value != 'All' ? color : AppColors.textSecondary,
                        fontWeight: value != 'All'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Options List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 68),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == value;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: isSelected ? color : AppColors.grey300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: color, size: 20)
                          : null,
                    ),
                    title: Text(
                      _getDisplayValue(item),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      onChanged(item);
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_hasPendingChanges)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyAllFilters,
                icon: const Icon(Icons.check_circle, size: 20),
                label: Text(l10n.applyFilters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          if (_hasPendingChanges && _activeFiltersCount > 0)
            const SizedBox(height: 8),
          if (_activeFiltersCount > 0)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearAllPendingFilters,
                icon: Icon(
                  Icons.clear_all_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                label: Text(
                  l10n.resetAllFilters,
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCustomCalendarDialog(AppLocalizations l10n) async {
    DateTime? tempStartDate = _pendingDateRange?.start;
    DateTime? tempEndDate = _pendingDateRange?.end;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.selectPeriod,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Selection Display
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.startDate,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tempStartDate != null
                                        ? _formatDate(tempStartDate!)
                                        : '--/--/----',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: tempStartDate != null
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.endDate,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tempEndDate != null
                                        ? _formatDate(tempEndDate!)
                                        : '--/--/----',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: tempEndDate != null
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scrollable Calendar
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey200),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              currentDate: DateTime.now(),
                              onDateChanged: (date) {
                                HapticFeedback.selectionClick();
                                setDialogState(() {
                                  if (tempStartDate == null ||
                                      tempEndDate != null) {
                                    // Starting new selection
                                    tempStartDate = date;
                                    tempEndDate = null;
                                  } else if (date.isBefore(tempStartDate!)) {
                                    // Selected date is before start, make it the new start
                                    tempStartDate = date;
                                    tempEndDate = null;
                                  } else if (date.isAtSameMomentAs(
                                    tempStartDate!,
                                  )) {
                                    // Same date clicked, reset
                                    tempStartDate = null;
                                    tempEndDate = null;
                                  } else {
                                    // Valid end date
                                    tempEndDate = date;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: AppColors.grey300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                ),
                              ),
                              child: Text(
                                l10n.cancel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                                  (tempStartDate != null && tempEndDate != null)
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        _pendingDateRange = DateTimeRange(
                                          start: tempStartDate!,
                                          end: tempEndDate!,
                                        );
                                        _hasPendingChanges = true;
                                      });
                                      Navigator.pop(context);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusM,
                                  ),
                                ),
                              ),
                              child: Text(
                                l10n.apply,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getDisplayValue(String value) {
    final l10n = AppLocalizations.of(context)!;

    switch (value) {
      case 'All':
        return l10n.allStatus;
      case 'Completed':
        return l10n.completedStatus;
      case 'Cancelled':
        return l10n.cancelledStatus;
      case 'Cash':
        return l10n.cash;
      case 'Wallet':
        return l10n.walletPayment;
      case 'CreditCard':
        return l10n.creditCardPayment;
      case 'LoyaltyPoints':
        return l10n.loyaltyPointsPayment;
      case 'FreeRide':
        return l10n.freeRidePayment;
      case 'CAR':
      case 'Voiture':
        return l10n.carVehicle;
      case 'MOTORCYCLE':
      case 'Moto':
        return l10n.motorcycleVehicle;
      case 'TRUCK':
      case 'Camion':
        return l10n.truckVehicle;
      case 'Price (high to low)':
        return l10n.sortPriceHighToLow;
      case 'Price (low to high)':
        return l10n.sortPriceLowToHigh;
      case 'Distance':
        return l10n.distance;
      default:
        return value;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}