import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oficihome/json/menu_json.dart';
import 'package:oficihome/templates/Connexion/Login/background_login.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/theme/colors.dart';
import 'package:oficihome/theme/styles.dart';
import 'package:oficihome/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PageCategorie extends StatefulWidget {
  const PageCategorie(
      {Key key, this.img, this.name, this.description, this.adresse})
      : super(key: key);

  final String img, name, description, adresse;

  @override
  _PageCategorieState createState() => _PageCategorieState();
}

class _PageCategorieState extends State<PageCategorie> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catégorie"),
        automaticallyImplyLeading: false,
        backgroundColor: OficihomeAppTheme.black_electrik,
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return Center(
        child: Container(
      child: Center(
        child: Text(
          "OFICI'HOME",
          style: TextStyle(color: OficihomeAppTheme.white),
        ),
      ),
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: OficihomeAppTheme.orange),
    ));
  }
}
