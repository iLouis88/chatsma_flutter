import 'package:chatsma_flutter/common/widgets/custom_button.dart';
import 'package:chatsma_flutter/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/colors.dart';
import '../../auth/screens/login_screen2.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToLonginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }
  void navigateToLonginScreen2(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen2.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColorLanding,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text('Welcome to Chat SMA',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(height: size.height / 9),
              Image.asset('assets/bg_start.png', height: 340, width: 340,
              color: tabColor,
              ),
              SizedBox(height: size.height/9),
              const Padding(
                padding:  EdgeInsets.all(8.0),
                child:  Text('Read our Privacy Policy. Tap "Agree and Continue" to eccept the Terms of Service.',
                    style: TextStyle(
                    color: Colors.grey),
                    textAlign: TextAlign.center,
                ),
              ),
              const SizedBox (height: 10),
            SizedBox(
                width: size.width*0.75, // 3/4 cua man hinh chiem
                child: CustomButton(text: 'AGREE AND CONTINUE',
              onPressed: () => navigateToLonginScreen(context),
                ),),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}