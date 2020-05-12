import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserGroup {
  final String name;
  final String photoUrl;
  final List<String> userNames;
  final String id;

  UserGroup(this.name, this.userNames, this.photoUrl, this.id);

  factory UserGroup.fromFirebase(DocumentSnapshot firebaseObject) {
    return UserGroup(
        firebaseObject.data['name'] as String,
        (firebaseObject.data['userNames'] as List)
            ?.map((e) => e as String)
            ?.toList(),
        firebaseObject.data['photoUrl'] as String,
        firebaseObject.documentID);
  }

  Map<String, dynamic> toFirebase() => <String, dynamic>{
        'name': this.name,
        'photoUrl': this.photoUrl,
        'userNames': this.userNames,
      };
}

Map<String, dynamic> toFirebaseUserGroup(name, userNames, photoUrl) =>
    <String, dynamic>{
      'name': name,
      'photoUrl': photoUrl,
      'userNames': userNames,
    };
