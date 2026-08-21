import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/repositories/audit_repository.dart';
import 'package:washify/core/utils/session_service.dart';

class AuditProviderObserver extends ProviderObserver {
  final AuditRepository _auditRepo;

  AuditProviderObserver(this._auditRepo);

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Log the error to the audit system
    _auditRepo.log(
      userId: SessionService.instance.getSavedUserId() ?? 'system',
      userName: 'Système (Riverpod)',
      action: 'provider_error',
      module: provider.name ?? provider.runtimeType.toString(),
      severity: 'error',
      description: error.toString(),
      deviceInfo: {
        'platform': 'Web / Flutter',
      },
      newData: {
        'stackTrace': stackTrace.toString(),
      },
    );
    
    super.providerDidFail(provider, error, stackTrace, container);
  }
}
