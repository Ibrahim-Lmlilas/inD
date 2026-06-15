// Support Repository
// Handles data operations for support and engagement features

import 'package:srrfrr_app_front/core/utils/log_utils.dart';
import 'package:srrfrr_app_front/features/support/data/models/support_models.dart';
import 'package:srrfrr_app_front/features/support/data/services/support_service.dart';

class SupportRepository {
  final SupportService _supportService;

  SupportRepository(this._supportService);

  // Send a report/reclamation
  Future<Report> sendReport(Report report) async {
    try {
      final response = await _supportService.sendReport(
        content: report.content,
        rideId: report.rideId!,
        categorie: report.category,
      );

      if (response['success'] == true) {
        return Report(
          content: report.content,
          category: report.category,
          rideId: report.rideId,
        );
      } else {
        final errorMsg =
            response['message'] ?? 'Erreur lors de l\'envoi de la réclamation';
        throw SupportException(errorMsg);
      }
    } catch (e, stackTrace) {
      logError('[SupportRepository]', 'Failed to send report - $e');
      logError('[SupportRepository]', 'Stack trace: $stackTrace');

      if (e is SupportException) rethrow;
      throw SupportException('Erreur lors de l\'envoi de la réclamation');
    }
  }
}

class SupportException implements Exception {
  final String message;
  final int? statusCode;

  SupportException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
