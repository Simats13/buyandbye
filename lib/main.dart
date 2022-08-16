import 'dart:async';
import 'package:buyandbye/templates/pages/page_accueil.dart';
import 'package:buyandbye/templates/widgets/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Connexion/Login/page_login.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/widgets/notification_controllers.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // ignore: avoid_print
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    badge: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
        Timer(const Duration(seconds: 2), () {
      if (FirebaseAuth.instance.currentUser != null) {
        // user already logged in ==> Home Screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Accueil()),
            (route) => false);
      } else {
        // user not logged ==> Login Screen
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PageLogin()),
              (route) => false);
      }
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    NotificationController.instance.initLocalNotification();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    super.initState();

    AuthMethods.instance.checkEmailVerification();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: <String, WidgetBuilder>{'/Accueil': (BuildContext context) => const PageAccueil()},
        title: "Buy&Bye",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
              builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()}),
          brightness: Brightness.light,
          // primaryColor: Colors.red,
        ),
        darkTheme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
              builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()}),
          brightness: Brightness.light,
          // additional settings go here
        ),
        home: const SplashScreen());
  }
}

// notifications(context, myID, myName, myProfilePic) {
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => ChatRoom(
//                 myID,
//                 myName,
//                 message.data["otherToken"],
//                 message.data["otherID"],
//                 message.data["chatroomid"],
//                 message.data["userName"],
//                 "",
//                 message.data["profilePic"],
//                 myProfilePic)));
//   });
// }

