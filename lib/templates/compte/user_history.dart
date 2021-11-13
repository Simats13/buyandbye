import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/compte/historyDetails.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class UserHistory extends StatefulWidget {
  @override
  _UserHistoryState createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyandByeAppTheme.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: RichText(
            text: TextSpan(
              // style: Theme.of(context).textTheme.bodyText2,
              children: [
                TextSpan(
                    text: "Historique d'Achat",
                    style: TextStyle(
                      fontSize: 20,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.history,
                      color: BuyandByeAppTheme.orangeFonce,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: BuyandByeAppTheme.white,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          bottomOpacity: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: BuyandByeAppTheme.orange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: FutureBuilder(
        future: DatabaseMethods().getPurchase("users", userid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              child: Container(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              ),
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
            );
          }
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding:
                  EdgeInsets.only(left: 15, right: 15, bottom: 30, top: 30),
              child: snapshot.data.docs.length > 0
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        String shopId = snapshot.data.docs[index]["shopID"];
                        String commandId = snapshot.data.docs[index]["id"];
                        // Appelle la fonction d'affichage des commandes pour chaque client qui a commandé dans la boutique
                        return UserCommand(shopId, commandId, userid);
                      },
                    )
                  : Container(
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.grey[700],
                            size: 64,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Vous n\'avez aucune commande.\n\nVous pouvez commander n\'importe quel produit depuis la page d'un magasin.",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                    ),
            );
          } else {
            return Shimmer.fromColors(
              child: Container(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              ),
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
            );
          }
        },
      ),
    );
  }
}

class UserCommand extends StatefulWidget {
  const UserCommand(this.shopId, this.commandId, this.userid);
  final String shopId, commandId, userid;
  _UserCommandState createState() => _UserCommandState();
}

class _UserCommandState extends State<UserCommand> {
  String shopName /*, address*/;
  String formatTimestamp(var timestamp) {
    var format = new DateFormat('d/MM/y');
    return format.format(timestamp.toDate());
  }

  getShopInfos(sellerId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("magasins")
        .where("id", isEqualTo: sellerId)
        .get();
    shopName = "${querySnapshot.docs[0]["name"]}";
    // address = "${querySnapshot.docs[0]["adresse"]}";
    if (mounted) {
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    getShopInfos(widget.shopId);
    return shopName != null
        ? FutureBuilder(
            future: DatabaseMethods()
                .getCommandDetails(widget.userid, widget.commandId),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return Center(
              //     child: ColorLoader3(
              //       radius: 15.0,
              //       dotRadius: 6.0,
              //     ),
              //   );
              // }
              if (snapshot.hasData) {
                int statut = snapshot.data["statut"];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatTimestamp(snapshot.data["horodatage"]),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryDetails(
                                widget.userid,
                                widget.commandId,
                                statut,
                                snapshot.data["horodatage"],
                                widget.shopId,
                                snapshot.data["prix"],
                                snapshot.data["livraison"],
                                snapshot.data["adresse"]),
                          ),
                        );
                      },
                      child: Container(
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
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shopName,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      // Ecrit au singulier ou au pluriel selon le nombre d'article(s)
                                      snapshot.data["articles"] == 1
                                          ? Text(snapshot.data["articles"]
                                                  .toString() +
                                              " article")
                                          : Text(snapshot.data["articles"]
                                                  .toString() +
                                              " articles"),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        snapshot.data["prix"]
                                                .toStringAsFixed(2) +
                                            "€",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Center(
                                  child: Text(statut == 0
                                      ? "Statut : En attente"
                                      : statut == 1
                                          ? "Statut : En cours"
                                          : "Statut : Terminé")),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30)
                  ],
                );
              } else {
                return Shimmer.fromColors(
                  child: Container(
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                );
              }
            })
        : Shimmer.fromColors(
            child: Container(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                  ),
                ],
              ),
            ),
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
          );
  }
}
