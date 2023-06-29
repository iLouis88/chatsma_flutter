import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:chatsma_flutter/common/widgets/loader.dart';
import 'package:chatsma_flutter/features/status/controller/status_controller.dart';
import 'package:chatsma_flutter/features/status/screens/status_screen.dart';
import 'package:chatsma_flutter/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusContactsScreen extends ConsumerWidget {
  const StatusContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: FutureBuilder<List<Status>>(
        future: ref.read(statusControllerProvider).getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var statusData = snapshot.data![index];
            return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          StatusScreen.routeName,
                          arguments: statusData,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ListTile(
                          title: Text(
                            statusData.username,
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              statusData.profilePicture,
                            ),
                            radius: 30,
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: dividerColor, indent: 85),
                  ],
              );
            },
          );
        },
      ),
    );
  }
}
