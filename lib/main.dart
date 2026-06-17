import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:washify/app.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization skipped or done via platform: $e");
  }

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          final initAsync = ref.watch(authInitProvider);
          return initAsync.when(
            data: (_) => const WashifyApp(),
            loading: () => const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
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
        },
      ),
    ),
  );
}
