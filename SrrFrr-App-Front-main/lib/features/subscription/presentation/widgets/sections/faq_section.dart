// FAQ Section Widget
// lib/features/subscription/presentation/widgets/subscription_sections/faq_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srrfrr_app_front/core/utils/responsive_utils.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class FAQSection extends StatelessWidget {
  final double padding;

  const FAQSection({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: ResponsiveUtils.getResponsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              l10n!.faqTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _FAQItem(
                  question: l10n.canChangeSubscription,
                  answer: l10n.changeSubscriptionAnswer,
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _FAQItem(
                  question: l10n.exceedLimitQuestion,
                  answer: l10n.exceedLimitAnswer,
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _FAQItem(
                  question: l10n.howRenewalWorks,
                  answer: l10n.renewalAnswer,
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _FAQItem(
                  question: l10n.canGetRefund,
                  answer: l10n.refundAnswer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isExpanded = !_isExpanded);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.remove : Icons.add,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}