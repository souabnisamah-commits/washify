import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_session.freezed.dart';
part 'cash_session.g.dart';

@freezed
class CashSession with _$CashSession {
  const factory CashSession({
    required String id,
    required String stationId,
    required DateTime openingDate,
    DateTime? closingDate,
    required String openedBy,
    String? closedBy,
    required double initialBalance,
    double? finalBalance,
    @Default(0.0) double totalCashIn,
    @Default(0.0) double totalCashOut,
    required String status, // 'open', 'closed'
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CashSession;

  factory CashSession.fromJson(Map<String, dynamic> json) => _$CashSessionFromJson(json);
}
