import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates_commercant/newProduct.dart';
import 'detailProduit.dart';
// import 'package:wave/wave.dart';
// import 'package:wave/config.dart';

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
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: size.height * 0.24,
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.24,
                      decoration: BoxDecoration(
                          // color: BuyandByeAppTheme.orangeMiFonce,
                          border: Border.all(
                              color: BuyandByeAppTheme.orange, width: 2.0),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(36),
                            bottomRight: Radius.circular(36),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 16, 0),
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              // color: BuyandByeAppTheme.orange,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: MediaQuery.of(context).size.width / 1.4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    myProfilePic,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      // Amène l'utilisateur sur la page d'ajout d'un produit
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewProduct(myID)));
                                },
                                icon: Icon(
                                  Icons.store,
                                  size: 30,
                                ))
                            // IconButton(
                            //     onPressed: () {
                            //       Navigator.push(
                            //           context,
                            //           // Amène l'utilisateur sur la page d'ajout d'un produit
                            //           MaterialPageRoute(
                            //               builder: (context) =>
                            //                   NewProduct(myID)));
                            //     },
                            //     icon: Icon(
                            //       Icons.add_rounded,
                            //       size: 30,
                            //     ))
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                            child: Text('Bienvenue',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: BuyandByeAppTheme.orange)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
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
              SizedBox(height: 15),
              Container(
                height: size.height * 0.24,
                width: 380,
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.24,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: BuyandByeAppTheme.orange, width: 2.0),
                          borderRadius: BorderRadius.circular(36)),
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
                height: size.height * 0.35,
                width: 380,
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.35,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: BuyandByeAppTheme.orange, width: 2.0),
                          borderRadius: BorderRadius.circular(36)),
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
              Text(
                "Catégories",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              // Appel de la 2e classe
              DisplayCategorie(myID),
            ],
          ),
        ),
      );
    }
  }
}

//   Column(
//   children: [
//     SizedBox(height: 50),
//     // Affiche le bouton d'ajout d'un produit
//     Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//       SizedBox(width: 10),
//       IconButton(
//           onPressed: () {
//             Navigator.push(
//                 context,
//                 // Amène l'utilisateur sur la page d'ajout d'un produit
//                 MaterialPageRoute(
//                     builder: (context) => NewProduct(myID)));
//           },
//           icon: Icon(Icons.add_rounded, size: 30))
//     ]),
//     // Affiche l'image de profil du magasin
//     Container(
//       height: 150,
//       child: ClipRRect(
//           borderRadius: BorderRadius.circular(100),
//           child: Image.network(
//             myProfilePic,
//           )),
//     ),
//     SizedBox(height: 20),
//     // Affiche le nom du magasin
//     Text(myName,
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//     SizedBox(height: 30),
//     // Appel de la 2e classe
//     DisplayCategorie(myID),
//   ],
// ),

class DisplayCategorie extends StatefulWidget {
  const DisplayCategorie(this.uid);
  final String uid;

  _DisplayCategorieState createState() => _DisplayCategorieState();
}

class _DisplayCategorieState extends State<DisplayCategorie> {
  // Récupère tous les produits de la boutique
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseMethods().getProducts(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Liste des catégories à afficher
            List listOfCategories = categoriesInDb(snapshot);
            return Column(
              children: [
                snapshot.data.docs.length < 1
                    ?
                    // Affiche un message pour indiquer qu'il n'y a pas de produit dans la boutique
                    Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20),
                                Text('Aucun produit dans la boutique.',
                                    style: TextStyle(fontSize: 20)),
                                SizedBox(height: 10),
                                Text('Appuyez sur "+" pour ajouter votre',
                                    style: TextStyle(fontSize: 20)),
                                Text('premier produit',
                                    style: TextStyle(fontSize: 20))
                              ],
                            )),
                      )
                    :
                    // Affiche toutes les catégories qui contiennent au moins un produit
                    Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listOfCategories.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                  // Appel de la fonction pour chaque catégorie
                                  child: Categorie(snapshot, listOfCategories,
                                      index, widget.uid));
                            },
                          ),
                          SizedBox(height: 20)
                        ],
                      ),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

// Affiche un récapitulatif des produits contenus dans chaque catégorie
class Categorie extends StatefulWidget {
  const Categorie(this.snapshot, this.listOfCategories, this.index, this.uid);
  final AsyncSnapshot snapshot;
  final List listOfCategories;
  final int index;
  final String uid;

  _CategorieState createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {
  bool isVisible = false;
  Widget build(BuildContext context) {
    // Variable pour savoir si le système est en dark mode ou non
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return Column(children: [
      // Divider(thickness: 0.5, color: Colors.black),
      SizedBox(height: 20),
      Container(
        width: 380,
        height: 52,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(4, 4))
            ]),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          // Permet de dérouler les produits d'une catégorie en cliquant dessus
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Affiche le nom de la catégorie
                Text(widget.listOfCategories[widget.index],
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: darkModeOn ? Colors.white : Colors.black)),
                Icon(
                  // Si la suite est visible, la flèche pointe vers le bas
                  // Sinon elle pointe à droite
                  isVisible ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: darkModeOn ? Colors.white : Colors.black,
                ),
              ],
            ),
            // Change le booléen de visibilité à chaque clic sur le bouton
            onPressed: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
          ),
        ),
      ),
      // Si visible, affiche tous les produits de la catégorie cliquée
      Visibility(
          visible: isVisible,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.snapshot.data.docs.length,
            itemBuilder: (context, index2) {
              // De base, tous les produits sont affichés dans chaque catégorie
              // On demande alors à n'afficher que les produits dont la catégorie
              // est la même que celle affichée
              return widget.snapshot.data.docs[index2]["categorie"] ==
                      widget.listOfCategories[widget.index]
                  ? SingleChildScrollView(
                      child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                // Affiche la page de détail lorsqu'on clique sur un produit
                                MaterialPageRoute(
                                    builder: (context) => DetailProduit(
                                        widget.uid,
                                        widget.snapshot.data.docs[index2]
                                            ["id"])));
                          },
                          //Affiche le récap du produit
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 4,
                                      offset: Offset(4, 4))
                                ]),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Image du produit
                                    Container(
                                      height: 50,
                                      width: 50,
                                      child: Image.network(widget.snapshot.data
                                          .docs[index2]["images"][0]),
                                    ),
                                    // Affiche en colonne le nom et la référence du produit
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            widget.snapshot.data.docs[index2]
                                                ["nom"],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                        // SizedBox(height: 30),
                                        SizedBox(height: 10),
                                        // Affiche un logo lorsque le produit est masqué pour les utilisateurs
                                        widget.snapshot.data.docs[index2]
                                                ["visible"]
                                            ? SizedBox.shrink()
                                            : Icon(Icons.hide_image),
                                        SizedBox(height: 10),
                                        Text("Réf : " +
                                            widget.snapshot.data
                                                .docs[index2]["reference"]
                                                .toString())
                                      ],
                                    ),
                                    // Affiche en colonne le prix et la quantité restante du produit
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(widget.snapshot.data
                                                .docs[index2]["prix"]
                                                .toStringAsFixed(2) +
                                            "€"),
                                        SizedBox(height: 30),
                                        Text("Quantité : " +
                                            widget.snapshot.data
                                                .docs[index2]["quantite"]
                                                .toString()),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded)
                                  ]),
                            ),
                          )))
                  : SizedBox.shrink();
            },
          ))
    ]);
  }
}
