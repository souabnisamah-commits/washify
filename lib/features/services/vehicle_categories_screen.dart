import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/vehicle_category_provider.dart';
import 'package:washify/features/services/models/vehicle_category.dart';

class VehicleCategoriesScreen extends ConsumerStatefulWidget {
  const VehicleCategoriesScreen({super.key});

  @override
  ConsumerState<VehicleCategoriesScreen> createState() => _VehicleCategoriesScreenState();
}

class _VehicleCategoriesScreenState extends ConsumerState<VehicleCategoriesScreen> {
  
  void _showCategoryDialog([VehicleCategory? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final examplesController = TextEditingController(text: category?.examples ?? '');
    final orderController = TextEditingController(text: (category?.sortOrder ?? 0).toString());
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                category == null ? 'Nouvelle Catégorie' : 'Modifier la Catégorie',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom de la catégorie'.tr,
                          hintText: 'ex: Citadines Compactes'.tr,
                          prefixIcon: Icon(Icons.category, color: AppTheme.accentCyan),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: examplesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Exemples de véhicules'.tr,
                          hintText: 'ex: 106, Clio, C2, C3, Fiat 500...'.tr,
                          prefixIcon: Icon(Icons.directions_car, color: AppTheme.accentCyan),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: orderController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Ordre d\'.traffichage',
                          hintText: 'ex: 1, 2, 3...'.tr,
                          prefixIcon: Icon(Icons.sort, color: AppTheme.accentCyan),
                        ),
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
                  onPressed: isSaving ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => isSaving = true);

                    try {
                      final user = ref.read(currentUserProvider);
                      if (user == null) return;
                      final stationId = user.tenantId;
                      final repo = ref.read(vehicleCategoryRepositoryProvider);
                      final now = DateTime.now();

                      if (category == null) {
                        // Create
                        await repo.create(VehicleCategory(
                          id: '',
                          tenantId: stationId,
                          name: nameController.text.trim(),
                          examples: examplesController.text.trim(),
                          sortOrder: int.tryParse(orderController.text) ?? 0,
                          createdAt: now,
                          updatedAt: now,
                        ));
                      } else {
                        // Update
                        await repo.update(category.copyWith(
                          name: nameController.text.trim(),
                          examples: examplesController.text.trim(),
                          sortOrder: int.tryParse(orderController.text) ?? category.sortOrder,
                          updatedAt: now,
                        ));
                      }

                      ref.invalidate(vehicleCategoriesStreamProvider(stationId));
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : $e'.tr)),
                        );
                      }
                    } finally {
                      if (context.mounted) setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(category == null ? 'Créer' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(VehicleCategory category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la catégorie'.tr),
        content: Text('Supprimer "${category.name}" ? Les services liés ne seront pas supprimés.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Annuler'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repo = ref.read(vehicleCategoryRepositoryProvider);
        await repo.delete(category.id);
        final user = ref.read(currentUserProvider);
        if (user != null) {
          ref.invalidate(vehicleCategoriesStreamProvider(user.tenantId));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'.tr)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Catégories de Véhicules'.tr),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: AppTheme.primaryBlue,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Nouvelle Catégorie', style: TextStyle(color: Colors.white)),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: AppTheme.textHint.withValues(alpha: 0.4)),
                  SizedBox(height: 16),
                  Text(
                    'Aucune catégorie de véhicule.\nCommencez par en créer une !',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textHint, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(Icons.directions_car, color: AppTheme.primaryBlue),
                  ),
                  title: Text(
                    cat.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: cat.examples.isNotEmpty
                      ? Text(
                          cat.examples,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppTheme.textHint, fontSize: 12),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${cat.sortOrder}',
                        style: TextStyle(color: AppTheme.textHint, fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: AppTheme.accentCyan),
                        onPressed: () => _showCategoryDialog(cat),
                        tooltip: 'Modifier'.tr,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: AppTheme.errorRed),
                        onPressed: () => _deleteCategory(cat),
                        tooltip: 'Supprimer'.tr,
                      ),
                    ],
                  ),
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
