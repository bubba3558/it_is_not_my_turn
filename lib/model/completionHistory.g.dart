// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completionHistory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletionHistory _$CompletionHistoryFromJson(Map<String, dynamic> json) {
  return CompletionHistory(
    json['dutyHistory'] == null
        ? null
        : DutyHistory.fromJson(json['dutyHistory'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CompletionHistoryToJson(CompletionHistory instance) =>
    <String, dynamic>{
      'dutyHistory': instance.dutyHistory,
    };
