import 'dart:async';
import 'dart:io';

import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/pageFirstConnection.dart';
import 'package:buyandbye/templates/pages/chatscreen.dart';
import 'package:buyandbye/templates/pages/pageBienvenue.dart';
import 'package:buyandbye/templates_commercant/nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/model/infowindow.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Connexion/Login/pageLogin.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/widgets/notificationControllers.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
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
  MyApp({Key? key}) : super(key: key);

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

    AuthMethods.instance.checkEmailVerification();
  }

  Future<void> _getFCMToken() async {
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

class MainScreen extends StatefulWidget {
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool? docExists;

  checkIfDocumentExists(uid) async {
    bool check = await DatabaseMethods().checkIfDocExists(uid);
    setState(() {
      docExists = check;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          // Si l'utilisateur existe et que son uid n'est pas nul
          if (snapshot.hasData && snapshot.data.uid != null) {
            // Si l'id n'existe pas dans la collection users, on vérifie dans celle des magasins
            checkIfDocumentExists(snapshot.data.uid);
            if (docExists == true) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(snapshot.data.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data;
                    if (user!['emailVerified'] == false) {
                      return PageLogin();
                    } else if (user['firstConnection'] == true) {
                      return PageFirstConnection();
                    } else {
                      return Accueil();
                    }
                  } else {
                    return PageLogin();
                  }
                },
              );
              //Recherche de l'id dans la table magasins
            } else {
              return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("magasins")
                      .doc(snapshot.data.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!['emailVerified'] == true) {
                        return NavBar();
                      } else {
                        return PageLogin();
                      }
                    } else {
                      return PageLogin();
                    }
                  });
            }
            // Si l'utilisateur n'existe pas ou que son uid est nul
          } else {
            return PageBienvenue();
          }
        });
  }
}
