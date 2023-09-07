import 'package:chatsma_flutter/common/widgets/custom_button.dart';
import 'package:chatsma_flutter/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../common/utils/colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToSignInScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
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
              const SizedBox(height: 30),
              Column(
                children: const [
                  Text('Chat SMA',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                  Text('The new world, bringing you new experiences',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              SizedBox(height: size.height / 30),
              Image.asset(
                'assets/images/logo_start.png',
                height: 340,
                width: 340,
              ),
              SizedBox(height: size.height / 15),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Read our Privacy Policy. Tap "Agree and Continue" to accept the Terms of Service.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      const Size(270, 43),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () => navigateToSignInScreen(context),
                  child: const Text(
                    'Agree & Continue',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),

                /*child: SizedBox(
                  width: size.width*0.75, // 3/4 cua man hinh chiem
                  child: CustomButton(text: 'AGREE AND CONTINUE',
                onPressed: () => navigateToLonginScreen(context),
                  ),),*/
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
