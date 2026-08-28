import 'package:washify/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/config/router/app_router.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/providers/auth_provider.dart';

class WashifyApp extends ConsumerWidget {
  const WashifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    // Listen to real-time user document changes to enforce forced logouts
    ref.listen(userRealtimeProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        if (next.value!.forceLogout) {
          ref.read(currentUserProvider.notifier).logout();
        }
      }
    });

    return MaterialApp.router(
      title: 'Washify',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      locale: locale,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('ar', 'TN'),
        Locale('ar'),
      ],
    );
  }
}
