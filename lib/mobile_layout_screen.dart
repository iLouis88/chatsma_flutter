import 'dart:io';

import 'package:chatsma_flutter/common/utils/utils.dart';

import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/features/auth/widgets/edit_profile_screen.dart';
import 'package:chatsma_flutter/features/group/screens/create_group_screen.dart';
import 'package:chatsma_flutter/features/select_contacts/screens/select_contact_screen.dart';
import 'package:chatsma_flutter/features/status/screens/confirm_status_screen.dart';
import 'package:chatsma_flutter/features/status/screens/status_contacts_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:chatsma_flutter/features/chat/widgets/contacts_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/screens/search_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/call/screens/call_pickup_screen.dart';
import 'features/group/widgets/add_member_page.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;

  // Changing Online/Offline Status (1) n2
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  // Changing Online/Offline Status (1) n1
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> iconPaths = [
      "assets/icons/chat_1.png",
      "assets/icons/status_1.png",
    ];

    return DefaultTabController(
      length: 3,
      child: CallPickupScreen(
        scaffold: Scaffold(
          body: _TabBarView(tabBarController: tabBarController),
          bottomNavigationBar: Material(
            color: Colors.white,
            elevation: 4,
            child: TabBar(
              controller: tabBarController,
              indicatorColor: tabColor,
              indicatorWeight: 4,
              labelColor: tabColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(
                  icon: ImageIcon(
                    AssetImage(iconPaths[0]),
                  ),
                ),
                Tab(
                  icon: ImageIcon(
                    AssetImage(iconPaths[1]),
                  ),
                ),
                const Tab(
                  icon: Icon(Icons.person_pin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarView extends ConsumerStatefulWidget {
  const _TabBarView({
    super.key,
    required this.tabBarController,
  });
  final TabController tabBarController;

  @override
  ConsumerState<_TabBarView> createState() => _TabBarViewState();
}

class _TabBarViewState extends ConsumerState<_TabBarView> {
  void signOut(BuildContext context) {
    ref.read(authControllerProvider).logout(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabBarController,
      children: [
        // Chat tab
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: appBarColor,
            centerTitle: true,
            title: const Text(
              'Chat SMA',
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
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: tabColor,
                  ),
                  child: Text(
                    'Chat SMA',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Edit Profile'),
                  leading: const Icon(Icons.person_pin_circle_rounded),
                  onTap: () {
                    Future(() =>
                        Navigator.pushNamed(context, ProfileScreen.routeName));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Create a new Group'),
                  leading: const Icon(Icons.groups),
                  onTap: () {
                    Future(() => Navigator.pushNamed(
                        context, CreateGroupScreen.routeName));
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  title: const Text('Add member to group'),
                  leading: const Icon(Icons.group_add_sharp),
                  onTap: () {
                    Future(() => Navigator.pushNamed(
                        context, AddMemberPage.routeName));
                    Navigator.pop(context);
                  },
                ),

                const Divider(),
                ListTile(
                  title: const Text('Sign out'),
                  leading: const Icon(Icons.output_rounded),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Sign Out'),
                          content:
                              const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('SIGN OUT'),
                            ),
                          ],
                        );
                      },
                    ).then((value) {
                      if (value == true) {
                        signOut(context);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          body: const ContactsList(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, SelectContactsScreen.routeName);
            },
            backgroundColor: tabColor,
            child: const Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: appBarColor,
            centerTitle: false,
            title: const Text(
              'Status',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              /*    IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),*/
            ],
          ),
          body: const StatusContactsScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                Navigator.pushNamed(
                  context,
                  ConfirmStatusScreen.routeName,
                  arguments: pickedImage,
                );
              }
            },
            backgroundColor: tabColor,
            child: const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
            ),
          ),
        ),

        const Scaffold(
          body: Center(
            child: ProfileScreen(),
          ),
        ),
      ],
    );
  }
}
