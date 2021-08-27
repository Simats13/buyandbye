import 'package:flutter/material.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';
import 'package:buyandbye/templates/Pages/pageLogin.dart';
import 'package:buyandbye/templates/Pages/pageSuiteInscription.dart';

import '../../buyandbye_app_theme.dart';
import 'background_inscription.dart';

class SuiteInscriptionCommercant extends StatefulWidget {
  @override
  _SuiteInscriptionCommercantState createState() =>
      _SuiteInscriptionCommercantState();
}

class _SuiteInscriptionCommercantState
    extends State<SuiteInscriptionCommercant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BackgroundInscription(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "INFORMATIONS MAGASINS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
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
                      },
                      decoration: InputDecoration(
                          labelText: 'Votre adresse email',
                          icon: Icon(
                            Icons.person,
                            color: BuyandByeAppTheme.kLightPrimaryColor,
                          )),
                      onSaved: (input) => _email = input,
                    ),
                    TextFormField(
                      validator: (input) {
                        if (input.length < 6 && input.length > 20) {
                          return 'Rentrez un mot de passe \ncompris entre 6 et 20 carctères';
                        }
                      },
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
                      obscureText: true,
                    ),
                    TextFormField(
                      validator: (input) {
                        if (input != _password) {
                          return 'Les mots de passe ne sont pas les mêmes';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Répéter le mot de passe",
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
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  try {
                    AuthMethods().signUpWithMail(_email, _password);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PageSuiteIncriptionCommercant()));
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
                  "Déjà un compte COMMERÇANT ?",
                  style: TextStyle(
                    color: BuyandByeAppTheme.kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    " Connectez-vous ! ",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Êtes-vous un UTILISATEUR ?",
                  style: TextStyle(
                    color: BuyandByeAppTheme.kPrimaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PageLogin();
                        },
                      ),
                    );
                  },
                  child: Text(
                    " Connectez-vous ici ! ",
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
      ),
    );
  }
}
