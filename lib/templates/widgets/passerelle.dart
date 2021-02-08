import 'package:flutter/material.dart';
import 'package:oficihome/model/utilisateur.dart';
import 'package:oficihome/templates/loginPage1.dart';
import 'package:provider/provider.dart';
import 'package:oficihome/templates/accueil.dart';

class Passerelle extends StatefulWidget {
  @override
  _PasserelleState createState() => _PasserelleState();
}

class _PasserelleState extends State<Passerelle> {
  @override
  Widget build(BuildContext context) {
    final utilisateur = Provider.of<Utilisateur>(context);
    if (utilisateur == null) {
      return LoginPage1();
    } else {
      return Accueil();
    }
  }
}
