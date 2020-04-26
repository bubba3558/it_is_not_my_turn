// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userGroup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserGroup _$UserGroupFromJson(Map<String, dynamic> json) {
  return UserGroup(
    json['name'] as String,
    (json['userNames'] as List)?.map((e) => e as String)?.toList(),
    json['photoUrl'] as String,
  );
}

Map<String, dynamic> _$UserGroupToJson(UserGroup instance) => <String, dynamic>{
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'userNames': instance.userNames,
    };
