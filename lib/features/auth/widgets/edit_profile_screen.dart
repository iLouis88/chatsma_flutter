import 'dart:io';
import 'package:chatsma_flutter/common/widgets/custom_button.dart';
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/chat/controller/chat_controller.dart';
import 'package:chatsma_flutter/models/user_model.dart';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatsma_flutter/models/chat_contact.dart';

import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../controller/auth_controller.dart';
import '../screens/profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/edit-profile';

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  File? image;
  bool isEditing = false;
  bool isShowInfo = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserDataToFirebase(context, name, image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
/*      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
      ),*/
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: StreamBuilder<UserModel>(
              stream: ref.watch(chatControllerProvider).getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userProfile = snapshot.data!;

                  if (isEditing) {
                    nameController.text = userProfile.name;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back)),
                          ],
                        ),
                        Stack(
                          children: [
                            image == null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      userProfile.profilePicture,
                                    ),
                                    radius: 64,
                                  )
                                : CircleAvatar(
                                    backgroundImage: FileImage(
                                      image!,
                                    ),
                                    radius: 64,
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 90,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: iconColor,
                                ),
                                child: IconButton(
                                  onPressed: selectImage,
                                  icon: const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: size.width * 0.85,
                          padding: const EdgeInsets.all(20),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: "Enter your name",
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 100,
                          child: CustomButton(
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                storeUserData();
                              });
                            },
                            text: 'Save',
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_outlined,
                                )),
                            const SizedBox(width: 10),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                icon: const Icon(Icons.edit)),
                          ],
                        ),
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            userProfile.profilePicture,
                          ),
                          radius: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProfile.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.perm_identity_outlined,),
                                    const SizedBox(width: 10),
                                    Text(
                                      userProfile.uid,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        FlutterClipboard.copy( userProfile.uid).then((result) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text('UID copied')),
                                          );
                                        });
                                      },
                                      icon: const Icon(Icons.copy),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.mail_outline_rounded),
                                    const SizedBox(width: 10),
                                    Text(
                                      userProfile.email,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_android_rounded),
                                    const SizedBox(width: 10),
                                    Text(
                                      userProfile.phoneNumber,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
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
