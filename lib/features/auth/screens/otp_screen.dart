import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';


import 'login_screen.dart';

class OTPScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;

  const OTPScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    ref
        .read(authControllerProvider)
        .verifyOTP(context, verificationId, userOTP);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

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
                  Icons.arrow_back_ios_new_rounded, color: Colors.black,
                ))),
        body: Container(
          margin: const EdgeInsets.only(left: 25, right: 25, top: 60),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text('Verify phone number',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 10,
                ),
                const Text('We have sent a SMS with a code.'),

                const SizedBox(height: 30),
                Pinput(
                  length: 6,
                  // pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,

                  onChanged: (val) {
                    if (val != null && val.trim().length == 6) {
                      debugPrint('Verify OTP');
                      verifyOTP(ref, context, val.trim());
                    }
                    debugPrint('This function was run');

                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, LoginScreen.routeName, (route) => false);
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
        ));
  }
}
