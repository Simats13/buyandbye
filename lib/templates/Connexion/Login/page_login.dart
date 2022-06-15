import 'dart:async';
import 'dart:io';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';

import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

import 'package:buyandbye/services/auth.dart';

import 'package:buyandbye/templates/Connexion/Login/background_login.dart';

import 'package:buyandbye/templates/Connexion/Tools/or_divider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sign_button/sign_button.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  _PageLoginState createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password;
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
                  child: const Text("Ok"),
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
                      child: const Text('OK'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      }),
                ],
              ));
    }
  }

  bool showPassword = true;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Background(
          child: Stack(
            children: [
              SafeArea(
                  child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
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
                          ? SignInButton.mini(
                              buttonType: ButtonType.apple,
                              onPressed: () async {
                                dynamic user = await AuthMethods.instance
                                    .signInWithApple(context);
                                if (user != null) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Accueil()),
                                      (Route<dynamic> route) => false);
                                }
                              })
                          : Container(),
                      SignInButton.mini(
                          buttonType: ButtonType.facebook,
                          onPressed: () async {
                            try {
                              await AuthMethods.instance
                                  .signInWithFacebook(context);
      
                              bool checkEmail = await (AuthMethods.instance
                                  .checkEmailVerification() as FutureOr<bool>);
      
                              if (checkEmail == false) {
                                showMessage("Vérification du mail",
                                    "Votre adresse mail n'est pas vérifiée, veuillez la vérifier en cliquant sur le mail qui vous a été envoyé.");
                                isCreated = true;
                                await _preferences.setBool(
                                    _keyCreatedUser, isCreated!);
                                SharedPreferenceHelper()
                                    .saveUserCreated(isCreated!);
                              } else {
                                isCreated = false;
                                await _preferences.setBool(
                                    _keyCreatedUser, isCreated!);
                                SharedPreferenceHelper()
                                    .saveUserCreated(isCreated!);
                              }
                            } catch (e) {
                              if (e is FirebaseAuthException) {
                                print(e);
                                if (e.code ==
                                    'account-exists-with-different-credential') {
                                  String erreur =
                                      "Un compte existe déjà avec cette adresse mail, veuillez le lier à votre compte depuis les paramètres du compte.";
                                  showMessage(
                                      "Adresse mail déjà existante", erreur);
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
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const MainScreen()),
                                      (Route<dynamic> route) => false);
                                }
                              }
                            } catch (e) {
                              if (e is FirebaseAuthException) {
                                print(e);
                                if (e.code ==
                                    'account-exists-with-different-credential') {
                                  String erreur =
                                      "Un compte existe déjà avec cette adresse mail, veuillez le lier à votre compte depuis les paramètres du compte.";
                                  showMessage(
                                      "Adresse mail déjà existante", erreur);
                                }
                              }
                            }
                          }),
                    ],
                  ),
                  const OrDivider(),
                  TextFieldContainer(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            // ignore: missing_return
                            validator: (input) {
                              if (input!.isEmpty) {
                                setState(() {
                                  errorMessage = null;
                                });
                                return 'Veuillez entrer une adresse email';
                              }
                              return null;
                            },
                            autocorrect: false,
                            decoration: const InputDecoration(
                                labelText: 'Votre adresse email',
                                icon: Icon(
                                  Icons.person,
                                  color: BuyandByeAppTheme.kLightPrimaryColor,
                                )),
                            onSaved: (input) => _email = input,
                          ),
                          const SizedBox(height: 5),
                          ((errorMessage == "Utilisateur introuvable" ||
                                      errorMessage ==
                                          "Le mail n'est pas au bon format") &&
                                  _email != null)
                              ? Row(children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          10.75),
                                  Text(errorMessage!,
                                      style: const TextStyle(
                                          color: Color.fromRGBO(210, 40, 40, 1),
                                          fontSize: 12))
                                ])
                              : const SizedBox.shrink(),
                          TextFormField(
                            // ignore: missing_return
                            validator: (input) {
                              if (input!.isEmpty) {
                                setState(() {
                                  errorMessage = null;
                                });
                                return 'Veuillez entrer un mot de passe';
                              }
                              return null;
                            },
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: "Mot de passe",
                              icon: const Icon(
                                Icons.lock,
                                color: BuyandByeAppTheme.kLightPrimaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                color: BuyandByeAppTheme.kLightPrimaryColor,
                              ),
                              border: InputBorder.none,
                            ),
                            onSaved: (input) => _password = input,
                            obscureText: showPassword,
                          ),
                          (errorMessage != "Utilisateur introuvable" &&
                                  errorMessage !=
                                      "Le mail n'est pas au bon format" &&
                                  errorMessage != null &&
                                  _password != null)
                              ? Row(children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          10.75),
                                  Text(errorMessage!,
                                      style: const TextStyle(
                                          color: Color.fromRGBO(210, 40, 40, 1),
                                          fontSize: 12))
                                ])
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: size.height / 20,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: BuyandByeAppTheme.orangeMiFonce,
                    ),
                    child: MaterialButton(
                      child: const Text('CONNEXION'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          AuthMethods()
                              .signInWithMail(_email!, _password!)
                              .then((User user) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => const MyApp()),
                                (Route<dynamic> route) => false);
                          }).catchError((e) {
                            switch (e.code) {
                              case "user-not-found":
                                setState(() {
                                  errorMessage = "Utilisateur introuvable";
                                });
                                print(e.code);
                                break;
                              case "wrong-password":
                                setState(() {
                                  errorMessage = "Mauvais mot de passe";
                                });
                                print(e.code);
                                break;
                              case "too-many-requests":
                                setState(() {
                                  errorMessage =
                                      "Trop de tentatives. Réessayez plus tard";
                                });
                                print(e.code);
                                break;
                              case "invalid-email":
                                setState(() {
                                  errorMessage =
                                      "Le mail n'est pas au bon format";
                                });
                                print(e.code);
                                break;
                              default:
                                setState(() {
                                  errorMessage = "Erreur indéfinie";
                                });
                                print(e.code);
                                break;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
