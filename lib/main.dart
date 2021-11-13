import 'dart:async';
import 'dart:io';

import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/pageFirstConnection.dart';
import 'package:buyandbye/templates/pages/chatscreen.dart';
import 'package:buyandbye/templates/pages/pageBienvenue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/model/infowindow.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Pages/pageLogin.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/widgets/notificationControllers.dart';
import 'package:provider/provider.dart';
import 'templates_commercant/nav_bar.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    badge: true,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => InfoWindowsModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool checkEmailVerification = false;

  // Future _future = DatabaseMethods().getCart();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    NotificationController.instance.initLocalNotification();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _getFCMToken();
    super.initState();

    AuthMethods.instanace.checkEmailVerification();
  }

  Future<void> _getFCMToken() async {
    // Go to Firebase console -> Project settings -> Cloud Messaging -> Web Push Certificates -> create key pair -> copy and paste
    const yourVapidKey =
        "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA";
    String _fcmToken =
        await FirebaseMessaging.instance.getToken(vapidKey: yourVapidKey);
    print('_FCMToken is $_fcmToken');
    // here you write the codes to input the data into firestore

    if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print(
          "L'utilisateur a accepté les notifications : ${settings.authorizationStatus}");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Buy&Bye",
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //     primaryColor: buyandbyeAppTheme.black_electrik,
        //     scaffoldBackgroundColor: Colors.white),
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
          }),
          brightness: Brightness.light,
          // primaryColor: Colors.red,
        ),
        darkTheme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
          }),
          brightness: Brightness.light,
          // additional settings go here
        ),
        home: MainScreen());
  }
}

notifications(context, myID, myName, myProfilePic) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatRoom(
                myID,
                myName,
                message.data["otherToken"],
                message.data["otherID"],
                message.data["chatroomid"],
                message.data["userName"],
                "",
                message.data["profilePic"],
                myProfilePic)));
  });
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data.uid != null) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(snapshot.data.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData &&
                    snapshot.data['emailVerified'] != null) {
                  final user = snapshot.data;
                  if (user['emailVerified'] == false) {
                    return PageLogin();
                  }
                  if (user['firstConnection'] == true) {
                    return PageFirstConnection();
                  }
                  if (user['admin'] == true &&
                      user['firstConnection'] == true) {
                    return NavBar();
                  } else {
                    return Accueil();
                  }
                } else {
                  return PageLogin();
                }
              },
            );
          } else {
            return PageBienvenue();
          }
        });
  }
}

//   Widget build(BuildContext context) {
//     notifications(context, myID);
//     print(admin);
//     if (myID == null) {
//       return PageBienvenue();
//     } else if (admin == "true") {
//       return NavBar();
//     } else if (emailVerified == "false") {
//       return PageLogin();
//     } else {
//       return Accueil();
//     }
//   }
// }
