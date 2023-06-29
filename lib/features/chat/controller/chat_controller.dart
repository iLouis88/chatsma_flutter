import 'dart:io';

import 'package:chatsma_flutter/common/enums/message_enum.dart';
import 'package:chatsma_flutter/common/providers/message_reply_provider.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/features/chat/repositories/chat_repository.dart';
import 'package:chatsma_flutter/models/chat_contact.dart';
import 'package:chatsma_flutter/models/group.dart';
import 'package:chatsma_flutter/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/message.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  //show chat contacts
  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<UserModel> getUserInfo() {
    return chatRepository.getUserInfo();
  }

  // show group list
  Stream<List<Group>> chatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<Group>> showAllGroups() {
    return chatRepository.getAllChatGroups();
  }

  //show messages
  Stream<List<MessageModel>> chatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  // show group messages
  Stream<List<MessageModel>> groupChatStream(String groupId) {
    return chatRepository.getGroupChatStream(groupId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            senderUser: value!,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
          ),
        );

    ref.read(messageReplyProvider.notifier).update((notifier) => null);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            messageEnum: messageEnum,
            ref: ref,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((notifier) => null);
  }

  void sendGIF(
    BuildContext context,
    String gifUrl,
    String receiverUserId,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIF(
            context: context,
            gifUrl: newgifUrl,
            receiverUserId: receiverUserId,
            senderUser: value!,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((notifier) => null);
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) {
    chatRepository.setChatMessageSeen(
      context,
      receiverUserId,
      messageId,
    );
  }

  // ````````````````````` Push Notification `````````````````````//
  Future<void> getFMToken({required UserModel existingUser}) async {
    await chatRepository.getFMToken(existingUser: existingUser);
  }

  void getNotificationToken(UserModel? user, String token) {
    return chatRepository.getNotificationToken(user, token);
  }

  Future<void> pushNotification(
      UserModel existingUser, UserModel receiverUser, String text) {
    return chatRepository.pushNotification(
      existingUser: existingUser,
      receiverUser: receiverUser,
      text: text,
    );
  }

  //********** Function (Delete) **********/

  // hide a chat contact
  void hideChatContact(String receiverUserId) {
    return chatRepository.hideChatContact(receiverUserId);
  }

  Future<void> deleteChatContactMess(String receiverUserId) {
    return chatRepository.deleteChatContactMess(receiverUserId);
  }

  // Delete all content of an individual chat
  Future<void> deleteAllPrivateChats(String receiverUserId) {
    return chatRepository.deleteAllPrivateChats(receiverUserId);
  }

// Delete only the sender's messages
  void deleteSenderMessages(String receiverUserId, String messageId) {
    return chatRepository.deleteSenderMessages(receiverUserId, messageId);
  }

// delete group messages
  Future<void> deleteGroupChats(String groupId) async {
    return chatRepository.deleteGroupChats(groupId);
  }

//Delete group
  Future<void> deleteGroupChat(String groupId) {
    return chatRepository.deleteGroupChat(groupId);
  }
}
