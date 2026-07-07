import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/app.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/firebase_options.dart';
import 'package:washify/core/utils/session_service.dart';

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

  print('TRACE: Calling runApp');
  runApp(
    const ProviderScope(
      child: WashifyInitializer(),
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
