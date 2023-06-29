import 'dart:io';
import 'package:chatsma_flutter/common/repositories/common_firebase_storage_repository.dart';
import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/models/status_model.dart';
import 'package:chatsma_flutter/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus({
    required String username,
    required String profilePicture,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      final statusId = const Uuid().v1();
      final uid = auth.currentUser!.uid;
      final imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            '/status/$statusId$uid',
            statusImage,
          );

      final contacts = await getContacts();
      final uidWhoCanSee = await getUidWhoCanSee(contacts);
      final statusImageUrls = await getStatusImageUrls(imageUrl);

      final status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePicture: profilePicture,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      await saveStatusToFirestore(status);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      return FlutterContacts.getContacts(withProperties: true);
    }
    return [];
  }

  Future<List<String>> getUidWhoCanSee(List<Contact> contacts) async {
    final uidWhoCanSee = <String>[];

    for (final contact in contacts) {
      final phoneNumber = contact.phones[0].number.replaceAll(' ', '');

      final userDataFirebase = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (userDataFirebase.docs.isNotEmpty) {
        final userData = UserModel.fromMap(userDataFirebase.docs.first.data());
        uidWhoCanSee.add(userData.uid);
      }
    }

    return uidWhoCanSee;
  }

  Future<List<String>> getStatusImageUrls(String imageUrl) async {
    final statusImageUrls = <String>[];
    final statusesSnapshot = await firestore
        .collection('status')
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get();

    if (statusesSnapshot.docs.isNotEmpty) {
      final status = Status.fromMap(statusesSnapshot.docs.first.data());
      statusImageUrls.addAll(status.photoUrl);
      statusImageUrls.add(imageUrl);
      await firestore
          .collection('status')
          .doc(statusesSnapshot.docs.first.id)
          .update({'photoUrl': statusImageUrls});
    } else {
      statusImageUrls.add(imageUrl);
    }

    return statusImageUrls;
  }

  Future<void> saveStatusToFirestore(Status status) {
    return firestore.collection('status').doc(status.statusId).set(status.toMap());
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnapshot = await firestore
            .collection('status')
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();
        for (var tempData in statusesSnapshot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }
}
