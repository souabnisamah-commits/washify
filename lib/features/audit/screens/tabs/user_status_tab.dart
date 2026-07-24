import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:intl/intl.dart';

class UserStatusTab extends ConsumerStatefulWidget {
  const UserStatusTab({super.key});

  @override
  ConsumerState<UserStatusTab> createState() => _UserStatusTabState();
}

class _UserStatusTabState extends ConsumerState<UserStatusTab> {
  String? _selectedStationId;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return const SizedBox.shrink();

    final isAdmin = currentUser.roles.any((r) => r == UserRole.admin);
    final targetStationId = isAdmin ? _selectedStationId : currentUser.tenantId;

    final stationsAsync = isAdmin 
        ? ref.watch(allStationsProvider) 
        : const AsyncValue<List<Station>>.data([]);

    return Column(
      children: [
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: stationsAsync.when(
              data: (stations) {
                if (stations.isEmpty) return const Text('Aucune station disponible', style: TextStyle(color: AppTheme.textHint));
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sélectionner une station (Lavage)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    filled: true,
                    fillColor: AppTheme.surfaceCard,
                  ),
                  initialValue: _selectedStationId,
                  items: stations.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStationId = val;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Erreur: $e'),
            ),
          ),
        Expanded(
          child: targetStationId == null
              ? const Center(child: Text('Veuillez sélectionner une station pour voir ses utilisateurs.', style: TextStyle(color: AppTheme.textHint)))
              : ref.watch(stationUsersProvider(targetStationId)).when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(child: Text('Aucun utilisateur dans cette station', style: TextStyle(color: AppTheme.textHint)));
                    }

                    // Sort: Online first
                    final sortedUsers = List.of(users)
                      ..sort((a, b) => (b.isOnline ? 1 : 0).compareTo(a.isOnline ? 1 : 0));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedUsers.length,
                      itemBuilder: (context, index) {
                        final user = sortedUsers[index];
                        final lastLoginStr = user.lastLoginAt != null 
                          ? DateFormat('dd/MM/yyyy HH:mm').format(user.lastLoginAt!) 
                          : 'Jamais';

                        return Card(
                          color: AppTheme.surfaceCard,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: user.isOnline ? AppTheme.successGreen.withValues(alpha: 0.5) : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user.isOnline ? AppTheme.successGreen.withValues(alpha: 0.2) : AppTheme.surfaceDark,
                              child: Icon(Icons.person, color: user.isOnline ? AppTheme.successGreen : AppTheme.textHint),
                            ),
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rôle: ${user.roles.map((r) => r.name).join(', ')}'),
                                Text('Dernière connexion: $lastLoginStr', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                              ],
                            ),
                            trailing: user.isOnline 
                              ? ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                                    foregroundColor: Colors.redAccent,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.power_settings_new, size: 16),
                                  label: const Text('Tuer Session'),
                                  onPressed: () => _killSession(context, ref, user.id),
                                )
                              : const Chip(
                                  label: Text('Hors Ligne', style: TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.transparent,
                                ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e')),
                ),
        ),
      ],
    );
  }

  Future<void> _killSession(BuildContext context, WidgetRef ref, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Confirmer la déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir forcer la déconnexion de cet utilisateur ? Il devra se reconnecter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.textHint)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tuer la session'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repo = ref.read(authRepositoryProvider);
        await repo.forceLogoutUser(userId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signal de déconnexion envoyé.'), backgroundColor: AppTheme.successGreen),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }
}
