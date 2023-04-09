import 'package:chatsma_flutter/common/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'otp_screen2.dart';

class LoginScreen2 extends StatefulWidget {
  static const routeName = '/login-screen2';
  const LoginScreen2({Key? key}) : super(key: key);

  static String verify ="";

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}


void navigateToOTPScreen2(BuildContext context) {
  Navigator.pushNamed(context, OTPScreen2.routeName);
}

class _LoginScreen2State extends State<LoginScreen2> {

  TextEditingController countrycode = TextEditingController();
  var phone = "";
  @override
  void initState() {
    // TODO: implement initState
    countrycode.text= ("+84");

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              const Text('Phone Verification',
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

              //field nhap lieu sdt va ma quoc gia
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countrycode,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value){
                          phone = value;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Your phone number"),),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // = void voidSignWithPhone, xac minh de qua trang otp
              SizedBox(
                  height: 45,
                  width: double.infinity,
                 child: CustomButton(
                   onPressed: () async{

                     await FirebaseAuth.instance.verifyPhoneNumber(
                       phoneNumber: '${countrycode.text+phone}',
                       verificationCompleted: (PhoneAuthCredential credential) {},
                       verificationFailed: (FirebaseAuthException e) {},
                       codeSent: (String verificationId, int? resendToken) {
                         LoginScreen2.verify = verificationId;
                         Navigator.pushNamed(context, OTPScreen2.routeName);
                       },
                       codeAutoRetrievalTimeout: (String verificationId) {},
                     );
                   },
                   text: 'Send the code',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
