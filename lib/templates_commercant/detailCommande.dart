import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/chatscreen.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

class DetailCommande extends StatefulWidget {
  const DetailCommande(this.ref, this.statut, this.date, this.total,
      this.livraisonNb, this.user0, this.user1, this.commandId);
  final String date, user0, user1, commandId;
  final int ref, statut, livraisonNb;
  final double total;
  _DetailCommandeState createState() => _DetailCommandeState();
}

// Si la commande est "en cours" on indique si elle doit être préparée ou si elle est disponible/expédiée
Widget defStatut(statut, livraison) {
  return Container(
      child: statut == 0
          ? Text("En attente")
          : statut == 2
              ? Text("Terminée")
              : livraison == 1
                  ? Text("Disponible en magasin")
                  : livraison == 3
                      ? Text("Commande expédiée")
                      : Text("En préparation"));
}

// Affiche les boutons en bas de page pour les commandes "en attente"
Widget boutonsEnAttente(documentId, commId, context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Container(
        height: 35,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: BuyandByeAppTheme.orange,
        ),
        child: MaterialButton(
            onPressed: () {
              DatabaseMethods().updateCommand(documentId, commId, 1);
              Navigator.pop(context);
            },
            child: Text(
              "Accepter commande",
              style: TextStyle(fontSize: 12),
            )),
      ),
      Container(
        height: 35,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: BuyandByeAppTheme.orange,
        ),
        child: MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Refuser commande",
              style: TextStyle(fontSize: 12),
            )),
      ),
    ],
  );
}

// Affiche les boutons en bas de page pour les commandes "en cours"
Widget boutonsEnCours(context, documentId, commId) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Container(
        height: 35,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: BuyandByeAppTheme.orange,
        ),
        child: MaterialButton(
            onPressed: () {
              DatabaseMethods().updateCommand(documentId, commId, 2);
              Navigator.pop(context);
            },
            child: Text(
              "Commande préparée",
              style: TextStyle(fontSize: 12),
            )),
      ),
      Container(
        height: 35,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: BuyandByeAppTheme.orange,
        ),
        child: MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Annuler commande",
              style: TextStyle(fontSize: 12),
            )),
      ),
    ],
  );
}

// Détermine les boutons à afficher en fonction du statut
displayButtons(statut, documentId, commId, context) {
  if (statut == 0) {
    return boutonsEnAttente(documentId, commId, context);
  } else if (statut == 1) {
    return boutonsEnCours(context, documentId, commId);
  } else {
    return SizedBox.shrink();
  }
}

// Première classe qui affiche les informations générales de la commande
class _DetailCommandeState extends State<DetailCommande> {
  @override
  Widget build(BuildContext context) {
    String documentId = widget.user0 + widget.user1;
    return Scaffold(
        appBar: AppBar(
          title: Text("Détail commande"),
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder(
            future: DatabaseMethods()
                .getPurchaseDetails(documentId, widget.commandId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int nbArticles = snapshot.data.docs.length;
                return SingleChildScrollView(
                    // Affiche les informations de la commande
                    child: Column(
                  children: [
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                    Text("Commande n°" + widget.ref.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    SizedBox(height: 10),
                    // Appelle de la fonction pour déterminer le message de statut de la commande
                    defStatut(widget.statut, widget.livraisonNb),
                    SizedBox(height: 20),
                    Text(widget.date),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20),
                        // Mot "article" au singulier s'il n'y en a qu'un dans la commande
                        nbArticles < 2
                            ? Text("1 article")
                            : Text((nbArticles).toString() + " articles"),
                      ],
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        // Appelle la classe d'affichage des produits
                        // pour chaque produit dans la commande
                        return Container(
                            child: Detail(
                                widget.user0,
                                snapshot.data.docs[index]["produit"],
                                snapshot.data.docs[index]["quantite"]));
                      },
                    ),
                    Divider(thickness: 0.5, color: Colors.black),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "Total : " + widget.total.toStringAsFixed(2) + "€"),
                        SizedBox(width: 10)
                      ],
                    ),
                    // Appel de la classe pour afficher les informations du client
                    UserInfo(widget.user1, widget.livraisonNb, widget.statut,
                        widget.commandId, documentId, widget.user0),
                  ],
                ));
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}

// Affiche le détail de chaque produit commandé
class Detail extends StatefulWidget {
  Detail(this.shopId, this.productId, this.quantite);
  final String shopId, productId;
  final int quantite;
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            DatabaseMethods().getOneProduct(widget.shopId, widget.productId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Affiche les informations du produit
            return Column(
              children: [
                Divider(thickness: 0.5, color: Colors.black),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(width: 25),
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.network(snapshot.data["images"][0]),
                  ),
                  SizedBox(width: 50),
                  Container(
                    width: 160,
                    child: Column(
                      // Affiche en colonne le nom et la référence du produit commandé
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(snapshot.data["nom"],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 30),
                        Text("Réf : " + snapshot.data["reference"].toString()),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  SizedBox(width: 50),
                  // Affiche en colonne le prox et la quantité du produit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(snapshot.data["prix"].toStringAsFixed(2) + "€"),
                      SizedBox(height: 30),
                      Text("Quantité : " + widget.quantite.toString())
                    ],
                  ),
                ])
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

// Affiche les informations de l'acheteur
class UserInfo extends StatefulWidget {
  const UserInfo(this.userId, this.livraisonNb, this.statut, this.commId,
      this.documentId, this.shopId);
  final String userId, commId, documentId, shopId;
  final int livraisonNb, statut;

  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String myUserName;
  getSellerName() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(userid);
    myUserName = "${querySnapshot.docs[0]["name"]}";
  }

  void initState() {
    getSellerName();
    super.initState();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseMethods().getUserInfo(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      // Affichage des informations
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Si livraisonNb == 0 ou 2 : "Click & Collect" Sinon "Livraison à domicile"
                        // Si livraisonNb == 1 : "Dispo en magasin", sinon "Colis expédié"
                        widget.livraisonNb == 0
                            ? Text("Click & Collect")
                            : widget.livraisonNb == 2
                                ? Text("Click & Collect")
                                : Text("Livraison à domicile"),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(snapshot.data.docs[0]["name"]),
                            SizedBox(width: 25),
                            // Bouton pour ouvrir le chat avec le client
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoom(
                                            widget.shopId,
                                            myUserName,
                                            snapshot.data.docs[0]["FCMToken"],
                                            widget.userId,
                                            widget.shopId + widget.userId,
                                            snapshot.data.docs[0]["name"],
                                            snapshot.data.docs[0]["imgUrl"])));
                              },
                              icon: Icon(Icons.message),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(snapshot.data.docs[0]["phone"]),
                        SizedBox(height: 20),
                        Text(snapshot.data.docs[0]["email"]),
                      ],
                    ),
                  ],
                ),
              ),
              // Affiche les boutons en fonction du statut de la commande
              displayButtons(
                  widget.statut, widget.documentId, widget.commId, context),
              SizedBox(height: 50)
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
