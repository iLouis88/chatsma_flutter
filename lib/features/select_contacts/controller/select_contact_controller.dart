import 'package:chatsma_flutter/features/select_contacts/repository/select_contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


    final getContactsProvider = FutureProvider ((ref){
        final selectContactRepository = ref.watch(selectContactsRepositoryProvider);
         return selectContactRepository.getContacts();
    });

//Displaying Contacts in User’s Phone (2) n4
    final selectContactControllerProvider = Provider((ref){
      final selectContactRepository = ref.watch(selectContactsRepositoryProvider);
      return SelectContactController(
        ref: ref,
        selectContactRepository: selectContactRepository,
      );
    });

//Displaying Contacts in User’s Phone (2) n2
    class SelectContactController {
      final ProviderRef ref;
      final SelectContactRepository selectContactRepository;
      SelectContactController({
        required this.ref,
        required this.selectContactRepository,
      });
//Displaying Contacts in User’s Phone (2) n3
      void selectContact(Contact selectedContact, BuildContext context){
        selectContactRepository.selectContact(selectedContact, context);
      }

    }

// Displaying Contacts in User’s Phone (2) n1