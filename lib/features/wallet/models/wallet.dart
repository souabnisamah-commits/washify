import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

enum WalletTransactionType {
  gainTicket('gain_ticket'),
  salaireJour('salaire_jour'),
  bonus('bonus'),
  retrait('retrait'),
  ajustement('ajustement');

  const WalletTransactionType(this.value);
  final String value;

  static WalletTransactionType fromString(String value) {
    return WalletTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WalletTransactionType.ajustement,
    );
  }
}

@freezed
class Wallet with _$Wallet {
  const Wallet._();

  const factory Wallet({
    required String id,
    required String userId,
    required String userName,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required double walletBalanceCache, // Solde calculé uniquement par Cloud Functions
    required double totalEarned,
    required double totalWithdrawn,
    required DateTime updatedAt,
  }) = _Wallet;

  double get balance => walletBalanceCache;
  String get stationId => tenantId;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}

@freezed
class WalletTransaction with _$WalletTransaction {
  const WalletTransaction._();

  const factory WalletTransaction({
    required String id,
    required String walletId,
    required String userId,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required WalletTransactionType type, // gain_ticket, bonus, retrait, ajustement
    required double amount,
    required double balanceBefore,
    required double balanceAfter,
    required String description,
    String? referenceId, // ticketId reference
    required DateTime createdAt,
  }) = _WalletTransaction;

  String get stationId => tenantId;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);
}
