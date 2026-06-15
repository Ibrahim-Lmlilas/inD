import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:srrfrr_app_front/l10n/app_localizations.dart';
import 'package:srrfrr_app_front/core/themes/app_theme.dart';
import 'package:srrfrr_app_front/core/utils/notification_listener.dart';
import 'package:srrfrr_app_front/shared/providers/user_provider.dart';
import 'package:srrfrr_app_front/features/account_settings/presentation/providers/language_provider.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, LanguageProvider>(
      builder: (context, userProvider, languageProvider, _) {
        final isLadiesInterface =
            userProvider.currentUser?.shouldUseLadiesInterface ?? false;

        return MaterialApp.router(
          title: 'SRR FRR',
          debugShowCheckedModeBanner: false,

          // Localization delegates
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Supported locales
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
            Locale('ar'), // Arabic
          ],

          // Use saved language or system locale with fallback to English
          locale: languageProvider.locale, // null = system, or specific locale
          localeResolutionCallback: (locale, supportedLocales) {
            // If user has set a language preference, use it
            if (languageProvider.locale != null) {
              return languageProvider.locale;
            }

            // Otherwise, try to match system locale
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            
            // Default to English if system locale not supported
            return const Locale('en');
          },

          theme: AppTheme.getLightTheme(isLadiesInterface: isLadiesInterface),
          routerConfig: AppRoutes.router,

          builder: (context, child) {
            final locale = Localizations.localeOf(context);

            return Directionality(
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: MediaQuery.withClampedTextScaling(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.3,
                child: AppNotificationListener(
                  child: child ?? const SizedBox(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}