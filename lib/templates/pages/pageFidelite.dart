import 'package:buyandbye/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PageFidelite extends StatefulWidget {
  @override
  const PageFidelite({Key key, this.firstName, this.lastName, this.eMail})
      : super(key: key);

  final String firstName;
  final String lastName;
  final String eMail;
  _PageFideliteState createState() => _PageFideliteState();
}

class _PageFideliteState extends State<PageFidelite> {
  String userid;

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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    "Compte de Fidélité",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  MaterialButton(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              offset: Offset(-8, -1),
                              spreadRadius: 2,
                              blurRadius: 5),
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(2, 2),
                              spreadRadius: 4,
                              blurRadius: 5)
                        ], shape: BoxShape.circle, color: Colors.white),
                        child: Icon(Icons.close)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Text(
                "Fidéliser vos achats",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            membershipCard(),
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 250,
                  child: Text(
                    "Grâce à notre carte de fidélité, profitez de vos magasins et produits préférés à petits prix ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Text(
                    "Comment gagner des points de fidélité ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: 250,
                  child: Text(
                    "C'est simple !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 250,
                  child: Text(
                    "1€ = 5 point",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 250,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text.rich(TextSpan(text: "Dès "),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              )),
                          Text.rich(
                            TextSpan(text: "200 points "),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                            text:
                                "tu peux les utiliser afin de réduire le prix de tes produits préférés !"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  membershipCard() {
    return Container(
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 200,
            width: 200,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/cardBuy&Bye.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(20, 125, 0, 0),
                  child: Row(children: [
                    Text(widget.firstName + " " + widget.lastName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        )),
                    SizedBox(
                      width: 100,
                    ),
                    Container(
                      child: Text("180 pts",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
        back: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 200,
            width: 200,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/cardBuy&ByeReverse.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: Column(
              children: [
                Container(
                  child: QrImage(
                    data: "buyandbye.fr",
                    version: QrVersions.auto,
                    size: 150,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
