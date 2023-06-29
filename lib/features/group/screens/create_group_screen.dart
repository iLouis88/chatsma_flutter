import 'dart:io';

import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/features/group/controller/group_controller.dart';
import 'package:chatsma_flutter/features/group/widgets/select_contacts_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  TextEditingController groupNameController = TextEditingController();
  File? image;

  selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
        context,
        groupNameController.text.trim(),
        image!,
        ref.read(selectedGroupContacts.notifier).state, // Thay đổi ở đây
      );
      ref.read(selectedGroupContacts.notifier).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Group',
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar_or.png'),
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Group Name',
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10.0),
              child: const Text('Select Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const SelectContactsGroup(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
