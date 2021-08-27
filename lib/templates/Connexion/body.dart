import 'package:flutter/material.dart';

import 'package:buyandbye/templates/widgets/constants.dart';

import 'package:buyandbye/templates/pages/pageInscription.dart';
import 'package:buyandbye/templates/pages/pageLogin.dart';

import 'package:buyandbye/templates/Connexion/Tools/bouton.dart';
import 'package:buyandbye/templates/Connexion/Tools/background.dart';

class Body extends StatelessWidget {
  const Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "BIENVENUE SUR BUY & BYE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Image.asset(
              "assets/icons/chat.png",
              height: size.height * 0.45,
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            RoundedButton(
              text: "CONNEXION",
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
            RoundedButton(
              text: "INSCRIPTION",
              color: kPrimaryLightColor,
              textColor: Colors.black,
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
