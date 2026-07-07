// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletImpl _$$WalletImplFromJson(Map<String, dynamic> json) => _$WalletImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  tenantId: json['tenantId'] as String,
  walletBalanceCache: (json['walletBalanceCache'] as num).toDouble(),
  totalEarned: (json['totalEarned'] as num).toDouble(),
  totalWithdrawn: (json['totalWithdrawn'] as num).toDouble(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$WalletImplToJson(_$WalletImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'tenantId': instance.tenantId,
      'walletBalanceCache': instance.walletBalanceCache,
      'totalEarned': instance.totalEarned,
      'totalWithdrawn': instance.totalWithdrawn,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$WalletTransactionImpl(
  id: json['id'] as String,
  walletId: json['walletId'] as String,
  userId: json['userId'] as String,
  tenantId: json['tenantId'] as String,
  type: $enumDecode(_$WalletTransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  balanceBefore: (json['balanceBefore'] as num).toDouble(),
  balanceAfter: (json['balanceAfter'] as num).toDouble(),
  description: json['description'] as String,
  referenceId: json['referenceId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$WalletTransactionImplToJson(
  _$WalletTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'walletId': instance.walletId,
  'userId': instance.userId,
  'tenantId': instance.tenantId,
  'type': _$WalletTransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'balanceBefore': instance.balanceBefore,
  'balanceAfter': instance.balanceAfter,
  'description': instance.description,
  'referenceId': instance.referenceId,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$WalletTransactionTypeEnumMap = {
  WalletTransactionType.gainTicket: 'gainTicket',
  WalletTransactionType.salaireJour: 'salaireJour',
  WalletTransactionType.bonus: 'bonus',
  WalletTransactionType.retrait: 'retrait',
  WalletTransactionType.ajustement: 'ajustement',
};
