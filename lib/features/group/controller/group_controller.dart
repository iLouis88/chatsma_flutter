import 'dart:io';

import 'package:chatsma_flutter/features/group/repository/group_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/group.dart' as model;
import '../../../models/group.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(groupRepository: groupRepository, ref: ref);
});

class GroupController extends StateNotifier<Group> {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController( {
    required this.groupRepository,
    required this.ref,
  }) : super( model.Group(
  senderId: '',
    name: '',
    groupId: 'groupId',
    lastMessage: '',
    groupPicture: 'profileUrl',
    membersUid: [],
    timeSent: DateTime.now(),
    notificationTokens: [],));

  void createGroup(BuildContext context, String name, File profilePicture,
      List<Contact> selectedContact) {
    groupRepository.createGroup(context, name, profilePicture, selectedContact);
  }

  Future<void> addMemberByUidToGroup(String groupId, List<String> uids) async {
     groupRepository.addMemberByUidToGroup(groupId, uids);
  }

  void updateSelectedGroup(Group group) {
    state = group;
  }


}
