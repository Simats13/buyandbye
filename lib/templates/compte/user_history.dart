import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:intl/intl.dart';

class UserHistory extends StatefulWidget {
  @override
  _UserHistoryState createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  //Initialisation de la DropDownList
  List<DropdownMenuItem<String>> duration = [];
  String def;

  void listDuration() {
    duration.clear();
    duration.add(DropdownMenuItem(
        value: "7 jours",
        child: Text("7 jours", style: TextStyle(fontSize: 18))));
    duration.add(DropdownMenuItem(
        value: "14 jours",
        child: Text("14 jours", style: TextStyle(fontSize: 18))));
    duration.add(DropdownMenuItem(
        value: "30 jours",
        child: Text("30 jours", style: TextStyle(fontSize: 18))));
  }

  @override
  Widget build(BuildContext context) {
    listDuration();
    return FutureBuilder(
        future: DatabaseMethods().getPurchase(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: BuyandByeAppTheme.black_electrik,
                title: Text("Historique d'achat"),
                elevation: 1,
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
              body: SingleChildScrollView(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //Menu déroulant
                    DropdownButton(
                        value: def,
                        elevation: 2,
                        items: duration,
                        hint: Text("Durée", style: TextStyle(fontSize: 18)),
                        onChanged: (value) {
                          def = value;
                          setState(() {});
                        }),
                    SizedBox(
                      height: 30,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        String user0 = snapshot.data.docs[index]["users"][0];
                        String user1 = snapshot.data.docs[index]["users"][1];
                        // Appelle la fonction d'affichage des commandes pour chaque client qui a commandé dans la boutique
                        return UserCommand(user0, user1);
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class UserCommand extends StatefulWidget {
  const UserCommand(this.user0, this.user1);
  final String user0, user1;
  _UserCommandState createState() => _UserCommandState();
}

class _UserCommandState extends State<UserCommand> {
  String shopName /*, address*/;
  String formatTimestamp(var timestamp) {
    var format = new DateFormat('d/MM/y');
    return format.format(timestamp.toDate());
  }

  //
  getShopInfos(sellerId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: sellerId)
        .get();
    shopName = "${querySnapshot.docs[0]["name"]}";
    // address = "${querySnapshot.docs[0]["adresse"]}";
    if (mounted) {
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    getShopInfos(widget.user0);
    String docId = widget.user0 + widget.user1;
    return StreamBuilder(
        stream: DatabaseMethods().getCommandDetails(docId),
        builder: (context, snapshot) {
          if (snapshot.hasData && shopName != null) {
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          formatTimestamp(
                              snapshot.data.docs[index]["horodatage"]),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          print("clicked");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
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
                                        // Ecrit au singulier ou au pluriel selon le nombre d'article
                                        snapshot.data.docs[index]["articles"] ==
                                                1
                                            ? Text(snapshot.data
                                                    .docs[index]["articles"]
                                                    .toString() +
                                                " article")
                                            : Text(snapshot.data
                                                    .docs[index]["articles"]
                                                    .toString() +
                                                " articles"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          snapshot.data.docs[index]["prix"]
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
                                ProductInfos(
                                    docId,
                                    snapshot.data.docs[index]["id"],
                                    widget.user0)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30)
                    ],
                  );
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class ProductInfos extends StatefulWidget {
  const ProductInfos(this.docId, this.commandId, this.sellerId);
  final String docId, commandId, sellerId;
  _ProductInfosState createState() => _ProductInfosState();
}

class _ProductInfosState extends State<ProductInfos> {
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseMethods()
            .getPurchaseDetails(widget.docId, widget.commandId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        SizedBox(height: 15),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, right: 40.0),
                          child: Divider(thickness: 1, color: Colors.black),
                        ),
                        SizedBox(height: 15),
                        ProductDetails(widget.sellerId,
                            snapshot.data.docs[index]["produit"]),
                      ],
                    );
                  },
                )
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class ProductDetails extends StatefulWidget {
  const ProductDetails(this.sellerId, this.productId);
  final String sellerId, productId;
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            DatabaseMethods().getOneProduct(widget.sellerId, widget.productId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [Text(snapshot.data["nom"])],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
