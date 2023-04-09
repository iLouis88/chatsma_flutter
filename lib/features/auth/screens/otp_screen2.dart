import 'package:chatsma_flutter/features/auth/screens/home_test.dart';
import 'package:chatsma_flutter/features/auth/screens/login_screen2.dart';
import 'package:chatsma_flutter/features/auth/screens/user_information_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/custom_button.dart';

class OTPScreen2 extends StatefulWidget {
  static const String routeName = '/otp-screen2';
  const OTPScreen2({
    Key? key,
  }) : super(key: key);

  @override
  State<OTPScreen2> createState() => _OTPScreen2State();
}

class _OTPScreen2State extends State<OTPScreen2> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    var code = "";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ))),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_signin.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 25),
              const Text('Verify phone number',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 10),
              const Text(
                'We need to register your phone before  getting started!',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Pinput(
                length: 6,
                // pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
              ),

              // the same VerifyOTP
              const SizedBox(height: 20),
              SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () async {
                    try{
                      // Create a PhoneAuthCredential with the code
                      PhoneAuthCredential credential =
                      PhoneAuthProvider.credential(
                          verificationId: LoginScreen2.verify,
                          smsCode: code);
                      // Sign the user in (or link) with the credential
                      await auth.signInWithCredential(credential);
                      Navigator.pushNamedAndRemoveUntil(context, HomeTest.routeName, (route) => false);
                    } catch(e){
                      debugPrint("Error occurred during sign in with OTP: $e");
                      showSnackBar(
                        context: context,
                        content: "An unexpected error occurred.",
                      );
                    }
                  },
                     text: 'Verify phone number',
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginScreen2.routeName, (route) => false);
                      },
                      child: const Text('Edit Phone Number',
                          style: TextStyle(
                            color: Colors.green,
                          ))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
