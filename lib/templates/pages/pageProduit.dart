import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:buyandbye/services/database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';

class PageProduit extends StatefulWidget {
  const PageProduit(
      {Key? key,
      this.img,
      this.name,
      this.description,
      this.adresse,
      this.imagesList,
      this.nomProduit,
      this.descriptionProduit,
      this.prixProduit,
      this.clickAndCollect,
      this.livraison,
      this.idCommercant,
      this.idProduit,
      this.userid})
      : super(key: key);

  final String? img;
  final List? imagesList;
  final String? nomProduit;
  final String? descriptionProduit;
  final num? prixProduit;
  final String? name;
  final String? description;
  final String? adresse;
  final bool? livraison;
  final bool? clickAndCollect;
  final String? idCommercant;
  final String? idProduit;
  final String? userid;

  @override
  _PageProduitState createState() => _PageProduitState();
}

class _PageProduitState extends State<PageProduit> {
  AddToCartButtonStateId stateId = AddToCartButtonStateId.idle;

  returnDetailPage() async {
    String? nomProduit = widget.nomProduit;
    num? prixProduit = widget.prixProduit;
    String imgProduit = widget.imagesList![0];
    int amount = 1;

    bool checkProductsExists = await DatabaseMethods().checkIfProductsExists(
        widget.userid!, widget.idCommercant, widget.idProduit);

    if (checkProductsExists == true) {
      DocumentSnapshot ds = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userid)
          .collection('cart')
          .doc(widget.idCommercant)
          .collection('products')
          .doc(widget.idProduit)
          .get();
      Map? getDocs = ds.data() as Map?;
      amount = getDocs!['amount'];
      DatabaseMethods().addItem(
          widget.userid, widget.idCommercant, widget.idProduit, amount + 1);
      Navigator.of(context).pop();
    } else {
      bool addProductToCart = await DatabaseMethods().addCart(
          nomProduit,
          prixProduit,
          imgProduit,
          amount,
          widget.idCommercant,
          widget.idProduit);

      if (addProductToCart == false) {
        var docId = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userid)
            .collection('cart')
            .get();
        QueryDocumentSnapshot doc = docId.docs[0];
        DocumentReference docRef = doc.reference;
        var querySnapshot =
            await DatabaseMethods().getMagasinInfo(widget.userid);
        //String sellerNameCart = "Informatique";
        String sellerNameCart = "${querySnapshot.docs[0]["name"]}";
        Platform.isIOS
            ? showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text("Commencer un nouveau panier ?"),
                  content: Text(
                      "Votre panier contient déjà un produit de '$sellerNameCart'. Voulez-vous vider votre panier et ajouter ce produit du magasin '${widget.name}' à la place ?"),
                  actions: [
                    // Close the dialog
                    CupertinoButton(
                        child: Text('Non'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    CupertinoButton(
                      child: Text(
                        'Oui',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        await DatabaseMethods().deleteCart(docRef.id);
                        await DatabaseMethods().addCart(
                            nomProduit,
                            prixProduit,
                            imgProduit,
                            amount,
                            widget.idCommercant,
                            widget.idProduit);
                        Navigator.of(context).pop();

                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              )
            : showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Commencer un nouveau panier ?"),
                  content: Text(
                      "Votre panier contient déjà un produit du magasin '$sellerNameCart'. Voulez-vous vider votre panier et ajouter ce produit du magasin '${widget.name}' à la place ?"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Annuler"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text(
                        'Nouveau panier',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        await DatabaseMethods().deleteCart(docRef.id);
                        await DatabaseMethods().addCart(
                            nomProduit,
                            prixProduit,
                            imgProduit,
                            amount,
                            widget.idCommercant,
                            widget.idProduit);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  Widget successfullAddCart() {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Icon(
                      Icons.add_shopping_cart,
                      size: 50,
                      color: Colors.green.shade300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Text(
              "Produit ajouté au panier !",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              height: 48,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    'Revenir aux produits',
                    style: TextStyle(
                        color: white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  int carouselItem = 0;
  Widget build(BuildContext context) {
    var carouselList =
        Iterable<int>.generate(widget.imagesList!.length).toList();
    String? nomVendeur = widget.name;
    var money = widget.prixProduit;

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Bouton de retour à la page précédente
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 50, left: 15),
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    elevation: 0,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Affichage des images du produit
            CarouselSlider(
                options: CarouselOptions(
                    height: 200,
                    enableInfiniteScroll:
                        widget.imagesList!.length > 1 ? true : false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        carouselItem = index;
                      });
                    }),
                items: carouselList.map((i) {
                  return Builder(builder: (context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.network(widget.imagesList![i]));
                  });
                }).toList()),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 5),
              for (int i = 0; i < widget.imagesList!.length; i++)
                Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: Icon(Icons.circle_rounded,
                        size: 12,
                        color: carouselItem == i ? Colors.black : Colors.grey))
            ]),
            // Affichage des autres informations du produit
            Container(
              padding: const EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 15.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.nomProduit!,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "$money€",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Vendeur : $nomVendeur",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(widget.descriptionProduit!
                        // style: descriptionStyle,
                        ),
                  ),
                  // QuantitySelector(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    // margin: const EdgeInsets.symmetric(vertical: 8.0),
                    // height: 48,
                    // width: double.infinity,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(15.0),
                    //   color: Colors.black,
                    // ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AddToCartButton(
                          // trolley: Image.asset(
                          //   'assets/icons/ic_cart.png',
                          //   width: 24,
                          //   height: 24,
                          //   color: Colors.white,
                          // ),
                          trolley: Icon(Icons.add_shopping_cart),
                          text: Text(
                            'Ajouter au panier',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          check: SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(24),
                          backgroundColor: Colors.deepOrangeAccent,
                          onPressed: (id) {
                            if (id == AddToCartButtonStateId.idle) {
                              //handle logic when pressed on idle state button.
                              setState(() {
                                stateId = AddToCartButtonStateId.loading;
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    stateId = AddToCartButtonStateId.done;
                                  });
                                  Future.delayed(Duration(seconds: 1), () {
                                    returnDetailPage();
                                  });
                                });
                              });
                            } else if (id == AddToCartButtonStateId.done) {
                              //handle logic when pressed on done state button.

                              setState(() {
                                stateId = AddToCartButtonStateId.idle;
                              });
                            }
                          },
                          stateId: stateId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
