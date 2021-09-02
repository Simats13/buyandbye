import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:buyandbye/model/infowindow.dart';
import 'package:buyandbye/services/auth.dart';

import 'package:buyandbye/templates/Pages/pageLogin.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/widgets/notificationControllers.dart';
import 'package:provider/provider.dart';
import 'templates/Pages/pageBienvenue.dart';
import 'templates_commercant/nav_bar.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();

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
    Geolocator.getCurrentPosition();
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
        title: "Buy & Bye",
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //     primaryColor: buyandbyeAppTheme.black_electrik,
        //     scaffoldBackgroundColor: Colors.white),
        theme: ThemeData(
          brightness: Brightness.light,
          // primaryColor: Colors.red,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          // additional settings go here
        ),
        home: MainScreen());
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(snapshot.data.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  final userDoc = snapshot.data;
                  final user = userDoc;
                  if (user['emailVerified'] == false) {
                    return PageLogin();
                  }
                  if (user['admin'] == true) {
                    return NavBar();
                  } else {
                    return Accueil();
                  }
                } else {
                  return PageLogin();
                }
              },
            );
          }
          return PageLogin();
        });
  }
}
