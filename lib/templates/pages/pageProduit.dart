import 'package:flutter/material.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:buyandbye/services/database.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PageProduit extends StatefulWidget {
  const PageProduit(
      {Key key,
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
      this.idProduit
      })
      : super(key: key);

  final String img;
  final List imagesList;
  final String nomProduit;
  final String descriptionProduit;
  final num prixProduit;
  final String name;
  final String description;
  final String adresse;
  final bool livraison;
  final bool clickAndCollect;
  final String idCommercant;
  final String idProduit;
  //final List comments;

  @override
  _PageProduitState createState() => _PageProduitState();
}

class _PageProduitState extends State<PageProduit> {
  Widget returnDetailPage() {
    String nomProduit = widget.nomProduit;
    num prixProduit = widget.prixProduit;
    String imgProduit = widget.imagesList[0];
    int amount = 1;
    return FutureBuilder(
        future: DatabaseMethods().addCart(nomProduit, prixProduit, imgProduit,
            amount, widget.idCommercant, widget.idProduit),
        builder: (context, snapshot) {
          return successfullAddCart();
        });
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
        Iterable<int>.generate(widget.imagesList.length).toList();
    String nomVendeur = widget.name;
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
                        widget.imagesList.length > 1 ? true : false,
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
                        child: Image.network(widget.imagesList[i]));
                  });
                }).toList()),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 5),
              for (int i = 0; i < widget.imagesList.length; i++)
                Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: Icon(Icons.circle_rounded,
                        size: 12,
                        color: carouselItem == i ? Colors.grey : Colors.black))
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
                          widget.nomProduit,
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
                    child: Text(widget.descriptionProduit
                        // style: descriptionStyle,
                        ),
                  ),
                  // QuantitySelector(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => returnDetailPage()));
                        },
                        child: Text(
                          'Ajouter au panier',
                          style: TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
