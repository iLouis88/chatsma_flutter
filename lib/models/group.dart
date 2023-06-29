import 'package:firebase_auth/firebase_auth.dart';

class Group {
  final String senderId;
  final String name;
  final String groupId;
  final String lastMessage;
  final String groupPicture;
  final List<String> membersUid;
  final DateTime timeSent;
  List<String> notificationTokens;

  Group( {
    required this.senderId,
    required this.name,
    required this.groupId,
    required this.lastMessage,
    required this.groupPicture,
    required this.membersUid,
    required this.timeSent,
    required this.notificationTokens,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'name': name,
      'groupId': groupId,
      'lastMessage': lastMessage,
      'groupPicture': groupPicture,
      'membersUid': membersUid,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'notificationTokens': notificationTokens,
    };
  }

  factory Group.fromFirebaseUser(User user) {
    final groupId = user.uid;
    final senderId = user.uid;
    final groupName = user.displayName ?? '';
    final groupPicture = user.photoURL ?? '';

    return Group(
      senderId: senderId,
      name: groupName,
      groupId: groupId,
      lastMessage: '',
      groupPicture: groupPicture,
      membersUid: [groupId],
      timeSent: DateTime.now(),
      notificationTokens: [],
    );
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      senderId: map['senderId'] ?? '',
      name: map['name'] ?? '',
      groupId: map['groupId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      groupPicture: map['groupPicture'] ?? '',
      membersUid: List<String>.from(map['membersUid']),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      notificationTokens: List<String>.from(map['notificationTokens']),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      senderId: json["senderId"],
      name: json["name"],
      groupId: json["groupId"],
      lastMessage: json["lastMessage"],
      groupPicture: json["groupPicture"],
      membersUid: List<String>.from(json["membersUid"].map((x) => x)),
      timeSent: DateTime.parse(json["timeSent"]),
      notificationTokens:List<String>.from(json["notificationTokens"].map((x) => x)),
    );
  }
//
}
