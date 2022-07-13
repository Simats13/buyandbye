import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';

// Retourne la liste des catégories où le commerçant a entré au moins un produit
List categoriesInDb(snapshot) {
  List categoriesList = [];
  // Pour chaque produit dans la bdd, ajoute le nom de la catégorie s'il n'est
  // pas déjà dans la liste
  for (var i = 0; i <= snapshot.data.docs.length - 1; i++) {
    String? categoryName = snapshot.data.docs[i]["categorie"];
    if (!categoriesList.contains(categoryName)) {
      categoriesList.add(snapshot.data.docs[i]["categorie"]);
    }
  }
  return categoriesList;
}

class AccueilCommercant extends StatefulWidget {
  const AccueilCommercant({Key? key}) : super(key: key);

  @override
  _AccueilCommercantState createState() => _AccueilCommercantState();
}

class _AccueilCommercantState extends State<AccueilCommercant> {
  String? myID;
  late String myFirstName, myLastName, myUserName, myEmail;
  String? myProfilePic;
  bool? myPremium;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  // Récupère les informations de l'utilisateur courant dans la bdd
  getMyInfo() async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myFirstName = "${querySnapshot.docs[0]["fname"]}";
    myLastName = "${querySnapshot.docs[0]["lname"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    myPremium = querySnapshot.docs[0]["premium"];
    setState(() {});
  }

  // Cette première classe affiche l'image et le nom du commerçant
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Si l'image de profil n'est pas chargée
    if (myProfilePic == null) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Affiche un message de chargement
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const CircularProgressIndicator(),
              ),
              const SizedBox(height: 20),
              const Text("Chargement",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 30),
              const Divider(thickness: 0.5, color: Colors.black),
            ],
          ),
        ),
      );
    } else {
      // Quand l'image est chargée
      return Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: size.width / 1.05,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            offset: Offset(4, 4))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            myProfilePic!,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 40, 0, 0),
                        child: Text('Bienvenue',
                            style: TextStyle(
                                fontSize: 20, color: BuyandByeAppTheme.orange)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(myFirstName + " " + myLastName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
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
                const SizedBox(height: 15),
                Container(
                    width: size.width / 1.05,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 4,
                              offset: Offset(4, 4))
                        ]),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 30),
                          child: Text('Ma boutique',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: const [
                                  Text('380.16 €',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    "Ce mois-ci",
                                  ),
                                ],
                              ),
                              Column(
                                children: const [
                                  Text('1527.161 €',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    "Au total",
                                  ),
                                ],
                              )
                            ]),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                      ],
                    )),
                const SizedBox(height: 15),
                myPremium == true
                    ? SizedBox(
                        width: size.width / 1.05,
                        child: Stack(
                          children: [
                            Container(
                              height: size.height * 0.35,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 4,
                                        offset: Offset(4, 4))
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Text('Vos Statistiques',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Image.asset('assets/images/charts.png'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
  }
}
