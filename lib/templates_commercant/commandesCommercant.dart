import 'package:buyandbye/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:shimmer/shimmer.dart';

import 'detailCommande.dart';

class CommandesCommercant extends StatefulWidget {
  @override
  _CommandesCommercantState createState() => _CommandesCommercantState();
}

// Fonction qui renvoie l'horodatage actuel
String getDate(time) {
  var format = new DateFormat(' dd/MM/yy à hh:mm');
  return format.format(time.toDate());
}

class _CommandesCommercantState extends State<CommandesCommercant> {
  var clickedCategorie = 0;
  int clickedNumber = 1;
  String userid;

  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;

    setState(() {});
  }

  // Première classe qui affiche les 3 boutons de statut des commandes
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BuyandByeAppTheme.black_electrik,
          title: Text("Commandes"),
          centerTitle: true,
          elevation: 1,
        ),
        body: FutureBuilder(
            future: DatabaseMethods().getPurchase("magasins", userid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      height: size.height * 0.08,
                      child: Stack(
                        children: [
                          Container(
                            height: size.height * 0.08,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.black_electrik,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(36),
                                  bottomRight: Radius.circular(36),
                                )),
                          ),
                          SizedBox(height: 30),
                          // Affichage des 3 boutons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // En attente
                              Container(
                                  height: 30,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: BuyandByeAppTheme.orange,
                                        width: 2.0),
                                    color: clickedCategorie == 0
                                        ? BuyandByeAppTheme.orange
                                        : Colors.transparent,
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      setState(() {
                                        clickedCategorie = 0;
                                      });
                                    },
                                    child: Text(
                                      "En attente",
                                      style: TextStyle(
                                        color: clickedCategorie == 0
                                            ? BuyandByeAppTheme.black_electrik
                                            : Colors.white,
                                      ),
                                    ),
                                  )),
                              // En cours
                              Container(
                                  height: 30,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: BuyandByeAppTheme.orange,
                                          width: 2.0),
                                      color: clickedCategorie == 1
                                          ? BuyandByeAppTheme.orange
                                          : Colors.transparent),
                                  child: MaterialButton(
                                    onPressed: () {
                                      setState(() {
                                        clickedCategorie = 1;
                                      });
                                    },
                                    child: Text("En cours",
                                        style: TextStyle(
                                          color: clickedCategorie == 1
                                              ? BuyandByeAppTheme.black_electrik
                                              : Colors.white,
                                        )),
                                  )),
                              // Terminées
                              Container(
                                  height: 30,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: BuyandByeAppTheme.orange,
                                        width: 2.0),
                                    color: clickedCategorie == 2
                                        ? BuyandByeAppTheme.orange
                                        : Colors.transparent,
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      setState(() {
                                        clickedCategorie = 2;
                                      });
                                    },
                                    child: Text("Terminées",
                                        style: TextStyle(
                                          color: clickedCategorie == 2
                                              ? BuyandByeAppTheme.black_electrik
                                              : Colors.white,
                                        )),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Stack(
                      children: [
                        // Affiche un message s'il n'y a aucune commande dans une catégorie
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Auncune commande dans cette catégorie",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                        // Affiche les commandes (s'il y en a) par dessus le message
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            // Appelle la fonction d'affichage des commandes pour chaque client qui a commandé dans la boutique
                            return Command(clickedCategorie, userid);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text("Pagination en cours de création,"),
                    Text("Masquer pour démonstration"),
                    // Le numéro de page actuelle reste le même sur En attente, En cours et Terminées.
                    // Créer 3 variables qui seront modifiées selon la catégorie affichée
                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (int i = 1; i < 6; i++)
                        Container(
                            height: 30,
                            width: 30,
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                fixedSize: Size(10, 10),
                              ),
                              child: Text((i).toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: i == clickedNumber
                                          ? Colors.black
                                          : Colors.grey)),
                              onPressed: () {
                                clickedNumber = i;
                                setState(() {});
                              },
                            ))
                    ]),
                    SizedBox(height: 20),
                  ]),
                );
              } else {
                return Shimmer.fromColors(
                  child: Container(
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                );
              }
            }));
  }
}

class Command extends StatefulWidget {
  const Command(this.clickedCategorie, this.sellerId);
  final String sellerId;
  final int clickedCategorie;
  _CommandState createState() => _CommandState();
}

// Affichage de chacune des commandes du client
class _CommandState extends State<Command> {
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseMethods().getSellerCommandDetails(widget.sellerId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              // Récupération des valeurs de la bdd
              int reference = snapshot.data.docs[index]["reference"];
              int statut = snapshot.data.docs[index]["statut"];
              String date = getDate((snapshot.data.docs[index]["horodatage"]));
              int nbArticles = snapshot.data.docs[index]["articles"];
              double prix = snapshot.data.docs[index]["prix"];
              int livraison = snapshot.data.docs[index]["livraison"];
              String commandId = snapshot.data.docs[index]["id"];
              String clientId = snapshot.data.docs[index]["clientID"];
              String brightness =
                  MediaQuery.of(context).platformBrightness.toString();
              // Toutes les commandes sont récupérées mais on affiche seulement
              // celles dont le statut est le même que celui de la catégorie selectionnée
              return statut == widget.clickedCategorie
                  ? MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Renvoie vers la page de détail d'une commande
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailCommande(
                                reference,
                                statut,
                                date.toString(),
                                prix,
                                livraison,
                                widget.sellerId,
                                clientId,
                                commandId),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Container coloré pour masquer le message "Aucune commande"
                          Container(
                            height: 20,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: brightness == "Brightness.light"
                                    ? Color.fromRGBO(250, 250, 250, 1)
                                    : Color.fromRGBO(48, 48, 48, 1)),
                          ),
                          // Affiche un résumé de chaque commande
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: BuyandByeAppTheme.orange, width: 2.0),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                // Affiche en ligne le numéro de commande et le prix total
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 30),
                                    Text("Commande n°" + reference.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16)),
                                    SizedBox(width: 100),
                                    Text(prix.toStringAsFixed(2) + "€",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Affiche en ligne la date de la commande et le nombre d'articles différents
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.arrow_forward_ios_rounded),
                                    SizedBox(width: 20)
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 30),
                                    Text(date,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16)),
                                    SizedBox(width: 100),
                                    nbArticles <= 1
                                        ? Text(
                                            nbArticles.toString() + " article",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16))
                                        : Text(
                                            nbArticles.toString() + " articles",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16))
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            },
          );
        } else {
          return Shimmer.fromColors(
            child: Container(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
          );
        }
      },
    );
  }
}
