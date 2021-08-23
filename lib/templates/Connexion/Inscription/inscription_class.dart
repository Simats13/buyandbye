import 'package:flutter/material.dart';

import 'package:oficihome/services/auth.dart';

import 'package:oficihome/templates/Connexion/Tools/text_field_container.dart';
import 'package:oficihome/templates/Pages/pageInscriptionCommercant.dart';
import 'package:oficihome/templates/Pages/pageLogin.dart';

import 'package:oficihome/templates/oficihome_app_theme.dart';

import 'package:oficihome/templates/Connexion/Tools/already_have_accountCheck.dart';
import 'package:oficihome/templates/Connexion/Inscription/background_inscription.dart';

import '../../accueil.dart';

class BodyInscription extends StatefulWidget {
  BodyInscription({Key key}) : super(key: key);

  @override
  _BodyInscriptionState createState() => _BodyInscriptionState();
}

class _BodyInscriptionState extends State<BodyInscription> {
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
                  TextFormField(
                    // ignore: missing_return
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Veuillez rentrer une adresse mail';
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
                        return 'Veuillez rentrer un mot de passe de plus de 6 caractères';
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
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                try {
                  AuthMethods().signUpWithMail(_email, _password);
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
                  color: OficihomeAppTheme.kPrimaryColor,
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
                    color: OficihomeAppTheme.kPrimaryColor,
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
