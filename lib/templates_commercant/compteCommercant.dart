import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/Compte/constants.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/Compte/help.dart';
import 'package:oficihome/templates/Pages/pageBienvenue.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

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
    if (myProfilePic == null) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Container(
              height: 120,
              width: 120,
              margin: EdgeInsets.only(top: 30),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CircularProgressIndicator(),
                    // Grosse erreur quand on affiche l'image du magasin
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 5),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: OficihomeAppTheme.orange,
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
                SizedBox(height: 50),
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
                            color: OficihomeAppTheme.orange,
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
                        SizedBox(height: 20),
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
                            color: OficihomeAppTheme.orange,
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
                        SizedBox(height: 20),
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
                            color: OficihomeAppTheme.orange,
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              AuthMethods().signOut().then((s) {
                                AuthMethods.toogleNavBar();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PageBievenue()));
                              });
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
      );
    } else {
      return Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(myProfilePic ??
                        "https://cdn.iconscout.com/icon/free/png-256/account-avatar-profile-human-man-user-30448.png"),

                    // Grosse erreur quand on affiche l'image du magasin
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              myName ?? "",
              style: kTitleTextStyle,
            ),
            SizedBox(height: 5),
            Text(
              myEmail ?? "",
              style: kCaption2TextStyle,
            ),
            SizedBox(height: 20),
            Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: OficihomeAppTheme.orange,
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
                SizedBox(height: 50),
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
                            color: OficihomeAppTheme.orange,
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
                        SizedBox(height: 20),
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
                            color: OficihomeAppTheme.orange,
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
                        SizedBox(height: 20),
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
                            color: OficihomeAppTheme.orange,
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              AuthMethods().signOut().then((s) {
                                AuthMethods.toogleNavBar();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PageBievenue()));
                              });
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
      );
    }
  }
}
