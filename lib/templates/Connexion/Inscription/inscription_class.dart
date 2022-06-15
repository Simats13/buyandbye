import 'dart:async';
import 'dart:io';

import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/main.dart';
import 'package:buyandbye/templates/Connexion/Tools/or_divider.dart';
import 'package:buyandbye/templates_commercant/accueil_commercant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:buyandbye/services/auth.dart';

import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';

import 'package:buyandbye/templates/buyandbye_app_theme.dart';

import 'package:buyandbye/templates/Connexion/Inscription/background_inscription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';

import '../../accueil.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email, _password, _fname, _lname;
  bool obscureText = true;
  static late SharedPreferences _preferences;

  static const _keyCreatedUser = "UserCreated";
  String? errorMessage;
  bool? isCreated;
  var userType = <bool>[false, false];
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: BackgroundInscription(
            child: Stack(
          children: [
            SizedBox(width: size.width),
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
                  "INSCRIPTION",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  "assets/icons/signup.png",
                  height: size.height * 0.20,
                ),
                const SizedBox(height: 20),
                // Sélection du type d'utilisateur
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  ToggleButtons(
                    color: Colors.black.withOpacity(0.60),
                    selectedColor: const Color(0xFF6200EE),
                    selectedBorderColor: const Color(0xFF6200EE),
                    fillColor: const Color(0xFF6200EE).withOpacity(0.08),
                    splashColor: const Color(0xFF6200EE).withOpacity(0.12),
                    hoverColor: const Color(0xFF6200EE).withOpacity(0.04),
                    borderRadius: BorderRadius.circular(4.0),
                    constraints: const BoxConstraints(minHeight: 36.0),
                    isSelected: userType,
                    onPressed: (index) {
                      // Respond to button selection
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < userType.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            userType[buttonIndex] = true;
                          } else {
                            userType[buttonIndex] = false;
                          }
                        }
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Client'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Commerçant'),
                      ),
                    ],
                  )
                ]),
                // Partie inscription
                // Masquée si aucun des types d'utilisateur n'est sélectionné
                Visibility(
                  visible: !(!userType[0] && !userType[1]),
                  child: Column(children: [
                    SizedBox(height: size.height * 0.02),
                    // Affiche l'inscription par Apple, Facebook et Google seulement seulement pour les clients
                    Visibility(
                      visible: userType[0],
                      child: Column(
                        children: [
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
                                                  builder:
                                                      (BuildContext context) =>
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
      
                                      bool checkEmail = await (AuthMethods
                                              .instance
                                              .checkEmailVerification()
                                          as FutureOr<bool>);
      
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
                                              "Adresse mail déjà existante",
                                              erreur);
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
                                        bool googleCheck = await AuthMethods
                                            .instance
                                            .signInwithGoogle();
      
                                        if (googleCheck == true) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const MyApp(),
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
                                          showMessage(
                                              "Adresse mail déjà existante",
                                              erreur);
                                        }
                                      }
                                    }
                                  }),
                            ],
                          ),
                          const OrDivider(),
                        ],
                      ),
                    ),
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
                                return null;
                              },
                              autocorrect: false,
                              decoration: const InputDecoration(
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
                                return null;
                              },
                              autocorrect: false,
                              decoration: const InputDecoration(
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
                                return null;
                              },
                              autocorrect: false,
                              decoration: const InputDecoration(
                                  labelText: 'Votre adresse email',
                                  icon: Text(
                                    "@",
                                    style: TextStyle(
                                        color:
                                            BuyandByeAppTheme.kLightPrimaryColor,
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
                                return null;
                              },
                              autocorrect: false,
                              decoration: InputDecoration(
                                hintText: "Votre mot de passe",
                                icon: const Icon(
                                  Icons.lock,
                                  color: BuyandByeAppTheme.kLightPrimaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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
                    SizedBox(height: size.height * 0.03),
                    Container(
                      height: size.height / 25,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: BuyandByeAppTheme.orange,
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (userType[0]) {
                              try {
                                AuthMethods().signUpWithMail(
                                    _email!, _password!, _fname, _lname);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const Accueil()),
                                    (Route<dynamic> route) => false);
                              } catch (e) {
                                print(e);
                              }
                            } else {
                              try {
                                AuthMethods().signUpWithMailSeller(
                                    _email!, _password!, _fname, _lname);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const AccueilCommercant()),
                                    (Route<dynamic> route) => false);
                              } catch (e) {
                                print(e);
                              }
                            }
                          }
                        },
                        child: const Text('INSCRIPTION'),
                      ),
                    ),
                  ]),
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
