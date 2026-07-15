import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/providers/station_provider.dart';

// Custom colors based on the provided HTML
const Color _cBackground = Color(0xFFF8F9FF);
const Color _cPrimary = Color(0xFF003EC7);
const Color _cOnSurface = Color(0xFF0D1C2F);
const Color _cOnSurfaceVariant = Color(0xFF434656);
const Color _cOutlineVariant = Color(0xFFC3C5D9);
const Color _cPrimaryContainer = Color(0xFF0052FF);
const Color _cOnPrimaryContainer = Color(0xFFDFE3FF);
const Color _cSecondaryContainer = Color(0xFFDAE2FD);
const Color _cOnSecondaryContainer = Color(0xFF5C647A);
const Color _cSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color _cSurfaceContainer = Color(0xFFE6EEFF);
const Color _cOutline = Color(0xFF737688);

class StationFormScreen extends ConsumerStatefulWidget {
  final Station? station;
  const StationFormScreen({super.key, this.station});

  @override
  ConsumerState<StationFormScreen> createState() => _StationFormScreenState();
}

class _StationFormScreenState extends ConsumerState<StationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _matriculeController;
  late final TextEditingController _phoneController;
  
  late final TextEditingController _gerantNameController;
  late final TextEditingController _emailController;
  
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  
  DateTime? _expirationDate;
  late final TextEditingController _gracePeriodController;
  
  bool _isActive = true;
  bool _isSaving = false;

  bool get _isEditing => widget.station != null;

  @override
  void initState() {
    super.initState();
    final s = widget.station;
    _nameController = TextEditingController(text: s?.name ?? '');
    _matriculeController = TextEditingController(text: s?.matriculeFiscale ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    
    _gerantNameController = TextEditingController(text: s?.gerantName ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    
    _latController = TextEditingController(text: s != null ? s.latitude.toString() : '');
    _lngController = TextEditingController(text: s != null ? s.longitude.toString() : '');
    
    _expirationDate = s?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
    _gracePeriodController = TextEditingController(text: '7');
    
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matriculeController.dispose();
    _phoneController.dispose();
    _gerantNameController.dispose();
    _emailController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _gracePeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  Future<void> _saveStation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner une date d'expiration")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(stationRepositoryProvider);
      final stationToSave = Station(
        id: _isEditing ? widget.station!.id : '',
        tenantId: _isEditing ? widget.station!.tenantId : '',
        name: _nameController.text.trim(),
        gerantName: _gerantNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        matriculeFiscale: _matriculeController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()) ?? 0.0,
        longitude: double.tryParse(_lngController.text.trim()) ?? 0.0,
        logoUrl: _isEditing ? widget.station!.logoUrl : '',
        licence: _isActive ? LicenceStatus.active : LicenceStatus.suspended,
        subscriptionDate: _isEditing ? widget.station!.subscriptionDate : DateTime.now(),
        expiryDate: _expirationDate,
        gracePeriodDays: int.tryParse(_gracePeriodController.text.trim()) ?? 7,
        address: _isEditing ? widget.station!.address : '',
        city: _isEditing ? widget.station!.city : '',
        isActive: true, // Always true unless deleted
        createdAt: _isEditing ? widget.station!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await repo.updateStation(stationToSave);
      } else {
        await repo.createStation(stationToSave);
      }
      
      ref.invalidate(stationsStreamProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Station modifiée avec succès' : 'Station créée avec succès')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: TextStyle(color: _cOutline, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _cOutlineVariant, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _cPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _cOnSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        padding: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _cOutlineVariant)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _cPrimary, size: 24),
            SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: _cOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColorStyle = TextStyle(color: _cOnSurface, fontSize: 16); // Fix for dark mode invisible text
    
    return Scaffold(
      backgroundColor: _cBackground,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              backgroundColor: _cBackground.withValues(alpha: 0.8),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: _cOutlineVariant, height: 1),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: _cPrimary),
                onPressed: () => context.pop(),
                splashRadius: 24,
              ),
              title: Text(
                _isEditing ? 'Modifier la Station' : 'Créer une Station',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _cPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _cPrimaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'AK',
                        style: TextStyle(
                          color: _cOnPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 100),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upload Logo Section
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: _cSurfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _cOutlineVariant,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _cSurfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_a_photo, color: _cOutline, size: 36),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Logo de la Station',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _cOnSurfaceVariant,
                            ),
                          ),
                          Text(
                            "PNG, JPG jusqu'à 5Mo",
                            style: TextStyle(fontSize: 12, color: _cOutline),
                          ),
                          SizedBox(height: 12),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: _cSecondaryContainer,
                              foregroundColor: _cOnSecondaryContainer,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'SÉLECTIONNER',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // 1. Informations Station
                    _buildSectionHeader(Icons.store, 'Informations Station'),
                    _buildLabel('Nom de la Station'),
                    TextFormField(
                      controller: _nameController,
                      style: textColorStyle,
                      decoration: _inputDecoration('Ex: Station North Bay Central'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Matricule Fiscale'),
                              TextFormField(
                                controller: _matriculeController,
                                style: textColorStyle,
                                decoration: _inputDecoration('1234567/A/M/000'),
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Téléphone'),
                              TextFormField(
                                controller: _phoneController,
                                style: textColorStyle,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration('+216 -- --- ---'),
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // 2. Gérant
                    _buildSectionHeader(Icons.manage_accounts, 'Gérant'),
                    _buildLabel('Nom Complet du Gérant'),
                    TextFormField(
                      controller: _gerantNameController,
                      style: textColorStyle,
                      decoration: _inputDecoration('Nom et Prénom'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    SizedBox(height: 16),
                    _buildLabel('Email Professionnel'),
                    TextFormField(
                      controller: _emailController,
                      style: textColorStyle,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('gerant@washify.tn'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    SizedBox(height: 32),

                    // 3. Localisation
                    _buildSectionHeader(Icons.location_on, 'Localisation'),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: _cSurfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cOutlineVariant, width: 1.5),
                      ),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: _cPrimary,
                            elevation: 4,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          icon: Icon(Icons.map),
                          label: Text(
                            'OUVRIR LA CARTE',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: _cOnSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Latitude'),
                              TextFormField(
                                controller: _latController,
                                style: textColorStyle,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('36.8065'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Longitude'),
                              TextFormField(
                                controller: _lngController,
                                style: textColorStyle,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('10.1815'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // 4. Licence & Paramètres
                    _buildSectionHeader(Icons.admin_panel_settings, 'Licence & Paramètres'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Date d'Expiration"),
                              InkWell(
                                onTap: _selectDate,
                                child: IgnorePointer(
                                  child: TextFormField(
                                    key: ValueKey(_expirationDate),
                                    style: textColorStyle,
                                    initialValue: _expirationDate != null
                                        ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                                        : '',
                                    decoration: _inputDecoration('Sélectionner'),
                                    validator: (_) => _expirationDate == null ? 'Requis' : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Période de Grâce (Jours)'),
                              TextFormField(
                                controller: _gracePeriodController,
                                style: textColorStyle,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('7'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cSurfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cOutlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statut Initial',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _cOnSurface,
                                ),
                              ),
                              Text(
                                'Activer la station immédiatement',
                                style: TextStyle(fontSize: 12, color: _cOnSurfaceVariant.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            activeThumbColor: _cPrimary,
                            activeTrackColor: _cSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Bottom Action
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveStation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cPrimaryContainer,
                        foregroundColor: _cOnPrimaryContainer,
                        minimumSize: const Size.fromHeight(48),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: _isSaving
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(_isEditing ? Icons.save : Icons.add_circle),
                      label: Text(
                        _isSaving ? 'SAUVEGARDE...' : (_isEditing ? 'MODIFIER LA STATION' : 'CRÉER LA STATION'),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
