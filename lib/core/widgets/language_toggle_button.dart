import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isFr = currentLocale.languageCode == 'fr';

    return TextButton.icon(
      onPressed: () {
        ref.read(localeProvider.notifier).toggleLocale();
      },
      icon: const Icon(Icons.language, color: Colors.white),
      label: Text(
        isFr ? 'FR' : 'TN',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
