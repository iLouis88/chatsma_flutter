// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';


class UserModel {
  final String name;
  final String uid;
  final String profilePicture;
  final bool isOnline;
  final String phoneNumber;
  final String email;
  final List<String> groupId;
  late final String notificationToken;

  UserModel(
      {required this.name,
      required this.uid,
      required this.profilePicture,
      required this.isOnline,
      required this.phoneNumber,
      required this.email,
      required this.groupId,
      required this.notificationToken,
      });




  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
      'profilePicture': profilePicture,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'email': email,
      'groupId': groupId,
      'notificationToken': notificationToken,
    };
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      name: user.displayName ?? '',
      uid: user.uid,
      profilePicture: user.photoURL ?? '',
      isOnline: false,
      phoneNumber: user.phoneNumber ?? '',
      email: user.email ?? '',
      groupId: [],
      notificationToken: '',

    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      isOnline: map['isOnline'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      groupId: List<String>.from(map['groupId']),
      notificationToken: map['notificationToken'] ?? '',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      uid: json['uid'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      isOnline: json['isOnline'] ?? false,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      groupId: List<String>.from(json['groupId']),
      notificationToken: json['notificationToken'] ?? '',

    );
  }


  factory UserModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return UserModel.fromJson(data);
  }

}
