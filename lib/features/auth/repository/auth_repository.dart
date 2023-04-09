import 'dart:io';

import 'package:chatsma_flutter/common/repositories/common_firebase_storage_repository.dart';
import 'package:chatsma_flutter/features/auth/screens/otp_screen.dart';
import 'package:chatsma_flutter/features/auth/screens/user_information_screen.dart';
import 'package:chatsma_flutter/models/user_model.dart';
import 'package:chatsma_flutter/mobile_layout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/utils.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  final auth1 = FirebaseAuth.instance;

  //Persisting Auth state (1) n1
  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();

    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            throw Exception(e.message);
          },
          codeSent: ((String verificationId, int? resendToken) async {
            Navigator.pushNamed(context, OTPScreen.routeName,
                arguments: verificationId);
          }),
          codeAutoRetrievalTimeout: (String verificationId) async {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(
        context: context,
        content: e.message!,
      );
    }
  }

  //OTP Screen
  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    if (verificationId == null || verificationId.isEmpty) {
      debugPrint("Verification ID is null or empty.");
      return;
    }

    if (userOTP == null || userOTP.isEmpty) {
      debugPrint("User OTP is null or empty.");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      if (credential == null) {
        debugPrint("Credential is null.");
        showSnackBar(
          context: context,
          content: "Please enter the correct OTP.",
        );
        return;
      }
      //
      final navContext = Navigator.of(context);
      await auth.signInWithCredential(credential);
      navContext.pushNamedAndRemoveUntil(
        UserInformationScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(
        context: context,
        content: e.message!,
      );
    } catch (e) {
      debugPrint("Error occurred during sign in with OTP: $e");
      showSnackBar(
        context: context,
        content: "An unexpected error occurred.",
      );
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePicture,
    required ProviderRef ref,
    required BuildContext context
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = 'https://i.imgur.com/y292Gu7.jpeg';

      if (profilePicture != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePicture/$uid',
              profilePicture,
            );
      }
      var user = UserModel(
        name: name,
        uid: uid,
        profilePicture: photoUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
      );

      final nav = Navigator.of(context);
      await firestore.collection('users').doc(uid).set(user.toMap());
      nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MobileLayoutScreen(),
          ),
          (route) => false);
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  Stream<UserModel>userData(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

// Changing Online/Offline Status (2) n1
    void setUserState (bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'isOnline' : isOnline,
    });
  }
}
