import 'package:buyandbye/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Achat/pageLivraison.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/database.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double cartTotal = 0.0;
  double cartDeliver = 0.0;

  String idCommercant;
  String customerID, email;

  @override
  void initState() {
    super.initState();
    getMyInfo();
    getMyInfoCart();
  }

  getMyInfoCart() async {
    QuerySnapshot querySnapshot = await DatabaseMethods().getCart();
    idCommercant = "${querySnapshot.docs[0]["idCommercant"]}";
    
    setState(() {});
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(userid);
    customerID = "${querySnapshot.docs[0]["customerId"]}";
    email = "${querySnapshot.docs[0]["email"]}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseMethods().allCartMoney(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data.docs.length > 0) {
            return Expanded(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    double total = 0.0;
                    for (var i = 0; i < snapshot.data.docs.length; i++) {
                      total += snapshot.data.docs[i]["prixProduit"] *
                          snapshot.data.docs[i]["amount"];
                    }
                    cartTotal = total;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: <Widget>[
                          // SizedBox(
                          //   height: 30,
                          // ),
                          Text(
                            "Mon Panier",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),

                          cartItem(),

                          SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Sous-Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                cartTotal.toString() + "€",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Frais de Livraison",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "1.99€",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                cartTotal.toString() + "€",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageLivraison(
                                            email: email,
                                            idCommercant: idCommercant,
                                            total: cartTotal,
                                            customerID: customerID,
                                          )));
                            },
                            color: Colors.deepOrangeAccent,
                            height: 50,
                            minWidth: MediaQuery.of(context).size.width - 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            child: RichText(
                              text: TextSpan(
                                text: 'CHOISIR LE MODE DE LIVRAISON',
                                style: TextStyle(
                                  fontSize: 15,
                                  // color: BuyandByeAppTheme.orangeMiFonce,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: Icon(
                                        Icons.local_shipping,
                                        color: BuyandByeAppTheme.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            );
          } else {
            cartTotal = 0.0;
            return Container(
              margin: EdgeInsets.only(top: 100),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.grey[700],
                    size: 64,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Votre panier est vide.\n Commencez à commercer dès maintenant avec les nombreux magasins présents sur la plateforme !",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )),
            );
          }
        });
  }

  cartItem() {
    return FutureBuilder(
        future: DatabaseMethods().getCart(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              height: 150,
              child: ListView.builder(
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    double total = 0.0;
                    for (var i = 0; i < snapshot.data.docs.length; i++) {
                      total += snapshot.data.docs[i]["prixProduit"] *
                          snapshot.data.docs[i]["amount"];
                    }

                    cartTotal = total;

                    var amount = snapshot.data.docs[index]["amount"];
                    var money = snapshot.data.docs[index]["prixProduit"];
                    var allMoneyForProduct = money * amount;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.scaleDown,
                                        image: NetworkImage(snapshot
                                            .data.docs[index]["imgProduit"])),
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 100,
                                  child: Text(
                                    snapshot.data.docs[index]["nomProduit"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: IconButton(
                                        icon: Icon(Icons.remove,
                                            color: Colors.black, size: 15),
                                        onPressed: () {
                                          var itemdelete =
                                              snapshot.data.docs[index]["id"];
                                          amount = (snapshot.data.docs[index]
                                                  ["amount"] -
                                              1);
                                          addItem(itemdelete, amount);
                                          if (snapshot.data.docs[index]
                                                  ["amount"] ==
                                              1) {
                                            var itemdelete =
                                                snapshot.data.docs[index]["id"];
                                            deleteItem(itemdelete);
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        "$amount",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.blue[300],
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: IconButton(
                                        icon: Icon(Icons.add,
                                            color: Colors.black, size: 15),
                                        onPressed: () {
                                          var itemdelete =
                                              snapshot.data.docs[index]["id"];
                                          amount = (snapshot.data.docs[index]
                                                  ["amount"] +
                                              1);
                                          addItem(itemdelete, amount);
                                        },
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "$allMoneyForProduct€",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  addItem(itemdelete, amount) async {
    String idProduit = itemdelete;
    DatabaseMethods().addItem(idProduit, amount);
    setState(() {});
  }

  deleteItem(itemdelete) {
    String idProduit = itemdelete;
    DatabaseMethods().deleteCartProduct(idProduit);
    setState(() {});
  }
}
