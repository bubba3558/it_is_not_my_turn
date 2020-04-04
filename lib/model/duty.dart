import 'package:json_annotation/json_annotation.dart';

part 'duty.g.dart';

@JsonSerializable()
class Duty {
  final String name;
  final String description;
  final Periodicity periodicity;
  final DateTime endDate;
  String lastUserName;
  DateTime nextDeadline;

  Duty(this.name, this.description, this.periodicity, this.nextDeadline,
      this.endDate);

  factory Duty.fromJson(Map<String, dynamic> json) => _$DutyFromJson(json);

  Map<String, dynamic> toJson() => _$DutyToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Duty &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lastUserName == other.lastUserName &&
          nextDeadline == other.nextDeadline;

  @override
  int get hashCode =>
      name.hashCode ^ lastUserName.hashCode ^ nextDeadline.hashCode;
}

enum Periodicity { Daily, Weekly, Monthly, Annually }
