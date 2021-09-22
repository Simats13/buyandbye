import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Compte/constants.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Compte/help.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembershipStore extends StatefulWidget {
  _MembershipStore createState() => _MembershipStore();
}

class _MembershipStore extends State<MembershipStore> {
  String userid;
  bool premium;

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
        body: StreamBuilder(
            stream: DatabaseMethods().getSellerInfo(userid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                premium = snapshot.data["premium"];
              }
              return Container(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Text(
                            "Abonnement",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
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
                        "Selectionnez votre abonnement",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    membershipCard(premium),
                    membershipCard2(premium),
                  ],
                ),
              );
            }));
  }

  membershipCard(premium) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(-3, -3),
                  color: Color(0xffA2CAEF).withOpacity(0.2),
                  spreadRadius: 6,
                  blurRadius: 6)
            ],
            borderRadius: BorderRadius.circular(15),
            color: Color(0xffA2CAEF).withOpacity(0.6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                      boxShadow: [
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
                      ],
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [Color(0xffFE9B4D), Color(0xffFE8032)])),
                  child: Icon(
                    Icons.favorite,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Abonnement Classique",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Color(0xff63A6E4),
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "Par mois",
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Fonctionnalités",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Plus de Détails",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: Container(
                height: 2,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gratuit",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Spacer(),
                MaterialButton(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(-5, -3),
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5)
                        ],
                        gradient: LinearGradient(
                            colors: [Color(0xffFE9B4D), Color(0xffFE8032)]),
                        borderRadius: BorderRadius.circular(20)),
                    child: premium == false
                        ? Text(
                            "Actuel",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            "Souscrire",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                  ),
                  onPressed: () {
                    DatabaseMethods().accountfree();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  membershipCard2(premium) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(-3, -3),
                  color: Color(0xffA2CAEF).withOpacity(0.2),
                  spreadRadius: 6,
                  blurRadius: 6)
            ],
            borderRadius: BorderRadius.circular(15),
            color: Color(0xffA2CAEF).withOpacity(0.6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                      boxShadow: [
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
                      ],
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [Color(0xffFE9B4D), Color(0xffFE8032)])),
                  child: Icon(
                    Icons.favorite,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Abonnement Premium",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Color(0xff63A6E4),
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "par mois",
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Fonctionnalités",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Plus de Details",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: Container(
                height: 2,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "19,99\€",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Spacer(),
                MaterialButton(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(-5, -3),
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5)
                        ],
                        gradient: LinearGradient(
                            colors: [Color(0xffFE9B4D), Color(0xffFE8032)]),
                        borderRadius: BorderRadius.circular(20)),
                    child: premium == false
                        ? Text(
                            "Souscrire",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            "Actuel",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                  ),
                  onPressed: () {
                    DatabaseMethods().accountpremium();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
