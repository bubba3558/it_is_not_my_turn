import 'package:json_annotation/json_annotation.dart';

part 'duty.g.dart';

@JsonSerializable()
class Duty {
  final String name;
  final String description;
  final Periodicity periodicity;
  final int frequency;
  final DateTime endDate;
  final String groupId;
  String lastUserName;
  DateTime nextDeadline;

  Duty(this.name, this.description, this.periodicity, this.frequency,
      this.nextDeadline, this.endDate, this.groupId);

  factory Duty.fromJson(Map<String, dynamic> json) => _$DutyFromJson(json);

  Map<String, dynamic> toJson() => _$DutyToJson(this);
}

enum Periodicity { Day, Week, Month, Year }
