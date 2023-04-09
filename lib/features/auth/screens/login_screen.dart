import 'package:chatsma_flutter/common/utils/utils.dart';
import 'package:chatsma_flutter/common/widgets/custom_button.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  TextEditingController countryCode = TextEditingController();


  Country? country;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    phoneController.dispose();

  }
  void initState() {
    // TODO: implement initState
    countryCode.text= ("+84");

    super.initState();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['+84', 'VN'],
      onSelect: (Country _country) {
        setState(() {
          country = _country;
        });
      },
    );
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');

    } else {
      showSnackBar(context: context, content: 'Fill out on the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        elevation: 0,
        backgroundColor: backgroundColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded, color: Colors.black,
              )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Verify your phone number'),
              const SizedBox(height: 10),

              TextButton(
                onPressed: pickCountry,
                child: const Text('Select Country'),
              ),
              const SizedBox(height: 10),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    if (country != null) Text('+${country!.phoneCode}'),
                    const SizedBox(
                      width: 10,
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "+84",
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value){
                        },
                        controller: phoneController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "phone number"),),
                    ),
                  ],
                ),
              ),

              // Row(
              //   //Ma quoc gia & feild nhap sdt
              //   children: [
              //
              //
              //     const SizedBox(width: 10),
              //     SizedBox(
              //       width: size.width * 0.7,
              //       child: TextField(
              //         controller: phoneController,
              //         decoration: const InputDecoration(
              //           hintText: 'phone number',
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // SizedBox(height: size.height * 0.6), // button
              const SizedBox(height: 20),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: CustomButton(
                  onPressed: sendPhoneNumber,
                  text: 'NEXT',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
