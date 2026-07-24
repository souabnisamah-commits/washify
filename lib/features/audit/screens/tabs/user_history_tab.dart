import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/audit_provider.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:intl/intl.dart';

class UserHistoryTab extends ConsumerStatefulWidget {
  const UserHistoryTab({super.key});

  @override
  ConsumerState<UserHistoryTab> createState() => _UserHistoryTabState();
}

class _UserHistoryTabState extends ConsumerState<UserHistoryTab> {
  String? _selectedStationId;
  String? _selectedUserId;

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
                    labelText: 'Sélectionner une station',
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
                      _selectedUserId = null; // Reset user selection
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Erreur: $e'),
            ),
          ),
          
        if (targetStationId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ref.watch(stationUsersProvider(targetStationId)).when(
              data: (users) {
                if (users.isEmpty) return const Text('Aucun utilisateur dans cette station', style: TextStyle(color: AppTheme.textHint));
                
                // Ensure _selectedUserId is still valid for this station
                if (_selectedUserId != null && !users.any((u) => u.id == _selectedUserId)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedUserId = null);
                  });
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sélectionner un utilisateur',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    filled: true,
                    fillColor: AppTheme.surfaceCard,
                  ),
                  initialValue: _selectedUserId,
                  items: users.map((u) => DropdownMenuItem(
                    value: u.id,
                    child: Text('${u.name} (${u.roles.first.name})'),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedUserId = val;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Erreur: $e'),
            ),
          ),
        
        Expanded(
          child: _selectedUserId == null
              ? const Center(child: Text('Veuillez sélectionner une station et un utilisateur.', style: TextStyle(color: AppTheme.textHint)))
              : ref.watch(userAuditLogsStreamProvider((userId: _selectedUserId!, limit: 100))).when(
                  data: (userLogs) {
                    if (userLogs.isEmpty) {
                      return const Center(child: Text('Aucune activité enregistrée pour cet utilisateur.', style: TextStyle(color: AppTheme.textHint)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: userLogs.length,
                      itemBuilder: (context, index) {
                        final log = userLogs[index];
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(log.createdAt);
                        final isError = log.severity == 'critical';
                        final isNavigation = log.module == 'navigation';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isNavigation ? Icons.visibility : (isError ? Icons.error : Icons.edit),
                                size: 16,
                                color: isNavigation ? Colors.grey : (isError ? Colors.redAccent : AppTheme.accentCyan),
                              ),
                              Container(width: 2, height: 20, color: AppTheme.surfaceCard), // Timeline line
                            ],
                          ),
                          title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(log.description),
                          trailing: Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
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
}
