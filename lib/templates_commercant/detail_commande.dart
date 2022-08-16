import 'package:buyandbye/services/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/chatscreen.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

class DetailCommande extends StatefulWidget {
  const DetailCommande(this.ref, this.statut, this.date, this.total, this.livraisonNb, this.sellerId, this.clientId, this.commandId, {Key? key})
      : super(key: key);
  final String? date, sellerId, clientId, commandId;
  final int? ref, statut, livraisonNb;
  final double total;
  @override
  _DetailCommandeState createState() => _DetailCommandeState();
}

// Si la commande est "en cours" on indique si elle doit être préparée ou si elle est disponible/expédiée
Widget defStatut(statut, livraison) {
  return Container(
      child: statut == 0
          ? const Text("En attente")
          : statut == 2
              ? const Text("Terminée")
              : livraison == 1
                  ? const Text("Disponible en magasin")
                  : livraison == 3
                      ? const Text("Commande expédiée")
                      : const Text("En préparation"));
}

// Affiche les boutons en bas de page pour les commandes "en attente"
Widget boutonsEnAttente(sellerId, clientId, commId, context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Container(
        height: 35,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: BuyandByeAppTheme.orange,
        ),
        child: MaterialButton(
            onPressed: () {
              DatabaseMethods().updateCommand(sellerId, clientId, commId, 1);
              Navigator.pop(context);
            },
            child: const Text(
              "Accepter commande",
              style: TextStyle(fontSize: 12),
            )),
      ),
      Container(
        height: 35,
        padding: const EdgeInsets.symmetric(
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
            child: const Text(
              "Refuser commande",
              style: TextStyle(fontSize: 12),
            )),
      ),
    ],
  );
}

// Affiche les boutons en bas de page pour les commandes "en cours"
Widget boutonsEnCours(context, sellerId, clientId, commId) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Container(
        height: 35,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: BuyandByeAppTheme.orange,
        ),
        child: MaterialButton(
            onPressed: () {
              DatabaseMethods().updateCommand(sellerId, clientId, commId, 2);
              Navigator.pop(context);
            },
            child: const Text(
              "Commande préparée",
              style: TextStyle(fontSize: 12),
            )),
      ),
      Container(
        height: 35,
        padding: const EdgeInsets.symmetric(
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
            child: const Text(
              "Annuler commande",
              style: TextStyle(fontSize: 12),
            )),
      ),
    ],
  );
}

// Détermine les boutons à afficher en fonction du statut
displayButtons(statut, sellerId, clientId, commId, context) {
  if (statut == 0) {
    return boutonsEnAttente(sellerId, clientId, commId, context);
  } else if (statut == 1) {
    return boutonsEnCours(context, sellerId, clientId, commId);
  } else {
    return const SizedBox.shrink();
  }
}

// Première classe qui affiche les informations générales de la commande
class _DetailCommandeState extends State<DetailCommande> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BuyandByeAppTheme.blackElectrik,
          title: const Text("Détail commande"),
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder(
            future: DatabaseMethods().getPurchaseDetails(widget.sellerId, widget.commandId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int nbArticles = (snapshot.data! as QuerySnapshot).docs.length;
                return SingleChildScrollView(
                    // Affiche les informations de la commande
                    child: Column(
                  children: [
                    // const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    Text("Commande n°" + widget.ref.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    // Appelle de la fonction pour déterminer le message de statut de la commande
                    defStatut(widget.statut, widget.livraisonNb),
                    const SizedBox(height: 20),
                    Text(widget.date!),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 20),
                        // Mot "article" au singulier s'il n'y en a qu'un dans la commande
                        nbArticles < 2 ? const Text("1 article") : Text((nbArticles).toString() + " articles"),
                      ],
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                      itemBuilder: (context, index) {
                        // Appelle la classe d'affichage des produits
                        // pour chaque produit dans la commande
                        return Detail(widget.sellerId, (snapshot.data! as QuerySnapshot).docs[index]["produit"],
                            (snapshot.data! as QuerySnapshot).docs[index]["quantite"]);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Text("Total : " + widget.total.toStringAsFixed(2) + "€"), const SizedBox(width: 10)],
                    ),
                    // Appel de la classe pour afficher les informations du client
                    UserInfo(widget.clientId, widget.livraisonNb, widget.statut, widget.commandId, widget.commandId, widget.sellerId)
                  ],
                ));
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}

// Affiche le détail de chaque produit commandé
class Detail extends StatefulWidget {
  const Detail(this.sellerId, this.productId, this.quantite, {Key? key}) : super(key: key);
  final String? sellerId, productId;
  final int? quantite;
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: DatabaseMethods().getOneProduct(widget.sellerId, widget.productId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Affiche les informations du produit
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                    // ignore: prefer_const_literals_to_create_immutables
                    boxShadow: [const BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(4, 4))]),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      const SizedBox(width: 25),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.network(snapshot.data["images"][0]),
                      ),
                      const SizedBox(width: 50),
                      SizedBox(
                        width: 160,
                        child: Column(
                          // Affiche en colonne le nom et la référence du produit commandé
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data["nom"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 30),
                            Text("Réf : " + snapshot.data["reference"].toString()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Affiche en colonne le prox et la quantité du produit
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(snapshot.data["prix"].toStringAsFixed(2) + "€"),
                          const SizedBox(height: 30),
                          Text("Quantité : " + widget.quantite.toString())
                        ],
                      ),
                    ]),
                    const SizedBox(height: 15)
                  ],
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

// Affiche les informations de l'acheteur
class UserInfo extends StatefulWidget {
  const UserInfo(this.clientId, this.livraisonNb, this.statut, this.commId, this.documentId, this.sellerId, {Key? key}) : super(key: key);
  final String? clientId, commId, documentId, sellerId;
  final int? livraisonNb, statut;

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String? myUserName, myProfilePic;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: ProviderUserInfo().returnData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          myUserName = snapshot.data["name"];
          myProfilePic = snapshot.data["imgUrl"];
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
                            ? const Text("Click & Collect")
                            : widget.livraisonNb == 2
                                ? const Text("Click & Collect")
                                : const Text("Livraison à domicile"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text((snapshot.data! as QuerySnapshot).docs[0]["fname"] + " " + (snapshot.data! as QuerySnapshot).docs[0]["lname"]),
                            const SizedBox(width: 25),
                            // Bouton pour ouvrir le chat avec le client
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoom(
                                            widget.sellerId!,
                                            myUserName,
                                            (snapshot.data! as QuerySnapshot).docs[0]["FCMToken"],
                                            widget.clientId!,
                                            widget.sellerId! + widget.clientId!,
                                            (snapshot.data! as QuerySnapshot).docs[0]["fname"],
                                            (snapshot.data! as QuerySnapshot).docs[0]["lname"],
                                            (snapshot.data! as QuerySnapshot).docs[0]["imgUrl"],
                                            myProfilePic,
                                            "client")));
                              },
                              icon: const Icon(Icons.message),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text((snapshot.data! as QuerySnapshot).docs[0]["phone"]),
                        const SizedBox(height: 20),
                        Text((snapshot.data! as QuerySnapshot).docs[0]["email"]),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
              // Affiche les boutons en fonction du statut de la commande
              displayButtons(widget.statut, widget.sellerId, widget.clientId, widget.commId, context),
              const SizedBox(height: 50)
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
