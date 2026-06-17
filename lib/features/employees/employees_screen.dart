import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/employees/models/employee.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _commissionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _salaryController.dispose();
    _commissionController.dispose();
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
        commissionRate: double.parse(_commissionController.text),
        updatedAt: DateTime.now(),
      );

      await repo.updateEmployee(updated);

      final selectedStation = ref.read(selectedStationProvider);
      if (selectedStation != null) {
        ref.invalidate(employeesStreamProvider(selectedStation.id));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarifs de l\'employé mis à jour')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Paramètres: ${employee.name}'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Salaire de base (DT)',
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null ? 'Montant invalide' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commissionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Taux de commission (%)',
                    hintText: 'ex: 10 pour 10%',
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null ? 'Taux invalide' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _updateRates(employee),
              child: _isSaving
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return const Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station sur le Dashboard.')),
      );
    }

    final employeesStream = ref.watch(employeesStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Employés - ${selectedStation.name}'),
      ),
      body: employeesStream.when(
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(
              child: Text('Aucun employé dans cette station.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: employee.role.value == 'cashier' ? AppTheme.accentTeal : AppTheme.primaryBlue,
                    child: Text(employee.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Rôle: ${employee.role.label}\nSalaire: ${employee.salary} DT | Comm: ${employee.commissionRate}%',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings, color: AppTheme.accentCyan),
                    onPressed: () => _showEditRatesDialog(employee),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
