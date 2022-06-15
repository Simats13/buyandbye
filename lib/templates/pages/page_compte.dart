import 'dart:io';

import 'package:buyandbye/templates/pages/page_bienvenue.dart';
import 'package:buyandbye/templates/pages/page_fidelite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/compte/constants.dart';
import 'package:buyandbye/templates/compte/help.dart';
import 'package:buyandbye/templates/compte/user_history.dart';
import 'package:buyandbye/templates/compte/edit_profile.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageCompte extends StatefulWidget {
  const PageCompte({Key? key}) : super(key: key);

  @override
  _PageCompteState createState() => _PageCompteState();
}

class _PageCompteState extends State<PageCompte> {
  String? userid, myProfilePicture, fname, lname, email;

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
    return StreamBuilder<dynamic>(
        stream: DatabaseMethods().getMyInfo2(userid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            myProfilePicture = snapshot.data["imgUrl"];
            fname = snapshot.data["fname"];
            lname = snapshot.data["lname"];
            email = snapshot.data["email"];
          }
          return Scaffold(
              backgroundColor: BuyandByeAppTheme.white,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: AppBar(
                    title: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: 'Mon Compte',
                              style: TextStyle(
                                fontSize: 20,
                                color: BuyandByeAppTheme.orangeMiFonce,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                    backgroundColor: BuyandByeAppTheme.white,
                    automaticallyImplyLeading: false,
                    elevation: 0.0,
                    bottomOpacity: 0.0,
                    actions: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                          },
                          child: Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  myProfilePicture ??
                                      "https://cdn.iconscout.com/icon/free/png-256/account-avatar-profile-human-man-user-30448.png",
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ]),
              ),
              body: ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  membershipCard(),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                      child: Container(
                        height: 75,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Icon(Icons.redeem,
                                size: 35,
                                color: BuyandByeAppTheme.orangeMiFonce),
                            const SizedBox(width: 40),
                            Text(
                              'Compte Fidélité',
                              style: kTitleTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: BuyandByeAppTheme.orangeMiFonce),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageFidelite(
                              firstName: fname,
                              lastName: lname,
                              eMail: email,
                            ),
                          ),
                        );
                      }),
                  const Divider(
                    height: 10,
                    thickness: 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserHistory(),
                        ),
                      );
                    },
                    child: Container(
                      height: 75,
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(LineAwesomeIcons.shopping_bag,
                              size: 35, color: BuyandByeAppTheme.orangeMiFonce),
                          const SizedBox(width: 40),
                          Text(
                            'Mes Commandes',
                            style: kTitleTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: BuyandByeAppTheme.orangeMiFonce),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Help(true, email),
                        ),
                      );
                    },
                    child: Container(
                      height: 75,
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(LineAwesomeIcons.question_circle,
                              size: 35, color: BuyandByeAppTheme.orangeMiFonce),
                          const SizedBox(width: 45),
                          Text(
                            'Aide / Support',
                            style: kTitleTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: BuyandByeAppTheme.orangeMiFonce),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 1,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      if (!Platform.isIOS) {
                        return showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Deconnexion"),
                            content: const Text(
                                "Souhaitez-vous réellement vous déconnecter ?"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Annuler"),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text("Déconnexion"),
                                onPressed: () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();
                                  await preferences.clear();
                                  AuthMethods().signOut().then((s) {
                                    AuthMethods.toogleNavBar();
                                  });
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PageBienvenue()),
                                      (Route<dynamic> route) => false);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        return showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                                  title: const Text("Déconnexion"),
                                  content: const Text(
                                      "Souhaitez-vous réellement vous déconnecter ?"),
                                  actions: [
                                    // Close the dialog
                                    CupertinoButton(
                                        child: const Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                    CupertinoButton(
                                      child: const Text('Déconnexion'),
                                      onPressed: () async {
                                        SharedPreferences preferences =
                                            await SharedPreferences
                                                .getInstance();
                                        await preferences.clear();
                                        AuthMethods().signOut().then((s) {
                                          AuthMethods.toogleNavBar();
                                        });
                                        Navigator.of(
                                                context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const PageBienvenue()),
                                                (Route<dynamic> route) =>
                                                    false);
                                      },
                                    )
                                  ],
                                ));
                      }
                    },
                    child: SizedBox(
                      height: 75,
                      width: 250,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(LineAwesomeIcons.alternate_sign_out,
                              size: 35, color: BuyandByeAppTheme.orangeMiFonce),
                          const SizedBox(width: 40),
                          Text(
                            'Se Déconnecter',
                            style: kTitleTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: BuyandByeAppTheme.orangeMiFonce),
                          ),
                          const SizedBox(width: 15),
                          const Icon(LineAwesomeIcons.angle_right,
                              size: 25, color: BuyandByeAppTheme.orangeMiFonce),
                        ],
                      ),
                    ),
                  ),
                ],
              ));
        });
  }

  membershipCard() {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Container(
        height: 175,
        width: 275,
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/cardBuy&Bye.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 25, 0, 0),
              alignment: Alignment.centerLeft,
              child: const Text("Points Obtenus",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  )),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              alignment: Alignment.centerLeft,
              child: const Text("180 pts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 25, 10, 0),
              alignment: Alignment.bottomRight,
              child: Text("$fname $lname",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ],
        ),
      ),
      back: Container(
        height: 175,
        width: 275,
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/cardBuy&ByeReverse.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          children: [
            QrImage(
              foregroundColor: Colors.white,
              data: "buyandbye.fr",
              version: QrVersions.auto,
              size: 140,
            )
          ],
        ),
      ),
    );
  }
}
