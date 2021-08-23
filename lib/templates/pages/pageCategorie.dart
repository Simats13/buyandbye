import 'package:flutter/material.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

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
