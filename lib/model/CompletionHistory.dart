import 'package:it_is_not_my_turn/model/dutyHistory.dart';
import 'package:json_annotation/json_annotation.dart';

part 'completionHistory.g.dart';

@JsonSerializable()
class CompletionHistory {
  DutyHistory dutyHistory;

  CompletionHistory(this.dutyHistory);

  factory CompletionHistory.fromJson(Map<String, dynamic> json) =>
      _$CompletionHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$CompletionHistoryToJson(this);
}
