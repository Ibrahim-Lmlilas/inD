// FAQ Data Provider
// Static FAQ data - can be moved to backend/CMS later

import 'package:srrfrr_app_front/features/support/data/models/support_models.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

class FaqDataProvider {
  /// Get FAQ sections with translations
  /// Pass AppLocalizations to get localized content
  static List<FaqSection> getFaqSections(AppLocalizations l10n) {
    return [
      FaqSection(
        title: l10n.faqAccountTitle,
        icon: 'person',
        items: [
          FaqItem(
            id: 'account_1',
            question: l10n.faqAccount1Q,
            answer: l10n.faqAccount1A,
          ),
          FaqItem(
            id: 'account_2',
            question: l10n.faqAccount2Q,
            answer: l10n.faqAccount2A,
          ),
          FaqItem(
            id: 'account_3',
            question: l10n.faqAccount3Q,
            answer: l10n.faqAccount3A,
          ),
        ],
      ),
      FaqSection(
        title: l10n.faqBookingTitle,
        icon: 'directions_car',
        items: [
          FaqItem(
            id: 'booking_1',
            question: l10n.faqBooking1Q,
            answer: l10n.faqBooking1A,
          ),
          FaqItem(
            id: 'booking_2',
            question: l10n.faqBooking2Q,
            answer: l10n.faqBooking2A,
          ),
          FaqItem(
            id: 'booking_3',
            question: l10n.faqBooking3Q,
            answer: l10n.faqBooking3A,
          ),
        ],
      ),
      FaqSection(
        title: l10n.faqPaymentTitle,
        icon: 'payment',
        items: [
          FaqItem(
            id: 'payment_1',
            question: l10n.faqPayment1Q,
            answer: l10n.faqPayment1A,
          ),
          FaqItem(
            id: 'payment_2',
            question: l10n.faqPayment2Q,
            answer: l10n.faqPayment2A,
          ),
          FaqItem(
            id: 'payment_3',
            question: l10n.faqPayment3Q,
            answer: l10n.faqPayment3A,
          ),
        ],
      ),
      FaqSection(
        title: l10n.faqSafetyTitle,
        icon: 'security',
        items: [
          FaqItem(
            id: 'safety_1',
            question: l10n.faqSafety1Q,
            answer: l10n.faqSafety1A,
          ),
          FaqItem(
            id: 'safety_2',
            question: l10n.faqSafety2Q,
            answer: l10n.faqSafety2A,
          ),
          FaqItem(
            id: 'safety_3',
            question: l10n.faqSafety3Q,
            answer: l10n.faqSafety3A,
          ),
        ],
      ),
      FaqSection(
        title: l10n.faqDriverTitle,
        icon: 'how_to_reg',
        items: [
          FaqItem(
            id: 'driver_1',
            question: l10n.faqDriver1Q,
            answer: l10n.faqDriver1A,
          ),
          FaqItem(
            id: 'driver_2',
            question: l10n.faqDriver2Q,
            answer: l10n.faqDriver2A,
          ),
          FaqItem(
            id: 'driver_3',
            question: l10n.faqDriver3Q,
            answer: l10n.faqDriver3A,
          ),
          FaqItem(
            id: 'driver_4',
            question: l10n.faqDriver4Q,
            answer: l10n.faqDriver4A,
          ),
        ],
      ),
      FaqSection(
        title: l10n.faqTechTitle,
        icon: 'build',
        items: [
          FaqItem(
            id: 'tech_1',
            question: l10n.faqTech1Q,
            answer: l10n.faqTech1A,
          ),
          FaqItem(
            id: 'tech_2',
            question: l10n.faqTech2Q,
            answer: l10n.faqTech2A,
          ),
          FaqItem(
            id: 'tech_3',
            question: l10n.faqTech3Q,
            answer: l10n.faqTech3A,
          ),
        ],
      ),
    ];
  }

  /// Search FAQ with localized content
  static List<FaqSection> searchFaq(String query, AppLocalizations l10n) {
    final lowerQuery = query.toLowerCase();
    final sections = getFaqSections(l10n);

    return sections
        .map((section) {
          final filteredItems = section.items.where((item) {
            return item.question.toLowerCase().contains(lowerQuery) ||
                item.answer.toLowerCase().contains(lowerQuery);
          }).toList();

          return FaqSection(
            title: section.title,
            icon: section.icon,
            items: filteredItems,
          );
        })
        .where((section) => section.items.isNotEmpty)
        .toList();
  }
}