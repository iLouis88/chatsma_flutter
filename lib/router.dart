import 'dart:io';

import 'package:chatsma_flutter/common/widgets/error.dart';
import 'package:chatsma_flutter/features/auth/screens/home_test.dart';
import 'package:chatsma_flutter/features/auth/screens/user_information_screen.dart';
import 'package:chatsma_flutter/features/chat/screens/mobile_chat_screen.dart';
import 'package:chatsma_flutter/features/group/screens/create_group_screen.dart';
import 'package:chatsma_flutter/features/status/screens/confirm_status_screen.dart';
import 'package:chatsma_flutter/features/status/screens/status_screen.dart';
import 'package:chatsma_flutter/select_contacts/screens/select_contact_screen.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/login_screen2.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/screens/otp_screen2.dart';
import 'models/status_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );

    case LoginScreen2.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen2(),
      );

    case OTPScreen2.routeName:
      return MaterialPageRoute(
        builder: (context) => const OTPScreen2(),
      );
    case HomeTest.routeName:
      return MaterialPageRoute(
        builder: (context) => const HomeTest(),
      );

    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );

    case UserInformationScreen.routeName:
      // final  verificationId  = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      );

    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactsScreen(),
      );

    case MobileChatScreen.routeName:
      final argruments = settings.arguments as  Map<String, dynamic>;
      final name = argruments['name'];
      final uid = argruments['uid'];
      final isGroupChat = argruments['isGroupChat'];
      final profilePicture = argruments['profilePicture'];

      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePicture: profilePicture,
        ),
      );


    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
        builder: (context) => ConfirmStatusScreen(
          file: file,
        ),
      );

    case StatusScreen.routeName:
      final status = settings.arguments as Status;
      return MaterialPageRoute(
        builder: (context) => StatusScreen(
          status: status ,
        ),
      );

    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
            body: ErrorScreen(error: 'This page doesn\'t exist')),
      );
  }
}
