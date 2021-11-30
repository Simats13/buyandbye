import 'dart:io';

import 'package:buyandbye/templates/Connexion/Login/pageLogin.dart';
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
              GridView.count(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(LineAwesomeIcons.address_card,
                                size: 35,
                                color: BuyandByeAppTheme.orangeMiFonce),
                            SizedBox(height: 5),
                            Text(
                              'Mon Compte',
                              style: kTitleTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: BuyandByeAppTheme.orangeMiFonce,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                      child: Card(
                        margin: EdgeInsets.all(1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.redeem,
                                  size: 35,
                                  color: BuyandByeAppTheme.orangeMiFonce),
                              SizedBox(height: 5),
                              Text(
                                'Compte Fidélité',
                                style: kTitleTextStyle.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: BuyandByeAppTheme.orangeMiFonce),
                              ),
                            ],
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
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserHistory(),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(LineAwesomeIcons.shopping_bag,
                                size: 35,
                                color: BuyandByeAppTheme.orangeMiFonce),
                            SizedBox(height: 5),
                            Text(
                              'Mes commandes',
                              style: kTitleTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: BuyandByeAppTheme.orangeMiFonce),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    child: Card(
                      margin: EdgeInsets.all(1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(LineAwesomeIcons.question_circle,
                                size: 35,
                                color: BuyandByeAppTheme.orangeMiFonce),
                            SizedBox(height: 5),
                            Text(
                              'Aide / Support',
                              style: kTitleTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: BuyandByeAppTheme.orangeMiFonce),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                width: 275,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: Colors.red),
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
                              onPressed: () => Navigator.of(context).pop(false),
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
                                          await SharedPreferences.getInstance();
                                      await preferences.clear();
                                      AuthMethods().signOut().then((s) {
                                        AuthMethods.toogleNavBar();
                                      });
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PageLogin()),
                                          (Route<dynamic> route) => false);
                                    },
                                  )
                                ],
                              ));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(LineAwesomeIcons.alternate_sign_out,
                          size: 30, color: Colors.white),
                      SizedBox(width: 15),
                      Text(
                        'Se déconnecter',
                        style: kTitleTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      SizedBox(width: 15),
                      Icon(LineAwesomeIcons.angle_right,
                          size: 30, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
