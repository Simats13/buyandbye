import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/accueil.dart';
import 'package:oficihome/templates/pages/pageBienvenue.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/services/push_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationsManager();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: OficihomeAppTheme.black_electrik,
        scaffoldBackgroundColor: Colors.white
      ),
      home: FutureBuilder(
          future: AuthMethods().getCurrentUser(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Accueil();
            } else {
              return PageBievenue();
            }
          }),
    );
  }
}
