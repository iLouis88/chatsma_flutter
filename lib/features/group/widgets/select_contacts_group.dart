import 'package:chatsma_flutter/common/widgets/error.dart';
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/select_contacts/controller/select_contact_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/utils.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {
Set<int> selectedContactsIndex = {};

void selectContact(int index, Contact contact) {
  if (!mounted) return; // Check if the widget is still displayed on the screen
  if (selectedContactsIndex.contains(index)) {
    selectedContactsIndex.remove(index);
  } else {
    selectedContactsIndex.add(index);
  }
  setState(() {});

  try {
    ref
        .read(selectedGroupContacts.notifier)
        .update((state) => [...state, contact]);
  } catch (e) {
    // Xử lý lỗi khi thêm contact không thành công
    print('Thêm contact không thành công: $e');
    showSnackBar(
      context: context,
      content: 'Thêm contact không thành công',
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactsProvider).when(
          data: (contactList) => Expanded(
            child: ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  final contact = contactList[index];
                  return InkWell(
                    onTap: () => selectContact(index, contact),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          contact.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: selectedContactsIndex.contains(index)
                            ? IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.done),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
          ),
          error: (err, trace) => ErrorScreen(
            error: err.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
