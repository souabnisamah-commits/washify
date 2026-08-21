import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/app.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/firebase_options.dart';
import 'package:washify/core/utils/session_service.dart';
import 'package:washify/repositories/audit_repository.dart';
import 'package:washify/core/observers/audit_provider_observer.dart';
import 'package:washify/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('TRACE: WidgetsFlutterBinding initialized');
  
  try {
    print('TRACE: Calling Firebase.initializeApp');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('TRACE: Firebase initialized');
    
    // Étape 1 : Activation du mode hors-ligne pour un chargement instantané
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print('TRACE: Firestore offline persistence enabled');
  } catch (e) {
    debugPrint("Firebase initialization or persistence skipped/failed: $e");
  }

  print('TRACE: Calling SessionService.init');
  // Initialize session persistence (SharedPreferences / localStorage)
  await SessionService.init();
  print('TRACE: SessionService initialized');

  // Configuration du traqueur global d'erreurs
  final auditRepo = AuditRepository();

  // Masquer l'écran rouge d'erreur (Red Screen of Death) en production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        color: AppTheme.surfaceDark,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Une erreur technique est survenue.',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le problème a été signalé automatiquement à l\'administrateur.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    auditRepo.log(
      userId: SessionService.instance.getSavedUserId() ?? 'system',
      userName: 'Système',
      action: 'crash',
      module: 'system',
      severity: 'critical',
      description: details.exceptionAsString(),
      deviceInfo: {
        'platform': 'Web / Flutter',
      },
      newData: {
        'stackTrace': details.stack?.toString() ?? 'Aucun stacktrace',
      },
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    auditRepo.log(
      userId: SessionService.instance.getSavedUserId() ?? 'system',
      userName: 'Système',
      action: 'crash',
      module: 'system',
      severity: 'critical',
      description: error.toString(),
      deviceInfo: {
        'platform': 'Web / Flutter',
      },
      newData: {
        'stackTrace': stack?.toString() ?? 'Aucun stacktrace',
      },
    );
    return true; // Empêche l'application de crasher silencieusement
  };

  print('TRACE: Calling runApp');
  runApp(
    ProviderScope(
      observers: [AuditProviderObserver(auditRepo)],
      child: const WashifyInitializer(),
    ),
  );
}

class WashifyInitializer extends ConsumerWidget {
  const WashifyInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(appInitProvider);
    
    return initAsync.when(
      data: (_) => const WashifyApp(),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Démarrage de Washify...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text('Erreur de démarrage: $err'),
          ),
        ),
      ),
    );
  }
}
