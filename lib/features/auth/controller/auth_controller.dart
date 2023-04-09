// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatsma_flutter/features/auth/repository/auth_repository.dart';
import '../../../models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

  //Persisting Auth state (2) n2
  final userDataAuthProvider = FutureProvider((ref) {
    final authController = ref.watch(authControllerProvider);
    return authController.getUserData();

  });

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({
    required this.authRepository,
    required this.ref,
  });

  //Persisting Auth state (2) n1
  Future <UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void verifyOTP(BuildContext context, String verificationId, String userOTP) {
    authRepository.verifyOTP(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  void saveUserDataToFirebase(
      BuildContext context, String name, File? profilePicture) {
    authRepository.saveUserDataToFirebase(
        name: name, profilePicture: profilePicture, ref: ref, context: context);
  }

   Stream<UserModel>userDataById(String userId) {
    return authRepository.userData(userId);
   }

  // Changing Online/Offline Status (3) n1
  void setUserState (bool isOnline) async {
    authRepository.setUserState(isOnline);
  }

}
