import 'package:chatsma_flutter/common/widgets/error.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/features/landing/screens/landing_screen.dart';
import 'package:chatsma_flutter/firebase_options.dart';
import 'package:chatsma_flutter/router.dart';
import 'package:chatsma_flutter/mobile_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/widgets/loader.dart';
import 'features/auth/screens/login_screen2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // for conect firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( const ProviderScope(
    child: MyApp(),
  ),);
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat SMA',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
        //Persisting Auth state (3) n1
            home: ref.watch(userDataAuthProvider).when(data: (user) {
              if(user == null) {
                return const LandingScreen();
              }
              return const MobileLayoutScreen();
            },
               error: (err, trace) {
               return ErrorScreen(error: err.toString(), );

            }, loading: () => const Loader(),),
            // home: const LandingScreen(),
           //    home: const LoginScreen2()

      /* const ResponsiveLayout(
        mobileScreenLayout: MobileLayoutScreen(),
        webScreenLayout: WebLayoutScreen(),
      ),*/
    );
  }
}
