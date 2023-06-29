class Call {
  final String callerId;
  final String callerName;
  final String callerPicture;
  final String receiverId;
  final String receiverName;
  final String receiverPicture;
  final String callId;
  final bool  hasDialled;
  Call({
    required this.callerId,
    required this.callerName,
    required this.callerPicture,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPicture,
    required this.callId,
    required this.hasDialled,
  });



  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'callerId': callerId,
      'callerName': callerName,
      'callerPicture': callerPicture,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPicture': receiverPicture,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      callerPicture: map['callerPicture'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      receiverPicture: map['receiverPicture'] as String,
      callId: map['callId'] as String,
      hasDialled: map['hasDialled'] as bool,
    );
  }

}
