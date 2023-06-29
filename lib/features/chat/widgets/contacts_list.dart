import 'package:chatsma_flutter/features/chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/features/chat/screens/mobile_chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/loader.dart';
import '../../../models/chat_contact.dart';
import '../../../models/group.dart';


class ContactsList extends ConsumerWidget {
  const ContactsList({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context, WidgetRef ref) {



    void hideChatContact (String receiverUserId) {
      ref.read(chatControllerProvider).hideChatContact(receiverUserId);
    }
    void deleteChatContactMess (String receiverUserId) {
      ref.read(chatControllerProvider).deleteChatContactMess( receiverUserId );
    }

    void deleteGroupChats(String groupId) {
      ref.read(chatControllerProvider).deleteGroupChats(groupId);
    }

    void deleteGroupChat(String groupId) {
      ref.read(chatControllerProvider).deleteGroupChat(groupId);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<Group>>(
                stream: ref.watch(chatControllerProvider).chatGroups(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var groupData = snapshot.data![index];

                      return Column(
                        children: [
                          Slidable(
                            key: Key(groupData.groupId[index]),
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  // An action can be bigger than the others.
                                  onPressed: (context) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text(
                                              'Are you sure you want to delete this group messages?(Only messages)'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteGroupChat(groupData.groupId);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_forever_outlined,
                                  label: 'Delete M',
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text(
                                              'Are you sure you want to delete this conversation?(Group & message)'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteGroupChats(
                                                    groupData.groupId);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red),),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_sharp,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  MobileChatScreen.routeName,
                                  arguments: {
                                    'name': groupData.name,
                                    'uid': groupData.groupId,
                                    'isGroupChat': true,
                                    'profilePicture': groupData.groupPicture,
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: ListTile(
                                  title: Text(
                                    groupData.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      groupData.lastMessage,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      groupData.groupPicture,
                                    ),
                                    radius: 30,
                                  ),
                                  trailing: Column(
                                    children: [
                                      const Icon(Icons.groups,
                                          color: Colors.black),
                                      Text(
                                        DateFormat.Hm()
                                            .format(groupData.timeSent),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ),
                        //  const Divider(color: iconColor, indent: 85),
                        ],
                      );
                    },
                  );
                }),


            StreamBuilder<List<ChatContact>>(
                stream: ref.watch(chatControllerProvider).chatContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];



                      return Column(
                        children: [
                          Slidable(
                            key: Key(chatContactData.contactId[index]),
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  // An action can be bigger than the others.
                                  onPressed: (context) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text(
                                              'Are you sure you want to hide this contact?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                hideChatContact(chatContactData.contactId);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Ok',
                                                style: TextStyle(
                                                    color: Colors.black,),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  icon: Icons.hide_source_rounded,
                                  label: 'Hide',
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: const Text(
                                              'Are you sure you want to delete this conversation?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteChatContactMess(
                                                    chatContactData.contactId);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red),),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_sharp,
                                  label: 'Delete',
                                ),
                              ],
                            ),

                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, MobileChatScreen.routeName,
                                    arguments: {
                                      'name': chatContactData.name,
                                      'uid': chatContactData.contactId,
                                      'isGroupChat': false,
                                      'profilePicture':
                                          chatContactData.profilePicture,
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: ListTile(
                                  title: Text(
                                    chatContactData.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      chatContactData.lastMessage,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      chatContactData.profilePicture,
                                    ),
                                    radius: 30,
                                  ),
                                  trailing: Text(
                                    DateFormat.Hm().format(
                                        chatContactData.timeSent), // package Inlt
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ),
                         // const Divider(color: iconColor, indent: 85),
                        ],
                      );
                    },
                  );

                }),
          ],
        ),
      ),
    );
  }
}
