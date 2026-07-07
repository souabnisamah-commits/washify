import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/core/utils/hash_util.dart';
import 'package:uuid/uuid.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _commissionController = TextEditingController();
  final _extraHourController = TextEditingController();
  List<UserRole> _editSelectedRoles = [UserRole.ouvrier];
  
  // Fields for adding employee
  final _addFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  List<UserRole> _selectedRoles = [UserRole.ouvrier];
  bool _isSaving = false;

  @override
  void dispose() {
    _salaryController.dispose();
    _commissionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _extraHourController.dispose();
    super.dispose();
  }

  Future<void> _updateRates(Employee employee) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(employeeRepositoryProvider);
      final updated = employee.copyWith(
        salaireMensuel: employee.contrat == ContractType.mensuel ? double.parse(_salaryController.text) : employee.salaireMensuel,
        valeurJournaliere: employee.contrat == ContractType.journalier ? double.parse(_salaryController.text) : employee.valeurJournaliere,
        commissionRate: double.tryParse(_commissionController.text) ?? 0.0,
        extraHourRate: double.tryParse(_extraHourController.text) ?? 0.0,
        roles: _editSelectedRoles.isEmpty ? [UserRole.ouvrier] : _editSelectedRoles,
        updatedAt: DateTime.now(),
      );

      await repo.updateEmployee(updated);

      final selectedStation = ref.read(selectedStationProvider);
      if (selectedStation != null) {
        ref.invalidate(employeesStreamProvider(selectedStation.id));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarifs de l\'employé mis à jour')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showEditRatesDialog(Employee employee) {
    _salaryController.text = employee.salary.toString();
    _commissionController.text = employee.commissionRate.toString();
    _extraHourController.text = employee.extraHourRate.toString();
    _editSelectedRoles = List.from(employee.roles);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Paramètres: ${employee.name}'.tr),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        children: UserRole.values.where((r) => r != UserRole.admin).map((r) {
                          return FilterChip(
                            label: Text(r.name.toUpperCase()),
                            selected: _editSelectedRoles.contains(r),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  _editSelectedRoles.add(r);
                                } else {
                                  _editSelectedRoles.remove(r);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Valeur Journalière (DT)'.tr,
                        ),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Montant invalide' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _extraHourController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Taux Heure Supplémentaire (DT/h)'.tr,
                        ),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Montant invalide' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _commissionController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Commission sur ticket (%)'.tr,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text('Confirmer la désactivation'.tr),
                        content: Text('Voulez-vous vraiment désactiver/supprimer cet employé ?'.tr),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Non'.tr)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                            onPressed: () => Navigator.pop(c, true), 
                            child: Text('Oui', style: TextStyle(color: Colors.white))
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(employeeRepositoryProvider).deleteEmployee(employee.id);
                      await ref.read(authRepositoryProvider).deactivateUser(employee.userId);
                      ref.invalidate(employeesStreamProvider(employee.tenantId));
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
                  child: Text('Supprimer'.tr),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _updateRates(employee),
                  child: _isSaving
                      ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Sauvegarder'.tr),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _createEmployee() async {
    if (!_addFormKey.currentState!.validate()) return;

    final selectedStation = ref.read(selectedStationProvider);
    if (selectedStation == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final phone = _phoneController.text.trim();

      final existingUser = await authRepo.getUserByPhone(phone);
      if (existingUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Un utilisateur avec ce numéro existe déjà'.tr)),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final now = DateTime.now();
      final newUser = AppUser(
        id: const Uuid().v4(),
        tenantId: selectedStation.id,
        phone: phone,
        pinHash: hashPin(_pinController.text.trim()),
        name: _nameController.text.trim(),
        roles: _selectedRoles.isEmpty ? [UserRole.ouvrier] : _selectedRoles,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await authRepo.createUser(newUser);

      final employeeRepo = ref.read(employeeRepositoryProvider);
      final parts = newUser.name.trim().split(' ');
      final prenom = parts.isNotEmpty ? parts.first : '';
      final nom = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      
      final newEmployee = Employee(
        id: '',
        userId: newUser.id,
        tenantId: selectedStation.id,
        nom: nom,
        prenom: prenom,
        phone: newUser.phone,
        contrat: ContractType.mensuel,
        valeurJournaliere: 0.0,
        salaireMensuel: 0.0,
        extraHourRate: 0.0,
        commissionRate: 0.0,
        roles: _selectedRoles.isEmpty ? [UserRole.ouvrier] : _selectedRoles,
        isActive: true,
        dateEmbauche: now,
        createdAt: now,
        updatedAt: now,
      );
      await employeeRepo.createEmployee(newEmployee);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employé créé avec succès'.tr)),
      );

      _phoneController.clear();
      _pinController.clear();
      _nameController.clear();
      setState(() {
        _isSaving = false;
        _selectedRoles = [UserRole.ouvrier];
      });
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showAddEmployeeDialog() {
    _nameController.clear();
    _phoneController.clear();
    _pinController.clear();
    _selectedRoles = [UserRole.ouvrier];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ajouter un Employé'.tr),
              content: SingleChildScrollView(
                child: Form(
                  key: _addFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nom complet'.tr),
                        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: 'Téléphone'.tr),
                        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Code PIN (4 chiffres)'.tr),
                        validator: (v) => v == null || v.length < 4 ? 'PIN invalide' : null,
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        children: UserRole.values.where((r) => r != UserRole.admin).map((r) {
                          return FilterChip(
                            label: Text(r.name.toUpperCase()),
                            selected: _selectedRoles.contains(r),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  _selectedRoles.add(r);
                                } else {
                                  _selectedRoles.remove(r);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : () {
                    setDialogState(() => _isSaving = true);
                    _createEmployee().then((_) {
                      if (mounted) setDialogState(() => _isSaving = false);
                    });
                  },
                  child: _isSaving
                      ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Créer'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station sur le Dashboard.')),
      );
    }

    final employeesStream = ref.watch(employeesStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Employés - ${selectedStation.name}'.tr),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: employeesStream.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Text('Aucun employé dans cette station.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: employee.roles.contains(UserRole.caissier) ? AppTheme.accentTeal : AppTheme.primaryBlue,
                    child: Text(employee.name.substring(0, 1).toUpperCase(), style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(employee.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Rôle: ${employee.roles.map((r) => r.label).join(' & ')}\nSalaire: ${employee.salary} DT | Comm: ${employee.commissionRate}%',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.settings, color: AppTheme.accentCyan),
                    onPressed: () => _showEditRatesDialog(employee),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}
