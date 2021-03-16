import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/model/infowindow.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/accueil.dart';
import 'package:oficihome/templates/pages/pageBienvenue.dart';
import 'package:oficihome/templates/widgets/notificationControllers.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
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
  @override
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    //NotificationController.instance.initLocalNotification();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _getFCMToken();
    super.initState();
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

      print('User granted permission: ${settings.authorizationStatus}');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ofici'Home",
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //     primaryColor: OficihomeAppTheme.black_electrik,
      //     scaffoldBackgroundColor: Colors.white),
      theme: ThemeData(
        brightness: Brightness.light,
        // primaryColor: Colors.red,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // additional settings go here
      ),
      home: FutureBuilder(
          future: AuthMethods().getCurrentUser(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.active) {
              User user = snapshot.data;
              if (user != null) {
                return Accueil();
              } else {
                return PageBievenue();
              }
            } else {
              return PageBievenue();
            }
          }),
    );
  }
}
