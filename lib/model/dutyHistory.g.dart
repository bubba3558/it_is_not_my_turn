// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dutyHistory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DutyHistory _$DutyHistoryFromJson(Map<String, dynamic> json) {
  return DutyHistory(
    json['userName'] as String,
    json['completionDate'] == null
        ? null
        : DateTime.parse(json['completionDate'] as String),
    json['daysBeforeDeadline'] as int,
  );
}

Map<String, dynamic> _$DutyHistoryToJson(DutyHistory instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'completionDate': instance.completionDate?.toIso8601String(),
      'daysBeforeDeadline': instance.daysBeforeDeadline,
    };
