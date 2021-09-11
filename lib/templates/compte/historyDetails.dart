import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates/pages/pageDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDetails extends StatefulWidget {
  _HistoryDetailsState createState() => _HistoryDetailsState();
  HistoryDetails(this.userid, this.commandId, this.statut, this.horodatage,
      this.shopID, this.prix, this.livraison, this.adresse);
  final String userid, commandId, shopID, adresse;
  final int statut, livraison;
  final Timestamp horodatage;
  final double prix;
}

// Fonction qui renvoie l'horodatage actuel
String getDate(time) {
  var format = new DateFormat('dd/MM/yy à hh:mm');
  return format.format(time.toDate());
}

class _HistoryDetailsState extends State<HistoryDetails> {
  String shopName;

  getShopInfos(sellerId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("magasins")
        .where("id", isEqualTo: sellerId)
        .get();
    shopName = "${querySnapshot.docs[0]["name"]}";
    if (mounted) {
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    getShopInfos(widget.shopID);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BuyandByeAppTheme.black_electrik,
          title: Text("Détails de commande"),
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
        body: FutureBuilder(
            future: DatabaseMethods()
                .getPurchaseDetails(widget.userid, widget.commandId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String date = getDate(widget.horodatage);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                          widget.statut == 0
                              ? "Commande en attente"
                              : widget.statut == 1
                                  ? "Commande en cours"
                                  : "Commande terminée",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700)),
                      SizedBox(height: 20),
                      Text(date, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Total : " + widget.prix.toStringAsFixed(2) + "€",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Vendeur : ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              shopName == null
                                  ? CircularProgressIndicator()
                                  : TextButton(
                                      child: Text(shopName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blue)),
                                      onPressed: () {
                                        print("clicked");
                                        // Navigator.push(context, MaterialPageRoute(
                                        //   builder: (context) => PageDetail()
                                        // ));
                                      }),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                              widget.livraison == 0 || widget.livraison == 0
                                  ? "Mode de livraison : Click & Collect"
                                  : "Mode de livraison : À domicile",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: 20),
                          Text("Adresse de livraison : " + widget.adresse,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
                                  padding: EdgeInsets.all(30),
                                  child: ProductDetails(
                                      snapshot.data.docs[index]["produit"],
                                      snapshot.data.docs[index]["quantite"],
                                      widget.shopID),
                                )),
                          );
                        },
                      )
                    ],
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}

class ProductDetails extends StatefulWidget {
  ProductDetails(this.productID, this.quantite, this.shopID);
  final String productID, shopID;
  final int quantite;
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseMethods()
          .getOneProductFuture(widget.shopID, widget.productID),
      builder: (context, snapshot) {
        String image, nom, prix, description;
        if (snapshot.hasData) {
          image = snapshot.data["images"][0];
          nom = snapshot.data["nom"];
          prix = snapshot.data["prix"].toStringAsFixed(2);
          description = snapshot.data["description"];
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    nom == null
                        ? CircularProgressIndicator()
                        : Text(nom,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10),
                    Container(
                      height: 100,
                      width: 100,
                      child: image == null
                          ? CircularProgressIndicator()
                          : Image.network(image),
                    ),
                  ],
                ),
                Center(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // children: [
                  child: prix == null
                      ? CircularProgressIndicator()
                      : Text("Prix unitaire :\n" + prix + "€",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16)),
                  // ],
                ),
              ],
            ),
            SizedBox(height: 25),
            Center(
                child: description == null
                    ? CircularProgressIndicator()
                    : Text(description,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center)),
          ],
        );
      },
    );
  }
}
