import 'dart:developer';

import 'package:chatsma_flutter/common/widgets/error.dart';
import 'package:chatsma_flutter/features/auth/controller/auth_controller.dart';
import 'package:chatsma_flutter/common/widgets/notification_service.dart';
import 'package:chatsma_flutter/features/landing/screens/landing_screen.dart';
import 'package:chatsma_flutter/firebase_options.dart';
import 'package:chatsma_flutter/models/message.dart';
import 'package:chatsma_flutter/router.dart';
import 'package:chatsma_flutter/mobile_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chatsma_flutter/common/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/widgets/loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase App ở đây
  try {
    await NotificationService().init();
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  Widget build(BuildContext context) {
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

