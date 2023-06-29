import 'package:chatsma_flutter/common/enums/message_enum.dart';
import 'package:chatsma_flutter/common/providers/message_reply_provider.dart';
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/chat/controller/chat_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/features/chat/widgets/my_message_card.dart';
import 'package:chatsma_flutter/features/chat/widgets/sender_message_card.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/message.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;
  const ChatList({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) :  super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
        );
  }
 /* void deleteGroupSenderMessages(receiverUserId, messageId) {
    ref
        .read(chatControllerProvider)
        .deleteGroupSenderMessages(receiverUserId, messageId);
  }*/

  void deleteSenderMessages(receiverUserId, messageId) {
    ref
        .read(chatControllerProvider)
        .deleteSenderMessages(receiverUserId, messageId);
  }


  //Menu Dialog
  void _showMessageOptions(MessageModel message) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Message Options'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Unsend for you', style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteSenderMessages(widget.receiverUserId, message.messageId);
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Unknown'),
              onPressed: () {
                Navigator.pop(context);
                // Handle share message here
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
        stream: widget.isGroupChat
            ? ref
                .read(chatControllerProvider)
                .groupChatStream(widget.receiverUserId)
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.receiverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });

          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              var timeSent = DateFormat.Hm().format(messageData.timeSent);

              //isSeen
              if (!messageData.isSeen &&
                  messageData.receiverId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                      context,
                      widget.receiverUserId,
                      messageData.messageId,
                    );
              }
              if (messageData.senderId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                return GestureDetector(
                  onLongPress: () {
                    _showMessageOptions(messageData);
                  },
                  child: MyMessageCard(
                    message: messageData.text,
                    date: timeSent,
                    type: messageData.type,
                    repliedText: messageData.repliedMessage,
                    username: messageData.repliedTo,
                    repliedMessageType: messageData.repliedMessageType,
                    onLeftSwipe: () => onMessageSwipe(
                      messageData.text,
                      true,
                      messageData.type,
                    ),
                    isSeen: messageData.isSeen,
                  ),
                );
              }
              return GestureDetector(
                onLongPress: () {
                  _showMessageOptions(messageData);
                },
                child: SenderMessageCard(
                  message: messageData.text,
                  date: timeSent,
                  type: messageData.type,
                  username: messageData.repliedTo,
                  repliedMessageType: messageData.repliedMessageType,
                  onRightSwipe: () => onMessageSwipe(
                    messageData.text,
                    false,
                    messageData.type,
                  ),
                  repliedText: messageData.repliedMessage,
                ),
              );
            },
          );
        });
  }
}
