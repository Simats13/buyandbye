import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates_commercant/produitsCommercant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';

// Retourne la liste des catégories où le commerçant a entré au moins un produit
List categoriesInDb(snapshot) {
  List categoriesList = [];
  // Pour chaque produit dans la bdd, ajoute le nom de la catégorie s'il n'est
  // pas déjà dans la liste
  for (var i = 0; i <= snapshot.data.docs.length - 1; i++) {
    String categoryName = snapshot.data.docs[i]["categorie"];
    if (!categoriesList.contains(categoryName)) {
      categoriesList.add(snapshot.data.docs[i]["categorie"]);
    }
  }
  return categoriesList;
}

class AccueilCommercant extends StatefulWidget {
  _AccueilCommercantState createState() => _AccueilCommercantState();
}

class _AccueilCommercantState extends State<AccueilCommercant> {
  String myID;
  String myName, myUserName, myEmail;
  String myProfilePic;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  // Récupère les informations de l'utilisateur courant dans la bdd
  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myName = "${querySnapshot.docs[0]["name"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    setState(() {});
  }

  // Cette première classe affiche l'image et le nom du commerçant
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Si l'image de profil n'est pas chargée
    if (myProfilePic == null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            // Affiche un message de chargement
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 20),
            Text("Chargement",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 30),
            Divider(thickness: 0.5, color: Colors.black),
          ],
        ),
      );
    } else {
      // Quand l'image est chargée
      return SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: 380,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                          offset: Offset(4, 4))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          myProfilePic,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 40, 0, 0),
                      child: Text('Bienvenue',
                          style: TextStyle(
                              fontSize: 20, color: BuyandByeAppTheme.orange)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Text(myName,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Image.asset(
                              'assets/icons/main.png',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ),
              SizedBox(height: 15),
              Container(
                height: size.height * 0.24,
                width: 380,
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.24,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(4, 4))
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Text('Votre solde',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(50, 43, 20, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                                child: Text('380.16 €',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Text(
                                "Ce mois-ci",
                                style: TextStyle(
                                    // color: white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(230, 43, 20, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                                child: Text('1527.61 €',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Text(
                                "Au Total",
                                style: TextStyle(
                                    // color: white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 380,
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.35,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(4, 4))
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Text('Vos Statistiques',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Image.asset('assets/images/charts.png'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              MaterialButton(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            offset: Offset(4, 4))
                      ]),
                  child: Text(
                    "Vos produits",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Products(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }
}
