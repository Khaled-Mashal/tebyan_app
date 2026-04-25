import 'package:flutter/material.dart';

import 'localization/app_localizations.dart';
import 'navigation/app_router.dart';
import 'theme/raqeem_theme.dart';

class RaqeemApp extends StatelessWidget {
  const RaqeemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رقيم',
      debugShowCheckedModeBanner: false,
      theme: RaqeemTheme.light(),
      darkTheme: RaqeemTheme.night(),
      locale: AppLocalizations.defaultLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: AppLocalizations.resolveLocale,
      initialRoute: AppRouter.home,
      routes: AppRouter.routes,
    );
  }
}
