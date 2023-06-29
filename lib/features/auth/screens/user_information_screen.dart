import 'dart:io';
import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';

  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  File? image;

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Enter Information'),
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
              )),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    image == null
                        ? const CircleAvatar(
                            backgroundImage:  AssetImage('assets/avatar_or.png'),
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                          width: size.width * 0.85,
                          padding: const EdgeInsets.all(20),
                          child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: "Enter your name",
                              ))),
                    ),
                    IconButton(
                      onPressed: storeUserData,
                      icon: const Icon(Icons.done),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}
