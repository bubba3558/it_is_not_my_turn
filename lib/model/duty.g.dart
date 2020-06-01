// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Duty _$DutyFromJson(Map<String, dynamic> json) {
  return Duty(
    json['name'] as String,
    json['description'] as String,
    _$enumDecodeNullable(_$PeriodicityEnumMap, json['periodicity']),
    json['frequency'] as int,
    json['nextDeadline'] == null
        ? null
        : DateTime.parse(json['nextDeadline'] as String),
    json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
    json['groupId'] as String,
  )..lastUserName = json['lastUserName'] as String;
}

Map<String, dynamic> _$DutyToJson(Duty instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'periodicity': _$PeriodicityEnumMap[instance.periodicity],
      'frequency': instance.frequency,
      'endDate': instance.endDate?.toIso8601String(),
      'groupId': instance.groupId,
      'lastUserName': instance.lastUserName,
      'nextDeadline': instance.nextDeadline?.toIso8601String(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$PeriodicityEnumMap = {
  Periodicity.Day: 'Day',
  Periodicity.Week: 'Week',
  Periodicity.Month: 'Month',
  Periodicity.Year: 'Year',
};
