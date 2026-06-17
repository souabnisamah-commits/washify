import 'package:freezed_annotation/freezed_annotation.dart';

part 'commission_rule.freezed.dart';
part 'commission_rule.g.dart';

@freezed
class CommissionRule with _$CommissionRule {
  const factory CommissionRule({
    required String id,
    required String stationId,
    String? serviceId,
    required double rate, // percentage (e.g., 10 means 10%)
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CommissionRule;

  factory CommissionRule.fromJson(Map<String, dynamic> json) => _$CommissionRuleFromJson(json);
}
