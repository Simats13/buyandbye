import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/Achat/page_livraison.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double cartTotal = 0.0;
  double cartDeliver = 0.0;

  String? idCommercant;
  String? email, userid;

  @override
  void initState() {
    super.initState();
    getMyInfo();
    getMyInfoCart();
  }

  getMyInfoCart() async {
    QuerySnapshot querySnapshot = await ProviderGetCart().returnData();
    if (querySnapshot.docs.isEmpty) {
      idCommercant = "empty";
    } else {
      idCommercant = querySnapshot.docs[0].id;
    }
    setState(() {});
  }

  getMyInfo() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: FutureBuilder<dynamic>(
          future: DatabaseMethods().allCartMoney(userid, idCommercant),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: const Center(
                  child: ColorLoader3(
                    radius: 15.0,
                    dotRadius: 6.0,
                  ),
                ),
                margin: const EdgeInsets.only(left: 12, right: 12),
              );
            }
            if (snapshot.data.docs.length > 0) {
              return StreamBuilder<dynamic>(
                  stream: ProviderUserInfo().returnData(),
                  builder: (context, snapshot2) {
                    String userName = snapshot.data['fname'] + snapshot.data['lname'];
                    return ListView.builder(
                        padding: const EdgeInsets.all(0.0),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          double total = 0.0;
                          for (var i = 0; i < snapshot.data.docs.length; i++) {
                            total += snapshot.data.docs[i]["prixProduit"] * snapshot.data.docs[i]["amount"];
                          }
                          cartTotal = total;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: <Widget>[
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  "Mon Panier",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                cartItem(),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Sous-Total",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      cartTotal.toStringAsFixed(2) + "€",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
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
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      cartTotal.toStringAsFixed(2) + "€",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PageLivraison(
                                            email: snapshot2.data["email"],
                                            idCommercant: idCommercant,
                                            total: cartTotal,
                                            customerID: userid,
                                            userName: userName),
                                      ),
                                    );
                                  },
                                  color: Colors.deepOrangeAccent,
                                  height: 50,
                                  minWidth: MediaQuery.of(context).size.width - 50,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  child: RichText(
                                    text: const TextSpan(
                                      text: 'CHOISIR LE MODE DE LIVRAISON',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        WidgetSpan(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Icon(
                                              Icons.local_shipping,
                                              color: BuyandByeAppTheme.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          );
                        });
                  });
            } else {
              cartTotal = 0.0;
              return Container(
                constraints: const BoxConstraints(maxHeight: 20),
                // margin: EdgeInsets.only(top: 100),
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
          }),
    );
  }

  cartItem() {
    return FutureBuilder<dynamic>(
        future: DatabaseMethods().getCartProducts(idCommercant),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              constraints: const BoxConstraints(
                maxHeight: 250,
              ),
              child: ListView.builder(
                  padding: const EdgeInsets.all(0.0),
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    double total = 0.0;

                    for (var i = 0; i < snapshot.data.docs.length; i++) {
                      total += snapshot.data.docs[i]["prixProduit"] * snapshot.data.docs[i]["amount"];
                    }

                    cartTotal = total;

                    var amount = snapshot.data.docs[index]["amount"];
                    var money = snapshot.data.docs[index]["prixProduit"];
                    var allMoneyForProduct = money * amount;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.scaleDown,
                                      image: NetworkImage(
                                        snapshot.data.docs[index]["imgProduit"],
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    snapshot.data.docs[index]["nomProduit"],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                                      child: IconButton(
                                        icon: const Icon(Icons.remove, color: Colors.black, size: 15),
                                        onPressed: () {
                                          var itemdelete = snapshot.data.docs[index]["id"];
                                          amount = (snapshot.data.docs[index]["amount"] - 1);
                                          addItem(itemdelete, amount, idCommercant);
                                          if (snapshot.data.docs[index]["amount"] == 1) {
                                            var itemdelete = snapshot.data.docs[index]["id"];
                                            deleteItem(itemdelete, idCommercant);
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        amount.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(4)),
                                      child: IconButton(
                                        icon: const Icon(Icons.add, color: Colors.black, size: 15),
                                        onPressed: () {
                                          var itemdelete = snapshot.data.docs[index]["id"];
                                          amount = (snapshot.data.docs[index]["amount"] + 1);
                                          addItem(itemdelete, amount, idCommercant);
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      allMoneyForProduct.toStringAsFixed(2) + "€",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
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
            return const CircularProgressIndicator();
          }
        });
  }

  addItem(itemdelete, amount, sellerID) async {
    String idProduit = itemdelete;
    DatabaseMethods().addItem(userid, sellerID, idProduit, amount);
    setState(() {});
  }

  deleteItem(itemdelete, sellerID) {
    String idProduit = itemdelete;
    DatabaseMethods().deleteCartProduct(idProduit, sellerID);
    setState(() {});
  }
}
