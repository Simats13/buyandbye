import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates_commercant/detail_produit.dart';
import 'package:buyandbye/templates_commercant/new_product.dart';
import 'package:buyandbye/templates_commercant/new_product_restaurant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String? userid;

  // Récupère les informations de l'utilisateur courant dans la bdd
  getMyInfo() async {
    final User user = await ProviderUserId().returnUser();
    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getMyInfo(),
        builder: (context, snapshotuid) {
          return snapshotuid.hasData
              ? Scaffold(
                  appBar: AppBar(
                      backgroundColor: BuyandByeAppTheme.blackElectrik,
                      title: const Text("Vos produits"),
                      elevation: 1,
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 30,
                          ),
                          onPressed: () {
                            if (snapshotuid.data ==
                                "5HZBy8qA2wbbqjDuQekjvdgI6Tl2") {
                                  Navigator.push(
                                  context,
                                  // Amène l'utilisateur sur la page d'ajout d'un produit de restaurant
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NewProductRestaurant(snapshotuid.data)));
                            } else {
                              Navigator.push(
                                  context,
                                  // Amène l'utilisateur sur la page d'ajout d'un produit
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NewProduct(snapshotuid.data)));
                            }
                          },
                        )
                      ]),
                  body: SingleChildScrollView(
                    child: StreamBuilder<dynamic>(
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
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: const [
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
                                          const SizedBox(height: 20)
                                        ],
                                      ),
                              ],
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                  ))
              : const Center(
                  child: CircularProgressIndicator(),
                );
        });
  }
}

// Affiche un récapitulatif des produits contenus dans chaque catégorie
class Categorie extends StatefulWidget {
  const Categorie(this.snapshot, this.listOfCategories, this.index, this.uid, {Key? key}) : super(key: key);
  final AsyncSnapshot snapshot;
  final List listOfCategories;
  final int index;
  final String? uid;

  @override
  _CategorieState createState() => _CategorieState();
}

class _CategorieState extends State<Categorie> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Divider(thickness: 0.5, color: Colors.black),
      const SizedBox(height: 20),
      Container(
        width: 380,
        height: 52,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.black)),
                Icon(
                  // Si la suite est visible, la flèche pointe vers le bas
                  // Sinon elle pointe à droite
                  isVisible ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: Colors.black,
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
            physics: const NeverScrollableScrollPhysics(),
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
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
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
                                    SizedBox(
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
                                        Container(
                                          width: 150,
                                          height: 35,
                                          padding: const EdgeInsets.only(right: 5),
                                          child: Text(
                                              widget.snapshot.data.docs[index2]
                                                  ["nom"],
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        const SizedBox(height: 10),
                                        // Affiche un logo lorsque le produit est masqué pour les utilisateurs
                                        widget.snapshot.data.docs[index2]
                                                ["visible"]
                                            ? const SizedBox.shrink()
                                            : const Icon(Icons.hide_image),
                                        const SizedBox(height: 10),
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
                                        const SizedBox(height: 30),
                                        Text("Quantité : " +
                                            widget.snapshot.data
                                                .docs[index2]["quantite"]
                                                .toString()),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded)
                                  ]),
                            ),
                          )))
                  : const SizedBox.shrink();
            },
          ))
    ]);
  }
}
