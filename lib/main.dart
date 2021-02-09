import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/screens/signin.dart';
import 'package:oficihome/templates/accueil.dart';
import 'package:oficihome/templates/loginPage2.dart';
import 'package:oficihome/templates/loginPage1.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      ),
      home: FutureBuilder(
          future: AuthMethods().getCurrentUser(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Accueil();
            } else {
              return LoginPage1();
            }
          }),
    );
  }
}
