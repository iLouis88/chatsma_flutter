import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/features/call/repository/call_repository.dart';
import 'package:chatsma_flutter/models/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  var instance = FirebaseAuth.instance;
  return CallController(
        callRepository: callRepository,
        auth: instance,
        ref: ref,
  );
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;
  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
  });

//
  Stream<DocumentSnapshot>get callStream => callRepository.callStream;

  //Call audio
  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfilePicture, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();

      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPicture: value.profilePicture,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPicture: receiverProfilePicture,
        callId: callId,
        hasDialled: true,
      );

      Call receiverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPicture: value.profilePicture,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPicture: receiverProfilePicture,
        callId: callId,
        hasDialled: false,
      );

      if(isGroupChat) {
        callRepository.makeGroupCall(senderCallData, context, receiverCallData);
      } else {
        callRepository.makeCall(senderCallData, context, receiverCallData);
      }
    });
  }

  void makeVideoCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfilePicture, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();

      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPicture: value.profilePicture,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPicture: receiverProfilePicture,
        callId: callId,
        hasDialled: true,
      );

      Call receiverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPicture: value.profilePicture,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPicture: receiverProfilePicture,
        callId: callId,
        hasDialled: false,
      );

    /*  if(isGroupChat) {
        callRepository.makeGroupVideoCall(senderCallData, context, receiverCallData);
      } else {
        callRepository.makeVideoCall(senderCallData, context, receiverCallData);
      }*/
    });
  }

  void endCall(
      String callerId,
      String receiverId,
      BuildContext context,
      ) {
      callRepository.endCall(callerId, receiverId, context);
  }
  void endGroupCall(
      String callerId,
      String receiverId,
      BuildContext context,
      ) {
    callRepository.endGroupCall(callerId, receiverId, context);
  }

}
