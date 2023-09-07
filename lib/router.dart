import 'dart:io';

import 'package:chatsma_flutter/common/screens/search_screen.dart';
import 'package:chatsma_flutter/common/widgets/error.dart';
/*import 'package:chatsma_flutter/features/auth/screens/signin_screens.dart';*/
import 'package:chatsma_flutter/features/auth/screens/user_information_screen.dart';
import 'package:chatsma_flutter/features/chat/screens/mobile_chat_screen.dart';
import 'package:chatsma_flutter/features/group/screens/create_group_screen.dart';
import 'package:chatsma_flutter/features/select_contacts/screens/select_contact_screen.dart';
import 'package:chatsma_flutter/features/status/screens/confirm_status_screen.dart';
import 'package:chatsma_flutter/features/status/screens/status_screen.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/other_profile_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/auth/widgets/edit_profile_screen.dart';

/*import 'features/group/widgets/add_member_page.dart';*/
import 'models/group.dart';
import 'models/status_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );

  /*  case SigninScreens.routeName:
      return MaterialPageRoute(
        builder: (context) => const SigninScreens(),
      );*/

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
/*
    case AddMemberPage.routeName:
      return MaterialPageRoute(
        builder: (context) => const AddMemberPage(),
      );*/

    case ProfileScreen.routeName:
    // final  verificationId  = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );

    case EditProfileScreen.routeName:
    // final  verificationId  = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      );

    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactsScreen(),
      );

    case SearchScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      );

    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isGroupChat = arguments['isGroupChat'];
      final profilePicture = arguments['profilePicture'];
      final groupId = arguments['groupId'];


      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePicture: profilePicture,
          groupId : groupId,

        ),
      );

    case OtherProfileScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isGroupChat = arguments['isGroupChat'];
      final profilePicture = arguments['profilePicture'];
      final groupId = arguments['groupId'];


      return MaterialPageRoute(
        builder: (context) => OtherProfileScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePicture: profilePicture,
          groupId : groupId,

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
