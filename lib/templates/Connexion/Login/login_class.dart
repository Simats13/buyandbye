import 'dart:io';

import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/main.dart';
import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';
import 'package:buyandbye/templates/Pages/pageInscription.dart';

import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

import 'package:buyandbye/services/auth.dart';

import 'package:buyandbye/templates/Connexion/Login/background_login.dart';

import 'package:buyandbye/templates/Connexion/Tools/or_divider.dart';
import 'package:buyandbye/templates/Connexion/Tools/social_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;
  static SharedPreferences _preferences;

  static const _keyCreatedUser = "UserCreated";
  bool isCreated;

  @override
  void initState() {
    super.initState();
    userInfo();
  }

  userInfo() async {
    isCreated = await SharedPreferenceHelper().getUserCreated() ?? false;
  }

  showMessage(String titre, e) {
    if (!Platform.isIOS) {
      showDialog(
          context: context,
          builder: (BuildContext builderContext) {
            return AlertDialog(
              title: Text(titre),
              content: Text(e),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () async {
                    Navigator.of(builderContext).pop();
                  },
                )
              ],
            );
          });
    } else {
      return showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text(titre),
                content: Text(e),
                actions: [
                  // Close the dialog
                  CupertinoButton(
                      child: Text('OK'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      }),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "CONNEXION",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Image.asset(
              "assets/icons/login.png",
              height: size.height * 0.30,
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Platform.isIOS
                    ? SocialIcon(
                        iconSrc: "assets/icons/apple.svg",
                        press: () async {
                          dynamic user =
                              await AuthMethods.instanace.signInWithApple();
                          if (user != null) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Accueil()),
                                (Route<dynamic> route) => false);
                          }
                        },
                      )
                    : "",
                SocialIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () async {
                    try {
                      await AuthMethods.instanace.signInWithFacebook(context);

                      bool checkEmail =
                          await AuthMethods.instanace.checkEmailVerification();

                      if (checkEmail == false) {
                        showMessage("Vérification du mail",
                            "Votre adresse mail n'est pas vérifiée, veuillez la vérifier en cliquant sur le mail qui vous a été envoyé.");
                        isCreated = true;
                        await _preferences.setBool(_keyCreatedUser, isCreated);
                        SharedPreferenceHelper().saveUserCreated(isCreated);
                      } else {
                        isCreated = false;
                        await _preferences.setBool(_keyCreatedUser, isCreated);
                        SharedPreferenceHelper().saveUserCreated(isCreated);
                      }
                    } catch (e) {
                      if (e is FirebaseAuthException) {
                        print(e);
                        if (e.code ==
                            'account-exists-with-different-credential') {
                          String erreur =
                              "Un compte existe déjà avec cette adresse mail, veuillez le lier à votre compte depuis les paramètres du compte.";
                          showMessage("Adresse mail déjà existante", erreur);
                        }
                      }
                    }
                  },
                ),
                SocialIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () async {
                    try {
                      //Si la variable isCreated est égale à true, dans ce cas un message d'erreur s'affiche pour l'utilisa
                      if (isCreated == true) {
                        showMessage("Adresse mail non validé",
                            "Vous avez essayé de vous connecter via un autre mode de connexion, veuillez vérifier l'adresse mail avant de vous connectez via ce mode connexion ou lier votre compte depuis l'édition de profil.");
                      } else {
                        await AuthMethods.instanace.signInwithGoogle(context);
                      }
                    } catch (e) {
                      if (e is FirebaseAuthException) {
                        print(e);
                        if (e.code ==
                            'account-exists-with-different-credential') {
                          String erreur =
                              "Un compte existe déjà avec cette adresse mail, veuillez le lier à votre compte depuis les paramètres du compte.";
                          showMessage("Adresse mail déjà existante", erreur);
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            OrDivider(),
            TextFieldContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      // ignore: missing_return
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Veuillez rentrer une adresse email';
                        }
                      },
                      autocorrect: false,
                      decoration: InputDecoration(
                          labelText: 'Votre adresse email',
                          icon: Icon(
                            Icons.person,
                            color: BuyandByeAppTheme.kLightPrimaryColor,
                          )),
                      onSaved: (input) => _email = input,
                    ),
                    TextFormField(
                      // ignore: missing_return
                      validator: (input) {
                        if (input.length < 6) {
                          return 'Mauvais mot de passe';
                        }
                      },
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: "Votre mot de passe",
                        icon: Icon(
                          Icons.lock,
                          color: BuyandByeAppTheme.kLightPrimaryColor,
                        ),
                        suffixIcon: Icon(
                          Icons.visibility,
                          color: BuyandByeAppTheme.kLightPrimaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      onSaved: (input) => _password = input,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  AuthMethods()
                      .signInWithMail(_email, _password)
                      .then((User user) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => MyApp()));
                  }).catchError((e) => print(e));
                }
              },
              child: Text('CONNEXION'),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Pas de compte ?",
                  style: TextStyle(
                    color: BuyandByeAppTheme.kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SignUpScreen();
                        },
                      ),
                    );
                  },
                  child: Text(
                    " Crée en un ! ",
                    style: TextStyle(
                      color: BuyandByeAppTheme.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
