import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

class PageCategorie extends StatefulWidget {
  const PageCategorie(
      {Key key,
      this.img,
      this.name,
      this.description,
      this.adresse,
      this.categorie})
      : super(key: key);

  final String img, name, description, adresse, categorie;

  @override
  _PageCategorieState createState() => _PageCategorieState();
}

class _PageCategorieState extends State<PageCategorie> {
  List categoryList = [];
  // @override
  // void initState() {
  //   super.initState();
  //   fetchDatabaseList();
  // }

  // fetchDatabaseList() async {
  //   dynamic result = await DatabaseMethods().allProductsCategory1();
  //   if (result == null) {
  //     showAlertDialog(context, "Erreur, veuillez réesayer ultérieurement");
  //   } else {
  //     setState(() {
  //       categoryList = result;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catégorie"),
        automaticallyImplyLeading: false,
        backgroundColor: BuyandByeAppTheme.black_electrik,
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return FutureBuilder(
        future: DatabaseMethods()
            .allProductsCategory(widget.categorie),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Center(
                    child: Container(
                  child: Center(
                    child: Text(
                      snapshot.data.docs[index]["nom"],
                      style: TextStyle(color: BuyandByeAppTheme.white),
                    ),
                  ),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: BuyandByeAppTheme.orange),
                ));
              });
        });
  }
}
