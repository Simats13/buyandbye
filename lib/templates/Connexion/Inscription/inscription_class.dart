import 'dart:async';
import 'dart:io';

import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/main.dart';
import 'package:buyandbye/templates/Connexion/Tools/or_divider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:buyandbye/services/auth.dart';

import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';
import 'package:buyandbye/templates/Pages/pageInscriptionCommercant.dart';
import 'package:buyandbye/templates/Connexion/Login/pageLogin.dart';

import 'package:buyandbye/templates/buyandbye_app_theme.dart';

import 'package:buyandbye/templates/Connexion/Tools/already_have_accountCheck.dart';
import 'package:buyandbye/templates/Connexion/Inscription/background_inscription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';

import '../../accueil.dart';

class BodyInscription extends StatefulWidget {
  BodyInscription({Key? key}) : super(key: key);

  @override
  _BodyInscriptionState createState() => _BodyInscriptionState();
}

class _BodyInscriptionState extends State<BodyInscription> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password, _fname, _lname;
  bool obscureText = true;
  static late SharedPreferences _preferences;

  static const _keyCreatedUser = "UserCreated";
  String? errorMessage;
  bool? isCreated;
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
    return BackgroundInscription(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "INSCRIPTION UTILISATEUR",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Image.asset(
            "assets/icons/signup.png",
            height: size.height * 0.20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Platform.isIOS
                  ? SignInButton.mini(
                      buttonType: ButtonType.apple,
                      onPressed: () async {
                        dynamic user =
                            await AuthMethods.instance.signInWithApple(context);
                        if (user != null) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => Accueil()),
                              (Route<dynamic> route) => false);
                        }
                      })
                  : Container(),
              SignInButton.mini(
                  buttonType: ButtonType.facebook,
                  onPressed: () async {
                    try {
                      await AuthMethods.instance.signInWithFacebook(context);

                      bool checkEmail = await (AuthMethods.instance
                          .checkEmailVerification() as FutureOr<bool>);

                      if (checkEmail == false) {
                        showMessage("Vérification du mail",
                            "Votre adresse mail n'est pas vérifiée, veuillez la vérifier en cliquant sur le mail qui vous a été envoyé.");
                        isCreated = true;
                        await _preferences.setBool(_keyCreatedUser, isCreated!);
                        SharedPreferenceHelper().saveUserCreated(isCreated!);
                      } else {
                        isCreated = false;
                        await _preferences.setBool(_keyCreatedUser, isCreated!);
                        SharedPreferenceHelper().saveUserCreated(isCreated!);
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
                  }),
              SignInButton.mini(
                  buttonType: ButtonType.google,
                  onPressed: () async {
                    try {
                      //Si la variable isCreated est égale à true, dans ce cas un message d'erreur s'affiche pour l'utilisateur
                      if (isCreated == true) {
                        showMessage("Adresse mail non validé",
                            "Vous avez essayé de vous connecter via un autre mode de connexion, veuillez vérifier l'adresse mail avant de vous connectez via ce mode connexion ou lier votre compte depuis l'édition de profil.");
                      } else {
                        bool googleCheck =
                            await AuthMethods.instance.signInwithGoogle();

                        if (googleCheck == true) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ),
                          );
                        }
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
                  }),
            ],
          ),
          OrDivider(),
          TextFieldContainer(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Champ NOM
                  TextFormField(
                    // ignore: missing_return
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Veuillez rentrer votre nom';
                      }
                    },
                    autocorrect: false,
                    decoration: InputDecoration(
                        labelText: 'Votre nom',
                        icon: Icon(
                          Icons.person,
                          color: BuyandByeAppTheme.kLightPrimaryColor,
                        )),
                    onSaved: (input) => _lname = input,
                  ),
                  // Champ PRENOM
                  TextFormField(
                    // ignore: missing_return
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Veuillez rentrer votre prénom';
                      }
                    },
                    autocorrect: false,
                    decoration: InputDecoration(
                        labelText: 'Votre prénom',
                        icon: Icon(
                          Icons.person,
                          color: BuyandByeAppTheme.kLightPrimaryColor,
                        )),
                    onSaved: (input) => _fname = input,
                  ),
                  // Champ EMAIL
                  TextFormField(
                    // ignore: missing_return
                    validator: (input) {
                      if (input!.isEmpty) {
                        return 'Veuillez rentrer une adresse mail';
                      }
                      final regex = RegExp(
                          r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
                      if (!regex.hasMatch(input)) {
                        return 'L\'adresse mail n\'est pas valide';
                      }
                    },
                    autocorrect: false,
                    decoration: InputDecoration(
                        labelText: 'Votre adresse email',
                        icon: Text(
                          "@",
                          style: TextStyle(
                              color: BuyandByeAppTheme.kLightPrimaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        )),
                    onSaved: (input) => _email = input,
                  ),
                  // Champ MOT DE PASSE

                  TextFormField(
                    // ignore: missing_return
                    validator: (input) {
                      if (input!.length < 6) {
                        return 'Veuillez rentrer un mot de passe de plus \nde 6 caractères';
                      }
                    },
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: "Votre mot de passe",
                      icon: Icon(
                        Icons.lock,
                        color: BuyandByeAppTheme.kLightPrimaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        color: BuyandByeAppTheme.kLightPrimaryColor,
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                    onSaved: (input) => _password = input,
                    obscureText: obscureText,
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  AuthMethods()
                      .signUpWithMail(_email!, _password!, _fname, _lname);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Accueil()));
                } catch (e) {
                  print(e);
                }
              }
            },
            child: Text('INSCRIPTION'),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PageLogin();
                  },
                ),
              );
            },
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Êtes-vous un COMMERÇANT ?",
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
                        return PageSignUpCommercant();
                      },
                    ),
                  );
                },
                child: Text(
                  " Créez vous un compte ! ",
                  style: TextStyle(
                    color: BuyandByeAppTheme.kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
