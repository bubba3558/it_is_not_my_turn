import 'package:it_is_not_my_turn/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'userGroup.g.dart';

@JsonSerializable()
class UserGroup {
  final String name;
  final String photoUrl;
  final List<String> userNames;

  UserGroup(this.name, this.userNames, this.photoUrl);

  factory UserGroup.fromJson(Map<String, dynamic> json) =>
      _$UserGroupFromJson(json);

  Map<String, dynamic> toJson() => _$UserGroupToJson(this);
}
