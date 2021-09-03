import 'dart:io';

import 'package:buyandbye/templates/pages/pageLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

import 'editProfileCommercant.dart';

class CompteCommercant extends StatefulWidget {
  _CompteCommercantState createState() => _CompteCommercantState();
}

class _CompteCommercantState extends State<CompteCommercant> {
  String myID;
  String myName, myUserName, myEmail;
  String myProfilePic;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myName = "${querySnapshot.docs[0]["name"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";

    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Container(
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(myProfilePic ??
                      "https://cdn.iconscout.com/icon/free/png-256/account-avatar-profile-human-man-user-30448.png"),

                  // Grosse erreur quand on affiche l'image du magasin
                ),
              ),
            ),
            SizedBox(height: 20),
            myName == null
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        myName ?? "",
                        style: kTitleTextStyle,
                      ),
                      SizedBox(height: 5),
                      Text(
                        myEmail ?? "",
                        style: kCaption2TextStyle,
                      ),
                    ],
                  ),
            SizedBox(height: 20),
            Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: BuyandByeAppTheme.orange, width: 2.0),
              ),
              child: Center(
                child: Text(
                  'Commerçant',
                  style: kButtonTextStyle,
                ),
              ),
            ),
            //
            // Deuxième partie du code
            //
            Container(
              width: MediaQuery.of(context).size.height,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(height: 20),
                Flexible(
                  child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Container(
                          height: 55,
                          margin: EdgeInsets.symmetric(
                            horizontal: 40,
                          ).copyWith(
                            bottom: 20,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: BuyandByeAppTheme.orange, width: 2.0),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileComPage(),
                                ),
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  LineAwesomeIcons.address_card,
                                  size: 25,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Mon Compte',
                                  style: kTitleTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  LineAwesomeIcons.angle_right,
                                  size: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 55,
                          margin: EdgeInsets.symmetric(
                            horizontal: 40,
                          ).copyWith(
                            bottom: 20,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: BuyandByeAppTheme.orange, width: 2.0),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Help(),
                                ),
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  LineAwesomeIcons.question_circle,
                                  size: 25,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Aide / Support',
                                  style: kTitleTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  LineAwesomeIcons.angle_right,
                                  size: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 55,
                          margin: EdgeInsets.symmetric(
                            horizontal: 40,
                          ).copyWith(
                            bottom: 20,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: BuyandByeAppTheme.orange, width: 2.0),
                          ),
                          child: MaterialButton(
                            onPressed: () async {
                              if (!Platform.isIOS) {
                                return showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Deconnexion"),
                                    content: Text(
                                        "Souhaitez-vous réellement vous déconnecter ?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Annuler"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: Text("Déconnexion"),
                                        onPressed: () async {
                                          SharedPreferences preferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          await preferences.clear();
                                          AuthMethods().signOut().then((s) {
                                            AuthMethods.toogleNavBar();
                                          });
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PageLogin()),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                          title: Text("Déconnexion"),
                                          content: Text(
                                              "Souhaitez-vous réellement vous déconnecter ?"),
                                          actions: [
                                            // Close the dialog
                                            CupertinoButton(
                                                child: Text('Annuler'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                }),
                                            CupertinoButton(
                                              child: Text('Déconnexion'),
                                              onPressed: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await preferences.clear();
                                                AuthMethods()
                                                    .signOut()
                                                    .then((s) {
                                                  AuthMethods.toogleNavBar();
                                                });
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PageLogin()),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              },
                                            )
                                          ],
                                        ));
                              }
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  LineAwesomeIcons.alternate_sign_out,
                                  size: 25,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Se déconnecter',
                                  style: kTitleTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  LineAwesomeIcons.angle_right,
                                  size: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
