class Group {
  final String senderId;
  final String name;
  final String groupId;
  final String lastMessage;
  final String groupPicture;
  final List<String> membersUid;
  final DateTime timeSent;

  Group( {
    required this.senderId,
    required this.name,
    required this.groupId,
    required this.lastMessage,
    required this.groupPicture,
    required this.membersUid,
    required this.timeSent,
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
    };
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
    );
  }

}
