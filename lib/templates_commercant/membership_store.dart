import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/services/auth.dart';

class MembershipStore extends StatefulWidget {
  const MembershipStore({Key? key}) : super(key: key);

  @override
  _MembershipStore createState() => _MembershipStore();
}

class _MembershipStore extends State<MembershipStore> {
  String? userid;
  bool? premium;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<dynamic>(
            stream: DatabaseMethods().getSellerInfo(userid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                premium = snapshot.data["premium"];
              }
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Text(
                          "Abonnement",
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        MaterialButton(
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    offset: const Offset(-8, -1),
                                    spreadRadius: 2,
                                    blurRadius: 5),
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(2, 2),
                                    spreadRadius: 4,
                                    blurRadius: 5)
                              ], shape: BoxShape.circle, color: Colors.white),
                              child: const Icon(Icons.close)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20),
                    child: Text(
                      "Selectionnez votre abonnement",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  membershipCard(premium),
                  membershipCard2(premium),
                ],
              );
            }));
  }

  membershipCard(premium) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: const Offset(-3, -3),
                  color: const Color(0xffA2CAEF).withOpacity(0.2),
                  spreadRadius: 6,
                  blurRadius: 6)
            ],
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xffA2CAEF).withOpacity(0.6)),
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
                            offset: const Offset(-8, -1),
                            spreadRadius: 2,
                            blurRadius: 5),
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(2, 2),
                            spreadRadius: 4,
                            blurRadius: 5)
                      ],
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xffFE9B4D), Color(0xffFE8032)])),
                  child: const Icon(
                    Icons.favorite,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Abonnement Classique",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: const Color(0xff63A6E4),
                            borderRadius: BorderRadius.circular(15)),
                        child: const Text(
                          "Par mois",
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "Fonctionnalités",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
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
                  children: const [
                    Text(
                      "Gratuit",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const Spacer(),
                MaterialButton(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(-5, -3),
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5)
                        ],
                        gradient: const LinearGradient(
                            colors: [Color(0xffFE9B4D), Color(0xffFE8032)]),
                        borderRadius: BorderRadius.circular(20)),
                    child: premium == false
                        ? const Text(
                            "Actuel",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : const Text(
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: const Offset(-3, -3),
                  color: const Color(0xffA2CAEF).withOpacity(0.2),
                  spreadRadius: 6,
                  blurRadius: 6)
            ],
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xffA2CAEF).withOpacity(0.6)),
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
                            offset: const Offset(-8, -1),
                            spreadRadius: 2,
                            blurRadius: 5),
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(2, 2),
                            spreadRadius: 4,
                            blurRadius: 5)
                      ],
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xffFE9B4D), Color(0xffFE8032)])),
                  child: const Icon(
                    Icons.favorite,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Abonnement Premium",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: const Color(0xff63A6E4),
                            borderRadius: BorderRadius.circular(15)),
                        child: const Text(
                          "par mois",
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "Fonctionnalités",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
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
                  children: const [
                    Text(
                      "19,99€",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const Spacer(),
                MaterialButton(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(-5, -3),
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5)
                        ],
                        gradient: const LinearGradient(
                            colors: [Color(0xffFE9B4D), Color(0xffFE8032)]),
                        borderRadius: BorderRadius.circular(20)),
                    child: premium == false
                        ? const Text(
                            "Souscrire",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        : const Text(
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
