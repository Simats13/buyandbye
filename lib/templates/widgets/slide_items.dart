import 'package:buyandbye/templates/Pages/pageDetail.dart';
import 'package:flutter/material.dart';

class SlideItem extends StatefulWidget {
  final String img;
  final String name;
  final String address;
  final List mainCategorie;
  final String colorStore;
  final String description;
  final bool clickAndCollect;
  final bool livraison;
  final String sellerID;
  final Map horairesOuverture;

  SlideItem({
    Key? key,
    required this.img,
    required this.name,
    required this.address,
    required this.mainCategorie,
    required this.colorStore,
    required this.description,
    required this.clickAndCollect,
    required this.livraison,
    required this.sellerID,
    required this.horairesOuverture,
  }) : super(key: key);

  @override
  _SlideItemState createState() => _SlideItemState();
}

class _SlideItemState extends State<SlideItem> {
  mainCategorie() {
    for (String categorie in widget.mainCategorie) {
      print(categorie);
      return Text(categorie);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 2.9,
          width: MediaQuery.of(context).size.width / 1.2,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 3.0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageDetail(
                      img: widget.img,
                      colorStore: widget.colorStore,
                      name: widget.name,
                      description: widget.description,
                      adresse: widget.address,
                      clickAndCollect: widget.clickAndCollect,
                      livraison: widget.livraison,
                      sellerID: widget.sellerID,
                      horairesOuverture: widget.horairesOuverture,
                    ),
                  ),
                );
              },
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 3.2,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Image.network(
                            widget.img,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                          top: 6.0,
                          right: 6.0,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.sell_outlined),
                                      Text("-50%",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )))),
                      Positioned(
                        top: 6.0,
                        left: 6.0,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              " OUVERT ",
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.0),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 180,
                            child: Text(
                                "${widget.name}",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.left,
                              ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.screen_search_desktop_outlined),
                                Icon(
                                  widget.clickAndCollect
                                      ? Icons.check_circle
                                      : Icons.highlight_off,
                                  color: widget.clickAndCollect
                                      ? Colors.green
                                      : Colors.red,
                                  size: 17,
                                ),
                                Icon(Icons.delivery_dining),
                                Icon(
                                  widget.livraison
                                      ? Icons.check_circle
                                      : Icons.highlight_off,
                                  color: widget.livraison
                                      ? Colors.green
                                      : Colors.red,
                                  size: 17,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            for (String categorie in widget.mainCategorie)
                              Card(
                                shadowColor: Colors.grey.withOpacity(0.2),
                                color: Colors.grey.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(" $categorie "),
                                ),
                              )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
