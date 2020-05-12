import 'package:it_is_not_my_turn/model/userGroup.dart';
import 'package:json_annotation/json_annotation.dart';

part 'duty.g.dart';

@JsonSerializable()
class Duty {
  final String name;
  final String description;
  final Periodicity periodicity;
  final DateTime endDate;
  final String groupId;
  String lastUserName;
  DateTime nextDeadline;

  Duty(this.name, this.description, this.periodicity, this.nextDeadline,
      this.endDate, this.groupId);

  factory Duty.fromJson(Map<String, dynamic> json) => _$DutyFromJson(json);

  Map<String, dynamic> toJson() => _$DutyToJson(this);

}

enum Periodicity { Daily, Weekly, Monthly, Annually }
