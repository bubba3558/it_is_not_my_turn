import 'package:json_annotation/json_annotation.dart';

part 'duty.g.dart';

@JsonSerializable()
class Duty {
  final String name;
  final String description;
  final Periodicity periodicity;
  String lastUserName;
  DateTime nextDeadline;
  DateTime endDate;

  Duty(this.name, this.description, this.periodicity, this.nextDeadline,
      this.endDate);

  factory Duty.fromJson(Map<String, dynamic> json) => _$DutyFromJson(json);

  Map<String, dynamic> toJson() => _$DutyToJson(this);
}

enum Periodicity { Daily, Weekly, Monthly, Annually }
