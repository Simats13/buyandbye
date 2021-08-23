import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

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

  // Première classe qui affiche les 3 boutons de statut des commandes
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Commandes"),
          elevation: 1,
        ),
        body: FutureBuilder(
            future: DatabaseMethods().getPurchase(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(children: [
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
                              color: clickedCategorie == 0
                                  ? OficihomeAppTheme.orange
                                  : Colors.transparent,
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                setState(() {
                                  clickedCategorie = 0;
                                });
                              },
                              child: Text("En attente"),
                            )),
                            // En cours
                        Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: clickedCategorie == 1
                                    ? OficihomeAppTheme.orange
                                    : Colors.transparent),
                            child: MaterialButton(
                              onPressed: () {
                                setState(() {
                                  clickedCategorie = 1;
                                });
                              },
                              child: Text("En cours"),
                            )),
                            // Terminées
                        Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: clickedCategorie == 2
                                  ? OficihomeAppTheme.orange
                                  : Colors.transparent,
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                setState(() {
                                  clickedCategorie = 2;
                                });
                              },
                              child: Text("Terminées"),
                            )),
                      ],
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
                            String user0 =
                                snapshot.data.docs[index]["users"][0];
                            String user1 =
                                snapshot.data.docs[index]["users"][1];
                            // Appelle la fonction d'affichage des commandes pour chaque commande
                            return Command(user0, user1, clickedCategorie);
                          },
                        ),
                      ],
                    ),
                    Divider(thickness: 0.5, color: Colors.black),
                  ]),
                );
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}

class Command extends StatefulWidget {
  const Command(this.user0, this.user1, this.clickedCategorie);
  final String user0, user1;
  final int clickedCategorie;
  _CommandState createState() => _CommandState();
}

// Affichage de chacune des commandes
class _CommandState extends State<Command> {
  Widget build(BuildContext context) {
    String docId = widget.user0 + widget.user1;
    return StreamBuilder(
      stream: DatabaseMethods().getCommandDetails(docId),
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
                                widget.user0,
                                widget.user1,
                                commandId),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          // Container colorée pour masquer le message "Aucune commande"
                          Container(
                            height: 18,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: brightness == "Brightness.light" ? Color.fromRGBO(250, 250, 250, 1) : Color.fromRGBO(48, 48, 48, 1)),
                          ),
                          // Affiche un résumé de chaque commande
                          Column(
                            children: [
                              Divider(thickness: 0.5, color: Colors.black),
                              // Affiche en ligne le numéro de commande et le prix total
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text("Commande n°" + reference.toString()),
                                  SizedBox(width: 40),
                                  Text(prix.toStringAsFixed(2) + "€"),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Affiche en ligne la date de la commande et le nombre d'articles différents
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.arrow_forward_ios_rounded),
                                  SizedBox(width: 10)
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(date),
                                  SizedBox(width: 40),
                                  nbArticles <= 1
                                      ? Text(nbArticles.toString() + " article")
                                      : Text(
                                          nbArticles.toString() + " articles")
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
