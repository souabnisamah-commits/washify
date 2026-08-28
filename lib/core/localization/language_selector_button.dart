import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';

class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar' || currentLocale.languageCode == 'tn';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: InkWell(
        onTap: () {
          ref.read(localeProvider.notifier).toggleLocale();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isArabic
                ? AppTheme.accentCyan.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isArabic ? AppTheme.accentCyan : Colors.white54,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? '🇹🇳' : '🇫🇷',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                isArabic ? 'العربية' : 'Français',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
