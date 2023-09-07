import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/features/call/controller/call_controller.dart';
/*import 'package:chatsma_flutter/features/call/screens/video_call_screen.dart';*/
import 'package:chatsma_flutter/models/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'call_screen.dart';

class CallPickupScreen extends ConsumerStatefulWidget {
  final Widget scaffold;

  const CallPickupScreen({Key? key, required this.scaffold}) : super(key: key);

  @override
  _CallPickupScreenState createState() => _CallPickupScreenState();
}

class _CallPickupScreenState extends ConsumerState<CallPickupScreen> {
  final bool isVideoCall = false;

  void declineGroupCall(
      String callerId, String receiverId, BuildContext context) {
    ref
        .read(callControllerProvider)
        .endGroupCall(callerId, receiverId, context);
  }

  void _declineCall(
      BuildContext context, String callerId, String receiverId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Delete the call document from Firestore
    await firestore.collection('call').doc(callerId).delete();
    await firestore.collection('call').doc(receiverId).delete();

    showSnackBar(context: context, content: 'Call rejected');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          if (!call.hasDialled) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(call.callerPicture),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPicture),
                      radius: 50,
                    ),
                    const SizedBox(height: 25),
                    Column(
                      children: [
                        Text(
                          call.callerName,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Incoming Call',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 200),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                _declineCall(
                                    context, call.callerId, call.receiverId);
                                declineGroupCall(
                                    call.callerId, call.receiverId, context);
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 30,
                                child: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    5), // Add some space between CircleAvatar and Text
                            const Text(
                              'Decline',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 120,
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                           CallScreen(
                                              channelId: call.callId,
                                              call: call,
                                              isGroupChat: false,
                                              isVideoCall: false,
                                            )
                                          ),
                                 /* MaterialPageRoute(
                                      builder: (context) => isVideoCall
                                          ? CallScreen(
                                        channelId: call.callId,
                                        call: call,
                                        isGroupChat: false,
                                        isVideoCall: false,
                                      )
                                          : VideoCallScreen(
                                        channelId: call.callId,
                                        call: call,
                                        isGroupChat: false,
                                        isVideoCall: true,
                                      )),*/
                                );
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 30,
                                child: Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    5), // Add some space between CircleAvatar and Text
                            const Text(
                              'Accept',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return widget.scaffold;
      },
    );
  }
}
