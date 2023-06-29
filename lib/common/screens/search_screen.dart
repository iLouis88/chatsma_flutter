import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/other_profile_screen.dart';
import '../../features/chat/screens/mobile_chat_screen.dart';


class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = '/search-screen';
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _results = [];

  Future<void> _search(String query) async {
    final List<Map<String, dynamic>> results = await searchContactsAndGroups(query);
    setState(() {
      _results = results;
    });
  }

  Future<List<Map<String, dynamic>>> searchContactsAndGroups(String query) async {
    final List<Map<String, dynamic>> results = [];

    // Search for contacts by name or phone number
    final contactQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();
    for (final doc in contactQuerySnapshot.docs) {
      final data = doc.data();
      results.add({
        'type': 'contactId',
        'id': data['uid'],
        'name': data['name'],
        'phoneNumber': data['phoneNumber'],
        'email': data['email'],
      });
    }

    // Search for groups by name
    final groupQuerySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isGreaterThanOrEqualTo: query.toUpperCase())
        .where('name', isLessThan: query + 'z')
        .get();
    for (final doc in groupQuerySnapshot.docs) {
      final data = doc.data();
      results.add({
        'type': 'groupId',
        'id': doc.id,
        'name': data['name'],
        'phoneNumber': data['phoneNumber'],
        'email': data['email']
      });
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: (query) => _search(query),
        ),
      ),
      body: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final result = _results[index];
          return ListTile(
            leading: result['type'] == 'contactId' ? const Icon(Icons.person) : const Icon(Icons.group),
            title: Text(result['name']),
            subtitle: result['type'] == 'contactId' ? Text(result['phoneNumber']) : null,
            onTap: () {
              Navigator.pushNamed(context, OtherProfileScreen.routeName, arguments: {
                'name': result['name'],
                'uid': result['id'],
                'isGroupChat': result['type'] == 'groupId',
                'profilePicture': result['type'] == 'contactId' ? result['profilePicture'] : null,
              });
            },
          );
        },
      ),
    );
  }
}