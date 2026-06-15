// Help & FAQ Page
//
// Modern UI matching wallet page style:
// - Clean tab navigation with rounded container
// - Proper spacing and shadows
// - Consistent color scheme

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/core/constants/app_colors.dart';
import 'package:srrfrr_app_front/core/constants/app_sizes.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/features/support/data/models/support_models.dart';
import 'package:srrfrr_app_front/features/support/data/repositories/support_repository.dart';
import 'package:srrfrr_app_front/features/support/data/services/support_service.dart';
import 'package:srrfrr_app_front/features/support/presentation/providers/faq_data_provider.dart';
import 'package:srrfrr_app_front/features/support/presentation/widgets/faq_section_widget.dart';
import 'package:srrfrr_app_front/features/support/presentation/widgets/general_reclamation_form.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class HelpFaqPage extends StatefulWidget {
  final String source;

  const HelpFaqPage({super.key, required this.source});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedFaqId;
  late TabController _tabController;
  SupportRepository? _supportRepository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize repository once dependencies are available
    if (_supportRepository == null) {
      final supportService = context.read<SupportService>();
      _supportRepository = SupportRepository(supportService);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  void _toggleFaqExpansion(String faqId) {
    setState(() => _expandedFaqId = _expandedFaqId == faqId ? null : faqId);
  }

  List<FaqSection> _getFilteredFaqSections(AppLocalizations l10n) {
    if (_searchQuery.isEmpty) {
      return FaqDataProvider.getFaqSections(l10n);
    }
    return FaqDataProvider.searchFaq(_searchQuery, l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          l10n.supportAndFaq,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF64748B),
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.faq),
                Tab(text: l10n.contact),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqContent(padding, l10n),
          _buildContactContent(padding, l10n),
        ],
      ),
    );
  }

  Widget _buildFaqContent(double padding, AppLocalizations l10n) {
    final filteredSections = _getFilteredFaqSections(l10n);

    return Column(
      children: [
        SizedBox(height: padding),
        _buildSearchBar(padding, l10n),
        SizedBox(height: padding * 1.5),
        Expanded(
          child: filteredSections.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _expandedFaqId = null;
                    });
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    itemCount: filteredSections.length,
                    itemBuilder: (context, index) {
                      final section = filteredSections[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: padding),
                        child: FaqSectionWidget(
                          section: section,
                          expandedFaqId: _expandedFaqId,
                          onToggleExpansion: _toggleFaqExpansion,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(double padding, AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: TextField(
        controller: _searchController,
        onChanged: _handleSearch,
        decoration: InputDecoration(
          hintText: l10n.searchInFaq,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
        ),
      ),
    );
  }

  Widget _buildContactContent(double padding, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: padding),
            _buildContactInfoCard(l10n),
            SizedBox(height: padding * 1.5),
            _buildReclamationFormCard(l10n),
            SizedBox(height: padding * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.contact_support,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.contactUs,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.ourTeamIsHereToHelp,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ContactInfoItem(
              icon: Icons.email,
              label: l10n.email,
              value: 'support@srrfrr.com',
            ),
            const SizedBox(height: 16),
            _ContactInfoItem(
              icon: Icons.phone,
              label: l10n.phoneLabel,
              value: '+212 5XX-XXXXXX',
            ),
            const SizedBox(height: 16),
            _ContactInfoItem(
              icon: Icons.schedule,
              label: l10n.hours,
              value: l10n.businessHours,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReclamationFormCard(AppLocalizations l10n) {
    // Don't render until repository is initialized
    if (_supportRepository == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sendComplaint,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.describeYourProblem,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            GeneralReclamationForm(repository: _supportRepository!),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noResultsFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryOtherKeywords,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}