import 'dart:io';

import 'package:buyandbye/templates/Pages/pageLogin.dart';
import 'package:buyandbye/templates/pages/pageFidelite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/compte/constants.dart';
import 'package:buyandbye/templates/compte/help.dart';
import 'package:buyandbye/templates/compte/user_history.dart';
import 'package:buyandbye/templates/compte/editProfile.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageCompte extends StatefulWidget {
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
          return Column(
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                height: 100,
                width: 100,
                margin: EdgeInsets.only(top: 30),
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
              SizedBox(height: 20),
              fname == null
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        Text(
                          fname! + " " + lname!,
                          style: kTitleTextStyle,
                        ),
                        SizedBox(height: 5),
                        Text(
                          email!,
                          style: kCaption2TextStyle,
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              MaterialButton(
                  child: Container(
                    height: 40,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: BuyandByeAppTheme.orange, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        'Compte Fidélité',
                        style: kButtonTextStyle,
                      ),
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
              ListView(
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
                            builder: (context) => EditProfilePage(),
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
                  SizedBox(height: 10),
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserHistory(),
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            LineAwesomeIcons.shopping_bag,
                            size: 25,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Mes commandes',
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
                  SizedBox(height: 10),
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
                            builder: (context) => Help(true, email),
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
                  SizedBox(height: 10),
                  // Bouton de déconnexion
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
                                        await SharedPreferences.getInstance();
                                    await preferences.clear();
                                    AuthMethods().signOut().then((s) {
                                      AuthMethods.toogleNavBar();
                                    });
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => PageLogin()),
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
                ],
              ),
            ],
          );
        });
  }
}
