import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates_commercant/detailProduit.dart';
import 'package:buyandbye/templates_commercant/newProduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class Products extends StatefulWidget {
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String userid;

  // Récupère les informations de l'utilisateur courant dans la bdd
  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
   return user.uid;
    // print(userid);
  }

  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getMyInfo(),
        builder: (context, snapshotuid) {
          print(snapshotuid.data);
          return snapshotuid.hasData
              ? Scaffold(
                  appBar: AppBar(
                      backgroundColor: BuyandByeAppTheme.black_electrik,
                      title: Text("Vos produits"),
                      elevation: 1,
                      actions: [
                        Container(
                          child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    // Amène l'utilisateur sur la page d'ajout d'un produit
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NewProduct(snapshotuid.data)));
                              },
                              icon: Icon(
                                Icons.add_rounded,
                                size: 30,
                              )),
                        )
                      ]),
                  body: SingleChildScrollView(
                    child: StreamBuilder(
                        stream: DatabaseMethods().getProducts(snapshotuid.data),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 20),
                                                Text(
                                                    'Aucun produit dans la boutique.',
                                                    style: TextStyle(
                                                        fontSize: 20)),
                                                SizedBox(height: 10),
                                                Text(
                                                    'Appuyez sur "+" pour ajouter votre',
                                                    style: TextStyle(
                                                        fontSize: 20)),
                                                Text('premier produit',
                                                    style:
                                                        TextStyle(fontSize: 20))
                                              ],
                                            )),
                                      )
                                    :
                                    // Affiche toutes les catégories qui contiennent au moins un produit
                                    Column(
                                        children: [
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: listOfCategories.length,
                                            itemBuilder: (context, index) {
                                              return SingleChildScrollView(
                                                  // Appel de la fonction pour chaque catégorie
                                                  child: Categorie(
                                                      snapshot,
                                                      listOfCategories,
                                                      index,
                                                      snapshotuid.data));
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
                        }),
                  ))
              : Center(
                  child: CircularProgressIndicator(),
                );
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
