import 'package:flutter/material.dart';

import 'package:buyandbye/services/auth.dart';

import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';
import 'package:buyandbye/templates/Pages/pageInscriptionCommercant.dart';
import 'package:buyandbye/templates/Pages/pageLogin.dart';

import 'package:buyandbye/templates/buyandbye_app_theme.dart';

import 'package:buyandbye/templates/Connexion/Tools/already_have_accountCheck.dart';
import 'package:buyandbye/templates/Connexion/Inscription/background_inscription.dart';

import '../../accueil.dart';

class BodyInscription extends StatefulWidget {
  BodyInscription({Key key}) : super(key: key);

  @override
  _BodyInscriptionState createState() => _BodyInscriptionState();
}

class _BodyInscriptionState extends State<BodyInscription> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password, _fname, _lname;
  bool obscureText = true;
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
          SizedBox(
            height: size.height * 0.03,
          ),
          Image.asset(
            "assets/icons/signup.png",
            height: size.height * 0.30,
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
                      if (input.isEmpty) {
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
                      if (input.isEmpty) {
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
                      if (input.isEmpty) {
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
                      if (input.length < 6) {
                        return 'Veuillez rentrer un mot de passe de plus de 6 caractères';
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
                        icon: Icon(Icons.visibility),
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
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                try {
                  AuthMethods()
                      .signUpWithMail(_email, _password, _fname, _lname);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Accueil()));
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
