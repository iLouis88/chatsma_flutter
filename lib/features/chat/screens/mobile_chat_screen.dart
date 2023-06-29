// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/features/auth/widgets/edit_profile_screen.dart';
import 'package:chatsma_flutter/features/call/controller/call_controller.dart';
import 'package:chatsma_flutter/features/call/screens/call_pickup_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:chatsma_flutter/features/chat/widgets/chat_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../auth/screens/other_profile_screen.dart';
import '../widgets/bottom_chat_field.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String? name;
  final String uid;
  final bool isGroupChat;
  final String? profilePicture;
  final String? groupId;

  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePicture,
    required this.groupId,
    bool? isGroupChat,
  })  : isGroupChat = isGroupChat ?? false,
        super(key: key);

  // Call audio
  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name!,
          uid,
          profilePicture!,
          isGroupChat,
        );
  }

  //Call video
  void makeVideoCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeVideoCall(
      context,
      name!,
      uid,
      profilePicture!,
      isGroupChat,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int charLimit = 10;
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                OtherProfileScreen.routeName,
                arguments: {
                  'name': name,
                  'uid': uid,
                  'isGroupChat': isGroupChat,
                  'profilePicture': profilePicture,
                },
              );
            },
            child: isGroupChat
                ? Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profilePicture!),
                      radius: 18,
                    ),
                    const SizedBox(width: 10,),
                    Text(name!),
                  ],
                )
                : StreamBuilder<UserModel>(
                    stream: ref.read(authControllerProvider).userDataById(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            OtherProfileScreen.routeName,
                            arguments: {
                              'name': name,
                              'uid': uid,
                              'isGroupChat': isGroupChat,
                              'profilePicture': profilePicture,
                            },
                          );
                        },

                        child: Row(

                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(profilePicture!),
                              radius: 18,
                            ),
                            const SizedBox(width: 10,),
                            Column(
                              children: [

                                Text(name!.length > charLimit ? name!.substring(0, charLimit) + '...' : name!,
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ), // substring(0, charLimit)giới hạn số kí tự được hiển thị trên 1 dòng text
                                Text(
                                  snapshot.data!.isOnline ? 'online' : 'offline',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => makeVideoCall(ref, context),
              icon: Image.asset(
                'assets/icons/video_call.png',
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => makeCall(ref, context),
              icon: const Icon(Icons.call_rounded,
                color: Colors.white,
              ),
            ),
            //Menu
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                receiverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: BottomChatField(
                receiverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
