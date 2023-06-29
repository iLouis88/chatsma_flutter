import 'dart:io';
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/auth/widgets/edit_profile_screen.dart';
import 'package:chatsma_flutter/features/chat/controller/chat_controller.dart';
import 'package:chatsma_flutter/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatsma_flutter/models/chat_contact.dart';

import '../../../common/screens/search_screen.dart';
import '../../../common/utils/colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/profile-screen';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String userId = FirebaseAuth.instance.currentUser!.uid;


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        centerTitle: false,
        title: const Text(
          'Setting',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, SearchScreen.routeName);
              /* showSearch(
                    context: context,
                    delegate: SearchWidget(),
                  );*/
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(

            child: StreamBuilder<UserModel>(
              stream: ref.watch(chatControllerProvider).getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userProfile = snapshot.data!;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, EditProfileScreen.routeName);
                    },
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            const SizedBox(width: 10,),
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                userProfile.profilePicture,
                              ),
                              radius: 27,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 19,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                 'Edit profile',
                                  style:  TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: Colors.grey
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
