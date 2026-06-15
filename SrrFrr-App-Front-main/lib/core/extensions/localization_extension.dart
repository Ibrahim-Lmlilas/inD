import 'package:flutter/material.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}