import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../chat/screens/mobile_chat_screen.dart';

class OtherProfileScreen extends ConsumerWidget {
  static const String routeName = '/other-profile-screen';
  final String? name;
  final String uid;
  final bool isGroupChat;
  final String? profilePicture;
  final String? groupId;

   OtherProfileScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePicture,
    required this.groupId,
    bool? isGroupChat,
  })  : isGroupChat = isGroupChat ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.grey),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isGroupChat
                ?  Column(
          children: [
          CircleAvatar(
          backgroundImage:
          NetworkImage(profilePicture!),
          radius: 45,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name!,
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(uid),
            IconButton(
              onPressed: () {
                FlutterClipboard.copy(uid).then((result) {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('UID copied')),
                  );
                });
              },
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              MobileChatScreen.routeName,
              arguments: {
                'name': name,
                'uid': uid,
                'isGroupChat': isGroupChat,
                'profilePicture': profilePicture,
              },
            );
          },
          style: buttonMessageStyle,
          child: const Text('Message'),
        ),

        ],
      )
                : StreamBuilder<UserModel>(
                    stream: ref.read(authControllerProvider).userDataById(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final profile = snapshot.data!;
                        return Column(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(profile.profilePicture),
                              radius: 45,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name!,
                                  style: const TextStyle(
                                      fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(uid),
                                IconButton(
                                  onPressed: () {
                                    FlutterClipboard.copy(uid).then((result) {
                                      scaffoldMessengerKey.currentState?.showSnackBar(
                                        const SnackBar(content: Text('UID copied')),
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.copy),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  MobileChatScreen.routeName,
                                  arguments: {
                                    'name': name,
                                    'uid': uid,
                                    'isGroupChat': isGroupChat,
                                    'profilePicture': profilePicture,
                                  },
                                );
                              },
                              style: buttonMessageStyle,
                              child: const Text('Message'),
                            ),

                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const Loader();
                      };
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // style for ElevatedButton
  final buttonMessageStyle = ElevatedButton.styleFrom(
   backgroundColor: tabColor, // foreground color
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(10),
  ),
  );

} //class
