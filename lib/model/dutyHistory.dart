import 'package:json_annotation/json_annotation.dart';

part 'dutyHistory.g.dart';

@JsonSerializable()
class DutyHistory {
  final String userName;
  final DateTime completionDate;
  int daysBeforeDeadline;

  DutyHistory(this.userName, this.completionDate, this.daysBeforeDeadline);

  factory DutyHistory.fromJson(Map<String, dynamic> json) =>
      _$DutyHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$DutyHistoryToJson(this);
}
