import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatsma_flutter/common/providers/message_reply_provider.dart';
import 'package:chatsma_flutter/common/repositories/common_firebase_storage_repository.dart';
import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/config/notification_config.dart';
import 'package:chatsma_flutter/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../common/enums/message_enum.dart';
import '../../../models/chat_contact.dart';
import '../../../models/message.dart';
import '../../../models/user_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> getFMToken({required UserModel existingUser}) async {
    try {
      await messaging.requestPermission();
      String? token = await messaging.getToken();
      if (token != null) {
        // Lưu trữ token vào Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        Map<String, dynamic> tokenData = {
          'token': token,
          'userId': existingUser.uid,
        };
        await firestore.collection('tokens').add(tokenData);

        // Cập nhật thuộc tính notificationToken của đối tượng UserModel
        UserModel updatedUser = UserModel(
          name: existingUser.name,
          uid: existingUser.uid,
          profilePicture: existingUser.profilePicture,
          isOnline: existingUser.isOnline,
          phoneNumber: existingUser.phoneNumber,
          email: existingUser.email,
          groupId: existingUser.groupId,
          notificationToken: token,
        );

        // Cập nhật đối tượng UserModel trong Firestore
        Map<String, dynamic> userMap = updatedUser.toMap();
        await firestore
            .collection('users')
            .doc(existingUser.uid)
            .update(userMap);

        // Cập nhật notificationToken của User thông qua hàm setNotificationToken
        User user = auth.currentUser!;
        UserModel userModel = UserModel.fromFirebaseUser(user);
        getNotificationToken(userModel, token);

        log('Notification token: $token');

      } else {
        log('Failed to get FCM token.');
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void getNotificationToken(UserModel? user, String token) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('users').doc(user!.uid).update({
      'notificationToken': token,
    });
  }


Future<void> pushNotification({
    required UserModel existingUser,
    required UserModel receiverUser,
    required String text,
  }) async {
    try {
      final body = {
        "to": receiverUser.notificationToken,
        "notification": {
          "title": '${existingUser.name}',
          "body": text,
          "android_channel_id": "chats"
        },
      };

      var res = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'key=${NotifyConfig.serverKeyNotify}'
        },
        body: jsonEncode(body),
      );
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');

    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<UserModel> getUserInfo() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot.data()!));
  }

  //Show chat contacts
  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePicture: user.profilePicture,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  // Show group list
  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  //
  Stream<List<Group>> getAllChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());
        groups.add(group);
      }
      return groups;
    });
  }

  //Show messages (personal)
  Stream<List<MessageModel>> getChatStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var document in event.docs) {
        messages.add(MessageModel.fromMap(document.data()));
      }
      return messages;
    });
  }

  // Show group messages
  Stream<List<MessageModel>> getGroupChatStream(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var document in event.docs) {
        messages.add(MessageModel.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timeSent,
    String receiverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(receiverUserId).update(
        {
          'lastMessage': text,
          'timeSent': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } else {
      // users -> receiver user id => chats -> current user id -> set data
      var receiverChatContact = ChatContact(
        name: senderUserData.name,
        profilePicture: senderUserData.profilePicture,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .set(receiverChatContact.toMap());

      // users -> current user id => chats ->  receiver user id -> set data
      var senderChatContact = ChatContact(
        name: receiverUserData!.name,
        profilePicture: receiverUserData.profilePicture,
        contactId: receiverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .set(
            senderChatContact.toMap(),
          );
    }
  }

  void _saveMessageToMessageSubcollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? receiverUserName,
    required bool isGroupChat,
  }) async {
    final message = MessageModel(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : receiverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );

    // groups -> group id > Chat > messages
    if (isGroupChat) {
      await firestore
          .collection('groups')
          .doc(receiverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
// users -> sender id > receiver id > messages > message id > storage message
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
      // users -> receiver id > sender id > messages > message id > storage message
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    // users > sender id > receiver id > message > message id > storage
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        text,
        timeSent,
        receiverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        receiverUserName: receiverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );


      final timesent = DateTime.now();
      final ref = firestore.collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages');

      await ref.doc(timesent.toString()).set({
        'messageId': messageId,
        'text': text,
        'senderUser': senderUser.toMap(),
        'receiverUser': receiverUserData!.toMap(),
      }).then((value) => pushNotification(
          existingUser: senderUser,
          receiverUser: receiverUserData!,
          text: text));
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String? imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
            file,
          );
      // receiverUserData = UserModel.fromMap(userDataMap.data()!);
      UserModel? receiverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        if (userDataMap.data() != null) {
          receiverUserData = UserModel.fromMap(userDataMap.data()!);
        }
      }
      // var userDataMap =
      //     await firestore.collection('users').doc('receiverUserId').get();
      // // receiverUserData = UserModel.fromMap(userDataMap.data()!);

      // su dung dc
      /* var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      if (userDataMap.data() != null) {
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }*/

      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;

        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;

        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;

        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;

        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubcollection(
        senderUserData,
        receiverUserData!,
        contactMsg,
        timeSent,
        receiverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        receiverUserName: receiverUserData.name,
        senderUsername: senderUserData.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIF({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    // users > sender id > receiver id > message > message id > storage
    try {
      var timeSent = DateTime.now();
      UserModel? receiverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        receiverUserData,
        'GIF',
        timeSent,
        receiverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        receiverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageType: MessageEnum.gif,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        receiverUserName: receiverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  //************* Function (delete) *************//

  // Hide chat contact, - contact list
  void hideChatContact(String receiverUserId) async {
    final contactId = auth.currentUser!.uid;
    await firestore
        .collection('users')
        .doc(contactId)
        .collection('chats')
        .doc(receiverUserId)
        .delete();
  }

//delete chat contact & all sender messages - contact list
  Future<void> deleteChatContactMess(String receiverUserId) async {
    final contactId = auth.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(contactId)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(contactId)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .get();

    if (querySnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(contactId)
          .collection('chats')
          .doc(receiverUserId)
          .delete();
    }
  }

  //delete all sender messages - contact list
  Future<void> deleteAllPrivateChats(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  // Only delete your messages - list chat
  void deleteSenderMessages(String receiverUserId, String messageId) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  //************ Group ********//

  //Delete both group and message
  Future<void> deleteGroupChats(String groupId) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .get();

    if (querySnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .delete();
    }
  }

  // Delete Group Chat for all messages in a group
  Future<void> deleteGroupChat(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
} // class ChatRepository
