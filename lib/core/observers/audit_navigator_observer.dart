import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/providers/audit_provider.dart';
import 'package:washify/providers/auth_provider.dart';

class AuditNavigatorObserver extends NavigatorObserver {
  final ProviderRef<dynamic> ref;

  AuditNavigatorObserver(this.ref);

  void _logNavigation(String action, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    if (route == null) return;
    
    // Pour GoRouter, le nom de la route se trouve souvent dans route.settings.name
    // Si absent, on prend runtimeType ou fallback
    final routeName = route.settings.name ?? route.settings.name ?? route.runtimeType.toString();
    final previousRouteName = previousRoute?.settings.name ?? 'none';
    
    // Ignore dialogs, bottom sheets, or internal framework routes
    if (route is! PageRoute) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final auditRepo = ref.read(auditRepositoryProvider);
    
    String description;
    if (action == 'push') {
      description = 'A visité la page: $routeName (depuis $previousRouteName)';
    } else if (action == 'pop') {
      description = 'Est retourné sur la page: $previousRouteName (en quittant $routeName)';
    } else if (action == 'replace') {
      description = 'A remplacé la page: $previousRouteName par $routeName';
    } else {
      description = 'Navigation vers $routeName';
    }

    auditRepo.log(
      userId: user.id,
      userName: user.name,
      action: 'navigation_$action',
      module: 'navigation',
      description: description,
      severity: 'info',
      stationId: user.tenantId,
      newData: {
        'to': routeName,
        'from': previousRouteName,
      },
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('replace', newRoute, oldRoute);
  }
}
