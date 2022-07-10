import 'dart:async';

import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Connexion/Login/page_login.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/pages/page_bienvenue.dart';
import 'package:buyandbye/templates/pages/page_first_connection.dart';
import 'package:buyandbye/templates_commercant/nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
              MaterialPageRoute(builder: (_) => const PageBienvenue()),
              (route) => false);
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/splash.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 35,
            ),
            Image.asset('assets/logo/logo.png'),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
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
                      return const PageLogin();
                    } else if (user['firstConnection'] == true) {
                      return const PageFirstConnection();
                    } else {
                      return const Accueil();
                    }
                  } else {
                    return const PageLogin();
                  }
                },
              );
              // Recherche de l'id dans la table magasins
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
                        return const NavBar();
                      } else {
                        return const PageLogin();
                      }
                    } else {
                      return const PageLogin();
                    }
                  });
            }
            // Si l'utilisateur n'existe pas ou que son uid est nul
          } else {
            return const PageBienvenue();
          }
        });
  }
}
