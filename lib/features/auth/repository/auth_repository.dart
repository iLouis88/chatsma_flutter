import 'dart:developer';
import 'dart:io';

import 'package:chatsma_flutter/common/repositories/common_firebase_storage_repository.dart';
import 'package:chatsma_flutter/features/auth/screens/login_screen.dart';
import 'package:chatsma_flutter/features/auth/screens/otp_screen.dart';
import 'package:chatsma_flutter/features/auth/screens/signin_screens.dart';
import 'package:chatsma_flutter/features/auth/screens/user_information_screen.dart';
import 'package:chatsma_flutter/features/landing/screens/landing_screen.dart';
import 'package:chatsma_flutter/models/user_model.dart';
import 'package:chatsma_flutter/mobile_layout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    try {
      var userData =
      await firestore.collection('users').doc(auth.currentUser?.uid).get();

      UserModel? user;
      if (userData.data() != null) {
        user = UserModel.fromMap(userData.data()!);
        await getFMToken(existingUser: user);
      }
      return user;
    } catch (e){
      throw Exception(e.toString());
    }
  }

  signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
          scopes: <String>["email"]).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, get the User and save user data to Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final name = googleUser.displayName ?? '';
        final photoUrl = googleUser.photoUrl ?? '';
        final email = googleUser.email ?? '';
        final userData = UserModel(
          name: name,
          uid: user.uid,
          profilePicture: photoUrl,
          isOnline: true,
          phoneNumber: user.phoneNumber ?? '',
          email: email,
          groupId: [],
          notificationToken: '',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData.toMap());

        final nav = Navigator.of(context);
        nav.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MobileLayoutScreen(),
            ),
                (route) => false);
      }
    } catch(e) {
      showSnackBar(context: context, content: e.toString());
    }
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
/*      //update token
      UserModel existingUser = UserModel.fromFirebaseUser(auth.currentUser!);
      await getFMToken(existingUser: existingUser);*/
      navContext.pushNamedAndRemoveUntil(UserInformationScreen.routeName, (route) => false);
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
      final currentUser = auth.currentUser;
      if (currentUser == null) {
    // Handle if current user is null
        showSnackBar(
          context: context,
          content: 'NO USERS ARE LOGGED IN - User is null',
        );
        return;
      }

      String uid = currentUser.uid;
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
        phoneNumber: currentUser.phoneNumber ?? '',
        email: currentUser.email ?? '',
        groupId: [],
        notificationToken: '',
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
  Stream<UserModel>otherUserData(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }
// Changing Online/Offline Status (2) n1
    void setUserState (bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'isOnline' : isOnline,
    });
  }
  Future<void> logout(BuildContext context) async {
    try {
      // Sign out from Firebase
      await auth.signOut();
      // Sign out from Google
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      //await googleSignIn.disconnect();
      final nav = Navigator.of(context);
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SigninScreens()),
            (route) => false,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  // get and update token
  Future<void> getFMToken({required UserModel existingUser}) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

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
        await firestore.collection('users').doc(existingUser.uid).update(userMap);

        // Cập nhật notificationToken của User thông qua hàm setNotificationToken
        User? user = auth.currentUser!;
        getNotificationToken(user, token);

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

  void getNotificationToken(User? user, String token) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('users').doc(user!.uid).update({
      'notificationToken': token,
    });
  }



} //Class AuthRepository
