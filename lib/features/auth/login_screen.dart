import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/widgets/color_animated_title.dart';
import 'package:washify/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(currentUserProvider.notifier).login(
            _phoneController.text.trim(),
            _pinController.text.trim(),
          );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _errorMessage = 'Numéro de téléphone ou PIN incorrect';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.toString().contains('station_suspended')) {
          _errorMessage = 'Votre station a été suspendue. Veuillez contacter l\'administrateur.';
        } else {
          _errorMessage = 'Une erreur est survenue lors de la connexion';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida/AP1WRLtqWfN4pCMrX6oqUWpIK46fa_LE9EqOXCkNv-6dCGi5NRgaY_wuU_G164qYBOjoLytJpHKrVC9Yi140cZ2FsPJVJz9dhfsKowNR2OOm6xLRRN4A4cZ4-6eYEHWXIN11_Q7u2RP9YIOPXx6peTfnpZGrfEibn7wOs31_ayU8ibOJDUCukU72vGXgwv6KVRULsWFvSe1xP-YMIcBfZM00TDaisLtsFQTlsVHfL6ilylWUPyth1vwqzIza4w',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.surfaceDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Header
                    Container(
                      width: 112,
                      height: 112,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/souteqsa_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    ColorAnimatedTitle(
                      text: 'Washify',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    // Gouttelette d'eau élégante
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.accentCyan],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Gestion intelligente de vos stations de lavage',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFCBD5E1), // slate-300
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 12),
                    // Removed 'CREATED BY SOUTEQSA' row
                    
                    SizedBox(height: 48),

                    // Connection Form (Glass Panel)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.65), // slate-900 / 65%
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 10)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Connexion',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF1F5F9), // slate-100
                                    ),
                                  ),
                                  SizedBox(height: 32),

                                  // Phone Input
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Numéro de téléphone'.tr,
                                      hintStyle: TextStyle(color: Color(0xFF94A3B8)), // slate-400
                                      prefixIcon: Icon(Icons.smartphone, color: Color(0xFF94A3B8)),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.05),
                                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                                      ),
                                    ),
                                    validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                                  ),
                                  SizedBox(height: 24),

                                  // PIN Input
                                  TextFormField(
                                    controller: _pinController,
                                    obscureText: true,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Code PIN'.tr,
                                      hintStyle: TextStyle(color: Color(0xFF94A3B8)), // slate-400
                                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.05),
                                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF00C2FF)),
                                      ),
                                    ),
                                    validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                                  ),
                                  SizedBox(height: 24),

                                  if (_errorMessage != null) ...[
                                    Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 14), // red-500
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                  ],

                                  // Submit Button
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00C2FF), Color(0xFF0052FF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00C2FF).withValues(alpha: 0.3),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : Text(
                                              'Se connecter',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 48),

                    // Footer
                    RichText(
                      text: const TextSpan(
                        text: 'Created By ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sou',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Te',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                          TextSpan(
                            text: 'Q',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                          ),
                          TextSpan(
                            text: 'Sa',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
