import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/model/utilisateur.dart';
import 'package:oficihome/services/authentification.dart';
import 'package:oficihome/templates/loginPage1.dart';
import 'package:oficihome/templates/widgets/passerelle.dart';
import 'package:oficihome/templates/widgets/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Utilisateur>.value(
      value: ServiceAuth().utilisateur,
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        routes: {
          '/passerelle': (context) => Passerelle(),
        },
      ),
    );
  }
}
