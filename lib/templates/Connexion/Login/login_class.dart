import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oficihome/templates/accueil.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/Connexion/Inscription/inscription_class.dart';

import 'package:oficihome/templates/widgets/chargement.dart';
import 'package:oficihome/templates/pages/pageInscription.dart';

import 'package:oficihome/templates/Connexion/Login/background_login.dart';
import 'package:oficihome/templates/Connexion/Tools/bouton.dart';
import 'package:oficihome/templates/Connexion/Tools/or_divider.dart';
import 'package:oficihome/templates/Connexion/Tools/social_icon.dart';

import 'package:oficihome/templates/Connexion/Tools/rounded_input_field.dart';
import 'package:oficihome/templates/Connexion/Tools/rounded_password_field.dart';
import 'package:oficihome/templates/Connexion/Tools/already_have_accountCheck.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthMethods>(context, listen: false);
      final user = await authService.signInWithApple();
      print('uid: ${user.uid}');
    } catch (e) {
      // TODO: Show alert here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool enCoursChargement = false;
    Size size = MediaQuery.of(context).size;
    return enCoursChargement
        ? Chargement()
        : Background(
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
                  SvgPicture.asset(
                    "assets/icons/login.svg",
                    height: size.height * 0.30,
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialIcon(
                        iconSrc: "assets/icons/apple.svg",
                        press: () async {
                          dynamic user =
                              await AuthMethods.instanace.signInWithApple();
                          if (user != null) {
                            Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => Accueil()));
                          }
                        },
                      ),
                      SocialIcon(
                        iconSrc: "assets/icons/facebook.svg",
                        press: () {},
                      ),
                      SocialIcon(
                        iconSrc: "assets/icons/google-plus.svg",
                        press: () async {
                          setState(() {
                            enCoursChargement = true;
                          });
                          dynamic result = await AuthMethods.instanace
                              .signInWithGoogle(context);
                          if (result == null) {
                            setState(() {
                              enCoursChargement = false;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                  OrDivider(),
                  RoundedInputField(
                    hintText: "Votre adresse e-mail",
                    onChanged: (value) {},
                  ),
                  RoundedPasswordField(
                    onChanged: (value) {},
                  ),
                  RoundedButton(
                    text: "CONNEXION",
                    press: () {},
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  AlreadyHaveAnAccountCheck(
                    press: () {
                      Navigator.pop(context, MaterialPageRoute(
                        builder: (context) {
                          return BodyInscription(
                            child: Column(),
                          );
                        },
                      ));
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
