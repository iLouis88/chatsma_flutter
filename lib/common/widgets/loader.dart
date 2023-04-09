import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return const Center(
      child: CircularProgressIndicator(
        backgroundColor: tabColor,
        color: Colors.white,
      ),
    );
  }
}

