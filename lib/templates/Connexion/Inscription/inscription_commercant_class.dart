import 'package:flutter/material.dart';
import 'package:oficihome/services/auth.dart';

import 'package:oficihome/templates/Connexion/Tools/text_field_container.dart';
import 'package:oficihome/templates/Pages/pageLogin.dart';

import 'package:oficihome/templates/oficihome_app_theme.dart';

import 'package:oficihome/templates/Connexion/Inscription/background_inscription.dart';
import 'package:oficihome/templates_commercant/accueilCommercant.dart';

class PageInscriCommercant extends StatefulWidget {
  PageInscriCommercant({Key key}) : super(key: key);

  @override
  _PageInscriCommercantState createState() => _PageInscriCommercantState();
}

class _PageInscriCommercantState extends State<PageInscriCommercant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = "",
      _password = "",
      // _confirmPassword = "",
      _nomSeller = "",
      _adresseSeller = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BackgroundInscription(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "INSCRIPTION COMMERÇANT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Image.asset(
              "assets/icons/seller.png",
              height: size.height * 0.30,
            ),
            TextFieldContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Rentrez une adresse mail valide';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Nom de votre enseigne',
                          icon: Icon(
                            Icons.person,
                            color: OficihomeAppTheme.kLightPrimaryColor,
                          )),
                      onSaved: (input) => _nomSeller = input,
                    ),
                    TextFormField(
                      validator: (input) {
                        if (input.isEmpty) {
                          return "Rentrez un nom d'enseigne valide";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Votre adresse',
                          icon: Icon(
                            Icons.person,
                            color: OficihomeAppTheme.kLightPrimaryColor,
                          )),
                      onSaved: (input) => _adresseSeller = input,
                    ),
                    TextFormField(
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Rentrez une adresse valide';
                        }
                        return null;
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
                      validator: (input) {
                        if (input.length < 6 && input.length > 20) {
                          return 'Rentrez un mot de passe \ncompris entre 6 et 20 carctères';
                        }
                        return null;
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
                      obscureText: false,
                      onSaved: (input) => _password = input,
                    ),
                    // TextFormField(
                    //   validator: (input) {
                    //     // if (input != _password) {
                    //     //   return 'Les mots de passe ne sont pas les mêmes';
                    //     // }
                    //     // //return null;
                    //   },
                    //   decoration: InputDecoration(
                    //     hintText: "Répéter le mot de passe",
                    //     icon: Icon(
                    //       Icons.lock,
                    //       color: OficihomeAppTheme.kLightPrimaryColor,
                    //     ),
                    //     suffixIcon: Icon(
                    //       Icons.visibility,
                    //       color: OficihomeAppTheme.kLightPrimaryColor,
                    //     ),
                    //     border: InputBorder.none,
                    //   ),
                    //   onSaved: (input) => _password = input,
                    //   obscureText: false,
                    // ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  try {
                    AuthMethods().signUpWithMailSeller(
                        _email, _password, _nomSeller, _adresseSeller);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccueilCommercant()));
                  } catch (e) {
                    print(e.message);
                  }
                }
              },
              child: Text('INSCRIPTION'),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Déjà un compte ?",
                  style: TextStyle(
                    color: OficihomeAppTheme.kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PageLogin();
                        },
                      ),
                    );
                  },
                  child: Text(
                    " Connectez-vous ! ",
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
          ],
        ),
      ),
    );
  }
}
