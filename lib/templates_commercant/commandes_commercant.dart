import 'package:buyandbye/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:shimmer/shimmer.dart';

import 'detail_commande.dart';

class CommandesCommercant extends StatefulWidget {
  const CommandesCommercant({Key? key}) : super(key: key);

  @override
  _CommandesCommercantState createState() => _CommandesCommercantState();
}

// Fonction qui renvoie l'horodatage actuel
String getDate(time) {
  var format = DateFormat(' dd/MM/yy à hh:mm');
  return format.format(time.toDate());
}

class _CommandesCommercantState extends State<CommandesCommercant> {
  var clickedCategorie = 0;
  String? userid;

  @override
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
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BuyandByeAppTheme.blackElectrik,
          title: const Text("Commandes"),
          centerTitle: true,
          elevation: 1,
        ),
        body: FutureBuilder(
            future: DatabaseMethods().getPurchase("magasins", userid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(
                      height: size.height * 0.08,
                      child: Stack(
                        children: [
                          Container(
                            height: size.height * 0.08,
                            decoration: const BoxDecoration(
                                color: BuyandByeAppTheme.blackElectrik,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(36),
                                  bottomRight: Radius.circular(36),
                                )),
                          ),
                          const SizedBox(height: 30),
                          // Affichage des 3 boutons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // En attente
                              Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
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
                                            ? BuyandByeAppTheme.blackElectrik
                                            : Colors.white,
                                      ),
                                    ),
                                  )),
                              // En cours
                              Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
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
                                              ? BuyandByeAppTheme.blackElectrik
                                              : Colors.white,
                                        )),
                                  )),
                              // Terminées
                              Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
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
                                              ? BuyandByeAppTheme.blackElectrik
                                              : Colors.white,
                                        )),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Command(clickedCategorie, userid),
                  ]),
                );
              } else {
                return Shimmer.fromColors(
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
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                );
              }
            }));
  }
}

class Command extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const Command(this.clickedCategorie, this.sellerId);
  final String? sellerId;
  final int clickedCategorie;
  @override
  _CommandState createState() => _CommandState();
}

// Affichage de chacune des commandes du client
class _CommandState extends State<Command> {
  int clickedNumber = 1;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseMethods()
          .getSellerCommandDetails(widget.sellerId, widget.clickedCategorie),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return (snapshot.data!as QuerySnapshot).docs.isEmpty
              ? //Affiche un message s'il n'y a aucune commande dans une catégorie
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text("Aucune commande dans cette catégorie",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                )
              : Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                      itemBuilder: (context, index) {
                        // Récupération des valeurs de la bdd
                        int? reference = (snapshot.data as QuerySnapshot).docs[index]["reference"];
                        int? statut = (snapshot.data! as QuerySnapshot).docs[index]["statut"];
                        String date =
                            getDate(((snapshot.data! as QuerySnapshot).docs[index]["horodatage"]));
                        int nbArticles = (snapshot.data! as QuerySnapshot).docs[index]["articles"];
                        double prix = (snapshot.data! as QuerySnapshot).docs[index]["prix"];
                        int? livraison = (snapshot.data! as QuerySnapshot).docs[index]["livraison"];
                        String? commandId = (snapshot.data! as QuerySnapshot).docs[index]["id"];
                        String? clientId = (snapshot.data! as QuerySnapshot).docs[index]["clientID"];
                        // Toutes les commandes sont récupérées mais on affiche seulement
                        // celles dont le statut est le même que celui de la catégorie selectionnée
                        return MaterialButton(
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
                              // Container(
                              //   height: 20,
                              //   width: MediaQuery.of(context).size.width,
                              //   decoration: BoxDecoration(
                              //       color: brightness == "Brightness.light"
                              //           ? Color.fromRGBO(250, 250, 250, 1)
                              //           : Color.fromRGBO(48, 48, 48, 1)),
                              // ),
                              // Affiche un résumé de chaque commande
                              Container(
                                margin: const EdgeInsets.all(15),
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
                                    const SizedBox(height: 10),
                                    // Affiche en ligne le numéro de commande et le prix total
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 30),
                                        Text(
                                            "Commande n°" +
                                                reference.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                        const SizedBox(width: 100),
                                        Text(prix.toStringAsFixed(2) + "€",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Affiche en ligne la date de la commande et le nombre d'articles différents
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const [
                                        Icon(Icons.arrow_forward_ios_rounded),
                                        SizedBox(width: 20)
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 30),
                                        Text(date,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                        const SizedBox(width: 100),
                                        nbArticles <= 1
                                            ? Text(
                                                nbArticles.toString() +
                                                    " article",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16))
                                            : Text(
                                                nbArticles.toString() +
                                                    " articles",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16))
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Text("Pagination en cours de création,"),
                    // Text("Masquer pour démonstration"),
                    // Le numéro de page actuelle reste le même sur En attente, En cours et Terminées.
                    // Créer 3 variables qui seront modifiées selon la catégorie affichée
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (int i = 1;
                          i < (((snapshot.data! as QuerySnapshot).docs.length + 1) / 3).ceil() + 1;
                          i++)
                        Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                fixedSize: const Size(10, 10),
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
                    const SizedBox(height: 20),
                  ],
                );
        } else {
          return Shimmer.fromColors(
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
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
          );
        }
      },
    );
  }
}
