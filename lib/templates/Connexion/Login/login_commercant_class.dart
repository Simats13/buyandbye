import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/main.dart';
import 'package:oficihome/templates/Connexion/Tools/text_field_container.dart';
import 'package:oficihome/templates/Pages/pageInscriptionCommercant.dart';

import 'package:oficihome/templates/oficihome_app_theme.dart';

import 'package:oficihome/services/auth.dart';

import 'package:oficihome/templates/Connexion/Login/background_login.dart';

class LoginCommercant extends StatefulWidget {
  LoginCommercant({Key key}) : super(key: key);

  @override
  _LoginCommercantState createState() => _LoginCommercantState();
}

class _LoginCommercantState extends State<LoginCommercant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "CONNEXION COMMERÇANT",
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
                      decoration: InputDecoration(
                          labelText: 'Votre adresse email',
                          icon: Icon(
                            Icons.person,
                            color: OficihomeAppTheme.kLightPrimaryColor,
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
                      decoration: InputDecoration(
                        hintText: "Votre mot de passe",
                        icon: Icon(
                          Icons.lock,
                          color: OficihomeAppTheme.kLightPrimaryColor,
                        ),
                        suffixIcon: Icon(
                          Icons.visibility,
                          color: OficihomeAppTheme.kLightPrimaryColor,
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
                  "Pas de compte COMMERÇANT ?",
                  style: TextStyle(
                    color: OficihomeAppTheme.kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PageSignUpCommercant()));
                  },
                  child: Text(
                    " Crée en un ! ",
                    style: TextStyle(
                      color: OficihomeAppTheme.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Êtes-vous un UTILISATEUR ?",
                  style: TextStyle(
                    color: OficihomeAppTheme.kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    " Connectez-vous ici ! ",
                    style: TextStyle(
                      color: OficihomeAppTheme.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
