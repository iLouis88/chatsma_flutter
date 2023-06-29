import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatsma_flutter/common/repositories/common_firebase_storage_repository.dart';
import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/models/group.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../config/notification_config.dart';
import '../../../models/user_model.dart';

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
 // Initialize the groupId variable to null
  ),
);

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository({
    required this.firestore,
    required this.auth,
    required this.ref,

  });

  get context => 'Error';

  Future<void> addMemberByUidToGroup(String groupId, List<String> uids) async {
    try {
      var groupDocRef = firestore.collection('groups').doc(groupId);
      await firestore.runTransaction((transaction) async {
        var groupDocSnapshot = await transaction.get(groupDocRef);
        if (!groupDocSnapshot.exists) {
          throw 'Group does not exist';
        }
        var groupData = groupDocSnapshot.data();
        if (groupData == null) {
          throw 'Group data is null';
        }
        var membersUid = List<String>.from(groupData['membersUid'] ?? []);
          membersUid.addAll(uids);
        transaction.update(groupDocRef, {'membersUid': membersUid});
      });
      showSnackBar(context: context, content: 'Members added successfully');
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<void> pushNotification({
    required UserModel existingUser,
    required String groupId,
    required String text,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> usersSnapshot = await firestore
          .collection('users')
          .where('groupId', isEqualTo: groupId)
          .get();

      List notificationTokens =
      usersSnapshot.docs.map((doc) => doc.data()['notificationToken']).toList();

      final body = {
        "registration_ids": notificationTokens,
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


  void createGroup(BuildContext context, String name, File profilePicture,
      List<Contact> selectedContact) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .where(
              'phoneNumber',
              isEqualTo: selectedContact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
        }
      }
      var groupId = const Uuid().v1();

      String profileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'group/$groupId',
            profilePicture,
          );

      List<String> notificationTokens = [];
      for (int i = 0; i < uids.length; i++) {
        DocumentSnapshot userSnapshot = await firestore.collection("users").doc(uids[i]).get();
        String userNotificationToken = userSnapshot.get("notificationToken");
        notificationTokens.add(userNotificationToken);
      }
      notificationTokens.addAll(uids);

      model.Group group = model.Group(
        senderId: auth.currentUser!.uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPicture: profileUrl,
        membersUid: [auth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
        notificationTokens: notificationTokens,
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
      //await addMemberByUidToGroup(groupId, uids);

    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }



}
