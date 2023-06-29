import 'package:agora_uikit/agora_uikit.dart';
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/config/agora_config.dart';
import 'package:chatsma_flutter/features/call/controller/call_controller.dart';
import 'package:chatsma_flutter/models/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;
  final bool isVideoCall;
  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
    required this.isVideoCall,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;
  String baseUrl = 'https://chat-sma.herokuapp.com';
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: baseUrl,
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    await client!.initialize();
    await client!.engine.enableAudio();
    await client!.engine.disableVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: client == null
            ? const Loader()
            : SafeArea(
                child: Stack(
                  children: [
                    AgoraVideoViewer(client: client!),
                    AgoraVideoButtons(
                      client: client!,
                      disconnectButtonChild: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent, // màu nền cho background
                          borderRadius:
                              BorderRadius.circular(60), // bo tròn viền
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await client!.engine.leaveChannel();
                            ref.read(callControllerProvider).endCall(
                                  widget.call.callerId,
                                  widget.call.receiverId,
                                  context,

                                );
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.call_end),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
