
class UserModel {
  final String name;
  final String uid;
  final String profilePicture;
  final bool isOnline;
  final String phoneNumber;
  final List<String> groupId;

  UserModel(
      {required this.name,
      required this.uid,
      required this.profilePicture,
      required this.isOnline,
      required this.phoneNumber,
      required this.groupId});

  Map<String, dynamic> toMap() {
    return{
      'name': name,
      'uid': uid,
      'profilePicture': profilePicture,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      isOnline: map['isOnline'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      groupId: List<String>.from(map['groupId']),
    );
  }
}
