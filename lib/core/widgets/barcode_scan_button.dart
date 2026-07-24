import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:washify/core/theme/app_theme.dart';

/// Widget réutilisable pour scanner un code-barres via la caméra.
/// Affiche un bouton avec icône caméra/scanner.
/// 
/// Usage :
/// ```dart
/// BarcodeScanButton(
///   onScanned: (barcode) {
///     // Utiliser le code-barres scanné
///     controller.text = barcode;
///   },
/// )
/// ```
class BarcodeScanButton extends StatelessWidget {
  final void Function(String barcode) onScanned;
  final String tooltip;
  final double? iconSize;
  final Color? iconColor;

  const BarcodeScanButton({
    super.key,
    required this.onScanned,
    this.tooltip = 'Scanner le code-barres',
    this.iconSize,
    this.iconColor,
  });

  Future<void> _scan(BuildContext context) async {
    try {
      final result = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Scanner le code-barres',
          centerTitle: true,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 500,
        cameraFace: CameraFace.back,
        scanFormat: ScanFormat.ALL_FORMATS,
      );

      if (result is String && result != '-1' && result.isNotEmpty) {
        onScanned(result);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur du scanner (Permissions refusées ou caméra non disponible) : $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _scan(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.15),
                  AppTheme.accentCyan.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppTheme.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.qr_code_scanner_rounded,
              size: iconSize ?? 24,
              color: iconColor ?? AppTheme.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

/// Version inline pour les suffixIcon de TextFormField
class BarcodeScanIcon extends StatelessWidget {
  final void Function(String barcode) onScanned;

  const BarcodeScanIcon({
    super.key,
    required this.onScanned,
  });

  Future<void> _scan(BuildContext context) async {
    try {
      final result = await SimpleBarcodeScanner.scanBarcode(
        context,
        barcodeAppBar: const BarcodeAppBar(
          appBarTitle: 'Scanner le code-barres',
          centerTitle: true,
          enableBackButton: true,
          backButtonIcon: Icon(Icons.arrow_back_ios),
        ),
        isShowFlashIcon: true,
        delayMillis: 500,
        cameraFace: CameraFace.back,
        scanFormat: ScanFormat.ALL_FORMATS,
      );

      if (result is String && result != '-1' && result.isNotEmpty) {
        onScanned(result);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur du scanner : $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner_rounded),
      color: AppTheme.primaryBlue,
      tooltip: 'Scanner le code-barres',
      onPressed: () => _scan(context),
    );
  }
}
