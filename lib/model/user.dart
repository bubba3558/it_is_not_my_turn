import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String name;
  final String email;
  final String id;
  final String photoUrl;

  User(this.name, this.email, this.id, this.photoUrl);

  User.fromFirebase(FirebaseUser firebaseUser)
      : name = firebaseUser.displayName,
        email = firebaseUser.email,
        id = firebaseUser.uid,
        photoUrl = firebaseUser.photoUrl;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
