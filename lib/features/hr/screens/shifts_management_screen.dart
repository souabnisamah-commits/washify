import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/hr/models/shift.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/repositories/hr_repository.dart';
import 'package:washify/providers/auth_provider.dart';

class ShiftsManagementScreen extends ConsumerStatefulWidget {
  const ShiftsManagementScreen({super.key});

  @override
  ConsumerState<ShiftsManagementScreen> createState() => _ShiftsManagementScreenState();
}

class _ShiftsManagementScreenState extends ConsumerState<ShiftsManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _addShift() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner l\'heure de début et de fin')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || user.tenantId.isEmpty) return;

    final newShift = Shift(
      id: '',
      stationId: user.tenantId,
      name: _nameController.text.trim(),
      startTime: _formatTime(_startTime!),
      endTime: _formatTime(_endTime!),
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(hrRepositoryProvider).createShift(newShift);
      _nameController.clear();
      setState(() {
        _startTime = null;
        _endTime = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shift ajouté avec succès'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'.tr)),
        );
      }
    }
  }

  void _editShift(BuildContext context, Shift shift) {
    final editNameController = TextEditingController(text: shift.name);
    TimeOfDay? editStartTime = TimeOfDay(
      hour: int.parse(shift.startTime.split(':')[0]),
      minute: int.parse(shift.startTime.split(':')[1]),
    );
    TimeOfDay? editEndTime = TimeOfDay(
      hour: int.parse(shift.endTime.split(':')[0]),
      minute: int.parse(shift.endTime.split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectTime(bool isStart) async {
              final initialTime = isStart ? editStartTime : editEndTime;
              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime ?? TimeOfDay.now(),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setDialogState(() {
                  if (isStart) {
                    editStartTime = picked;
                  } else {
                    editEndTime = picked;
                  }
                });
              }
            }

            return AlertDialog(
              title: Text('Modifier le Shift'.tr),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editNameController,
                      decoration: InputDecoration(labelText: 'Nom'.tr, border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => selectTime(true),
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Heure de Début'.tr, border: OutlineInputBorder()),
                              child: Text(_formatTime(editStartTime!)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => selectTime(false),
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Heure de Fin'.tr, border: OutlineInputBorder()),
                              child: Text(_formatTime(editEndTime!)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler'.tr)),
                ElevatedButton(
                  onPressed: () async {
                    if (editNameController.text.trim().isEmpty) return;
                    final updatedShift = shift.copyWith(
                      name: editNameController.text.trim(),
                      startTime: _formatTime(editStartTime!),
                      endTime: _formatTime(editEndTime!),
                    );
                    try {
                      await ref.read(hrRepositoryProvider).updateShift(updatedShift);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shift modifié'.tr)));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'.tr)));
                      }
                    }
                  },
                  child: Text('Enregistrer', style: TextStyle(color: Colors.white)),
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
    final user = ref.watch(currentUserProvider);
    if (user == null || user.tenantId.isEmpty) return Center(child: Text('Aucune station'.tr));

    final shiftsAsync = ref.watch(shiftsStreamProvider(user.tenantId));

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form to add shift
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ajouter un Shift', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du Shift (ex: Matin, Soir)'.tr,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Heure de Début'.tr, border: OutlineInputBorder()),
                              child: Text(_startTime != null ? _formatTime(_startTime!) : 'Sélectionner'),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Heure de Fin'.tr, border: OutlineInputBorder()),
                              child: Text(_endTime != null ? _formatTime(_endTime!) : 'Sélectionner'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _addShift,
                        icon: Icon(Icons.add),
                        label: Text('Ajouter le Shift'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text('Shifts Existants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Expanded(
            child: shiftsAsync.when(
              data: (shifts) {
                if (shifts.isEmpty) {
                  return Center(child: Text('Aucun shift configuré'.tr));
                }
                return ListView.builder(
                  itemCount: shifts.length,
                  itemBuilder: (context, index) {
                    final shift = shifts[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.schedule, color: AppTheme.primaryBlue),
                        title: Text(shift.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('De ${shift.startTime} à ${shift.endTime}'.tr),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppTheme.primaryBlue),
                              onPressed: () => _editShift(context, shift),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: AppTheme.errorRed),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: Text('Confirmer'.tr),
                                    content: Text('Supprimer ce shift ?'.tr),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Non'.tr)),
                                      ElevatedButton(onPressed: () => Navigator.pop(c, true), child: Text('Oui', style: TextStyle(color: Colors.white))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(hrRepositoryProvider).deleteShift(shift.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur: $e'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
