import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/core/utils/hash_util.dart';

// Tailwind Colors
const _cPrimary = Color(0xFF0052FF);
const _cWhite = Colors.white;
const _cSlate50 = Color(0xFFF8FAFC);
const _cSlate100 = Color(0xFFF1F5F9);
const _cSlate400 = Color(0xFF94A3B8);
const _cSlate500 = Color(0xFF64748B);
const _cSlate800 = Color(0xFF1E293B);
const _cSlate900 = Color(0xFF0F172A);
const _cRed500 = Color(0xFFEF4444);

class ManageProfilesDialog extends ConsumerStatefulWidget {
  final Station station;

  const ManageProfilesDialog({super.key, required this.station});

  @override
  ConsumerState<ManageProfilesDialog> createState() => _ManageProfilesDialogState();
}

class _ManageProfilesDialogState extends ConsumerState<ManageProfilesDialog> {
  AppUser? _editingUser;
  bool _isFormVisible = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  List<UserRole> _selectedRoles = [UserRole.ouvrier];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _openForm([AppUser? user]) {
    setState(() {
      _editingUser = user;
      _isFormVisible = true;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _pinController.text = ''; // Leave blank for edit, unless they want to change
        
        // Parse roles
        if (user.roles.isNotEmpty) {
          _selectedRoles = user.roles.map((r) {
            final str = r.toString().split('.').last.toLowerCase();
            if (str == 'gerant' || str == 'patron') return UserRole.patron;
            if (str == 'caissier') return UserRole.caissier;
            if (str == 'admin') return UserRole.admin;
            return UserRole.ouvrier;
          }).toList();
        } else {
          _selectedRoles = [UserRole.ouvrier];
        }
      } else {
        _nameController.clear();
        _phoneController.clear();
        _pinController.clear();
        _selectedRoles = [UserRole.ouvrier];
      }
    });
  }

  void _closeForm() {
    setState(() {
      _isFormVisible = false;
      _editingUser = null;
    });
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un rôle'.tr)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      
      if (_editingUser != null) {
        // Edit
        var updatedUser = _editingUser!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          roles: _selectedRoles,
          updatedAt: DateTime.now(),
        );

        if (_pinController.text.isNotEmpty) {
          updatedUser = updatedUser.copyWith(pinHash: hashPin(_pinController.text.trim()));
        }

        await authRepo.updateUser(updatedUser);
      } else {
        // Create
        final newUser = AppUser(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          tenantId: widget.station.id,
          phone: _phoneController.text.trim(),
          pinHash: hashPin(_pinController.text.trim()),
          name: _nameController.text.trim(),
          roles: _selectedRoles,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await authRepo.createUser(newUser);
      }

      ref.invalidate(stationUsersProvider(widget.station.id));
      _closeForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil enregistré avec succès'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'.tr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le profil'.tr),
        content: Text('Voulez-vous vraiment supprimer ${user.name} ?'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Annuler'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _cRed500),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(authRepositoryProvider).deactivateUser(user.id);
        ref.invalidate(stationUsersProvider(widget.station.id));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'.tr)),
          );
        }
      }
    }
  }
  
  Widget _buildRoleCheckbox(UserRole role, String label) {
    return CheckboxListTile(
      title: Text(label, style: TextStyle(color: _cSlate800, fontSize: 14)),
      value: _selectedRoles.contains(role),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            if (!_selectedRoles.contains(role)) {
              _selectedRoles.add(role);
            }
          } else {
            _selectedRoles.remove(role);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildForm() {
    const textStyle = TextStyle(color: _cSlate900, fontSize: 15);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cSlate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cSlate100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editingUser == null ? 'Nouveau Profil' : 'Modifier le Profil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cSlate800),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: textStyle,
              decoration: InputDecoration(labelText: 'Nom complet'.tr, filled: true, fillColor: _cWhite),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              style: textStyle,
              decoration: InputDecoration(labelText: 'Téléphone'.tr, filled: true, fillColor: _cWhite),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _pinController,
              style: textStyle,
              decoration: InputDecoration(
                labelText: _editingUser == null ? 'Code PIN (4 chiffres)' : 'Nouveau Code PIN (optionnel)', 
                filled: true, 
                fillColor: _cWhite
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (v) {
                if (_editingUser == null && (v == null || v.isEmpty)) return 'Requis pour un nouveau profil';
                if (v != null && v.isNotEmpty && v.length < 4) return '4 chiffres minimum';
                return null;
              },
            ),
            SizedBox(height: 16),
            Text('Rôles :', style: TextStyle(fontWeight: FontWeight.bold, color: _cSlate800)),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _cWhite,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildRoleCheckbox(UserRole.patron, 'Gérant / Patron'),
                  _buildRoleCheckbox(UserRole.caissier, 'Caissier'),
                  _buildRoleCheckbox(UserRole.ouvrier, 'Ouvrier (Laveur)'),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _closeForm,
                  child: Text('Annuler'.tr),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveUser,
                  style: ElevatedButton.styleFrom(backgroundColor: _cPrimary),
                  child: _isLoading 
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Enregistrer', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(stationUsersProvider(widget.station.id));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _cSlate100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gérer les Profils',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cSlate900),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: _cSlate500),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isFormVisible) 
                      _buildForm()
                    else ...[
                      // Add Button
                      ElevatedButton.icon(
                        onPressed: () => _openForm(),
                        icon: Icon(Icons.add, size: 18, color: Colors.white),
                        label: Text('Ajouter un profil', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _cPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Users List
                      usersAsync.when(
                        data: (users) {
                          if (users.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('Aucun profil n\'a été ajouté.', style: TextStyle(color: _cSlate500)),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final formattedRoles = user.roles.map((r) {
                                final roleName = r.toString().split('.').last.toLowerCase();
                                if (roleName == 'gerant') return 'Gérant';
                                if (roleName == 'ouvrier') return 'Ouvrier';
                                return roleName.toUpperCase();
                              }).join(', ');
                              
                              final isGerant = user.roles.any((r) => r.toString().contains('gerant'));

                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _cWhite,
                                  border: Border.all(color: _cSlate100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isGerant ? _cPrimary.withValues(alpha: 0.1) : _cSlate100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isGerant ? Icons.manage_accounts : Icons.person,
                                        size: 20,
                                        color: isGerant ? _cPrimary : _cSlate500,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _cSlate800),
                                          ),
                                          Text(
                                            '$formattedRoles • ${user.phone}',
                                            style: TextStyle(fontSize: 12, color: _cSlate500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, size: 20, color: _cSlate400),
                                      onPressed: () => _openForm(user),
                                      tooltip: 'Modifier'.tr,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, size: 20, color: _cRed500),
                                      onPressed: () => _deleteUser(user),
                                      tooltip: 'Supprimer'.tr,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => Center(child: CircularProgressIndicator()),
                        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
