import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:oficihome/templates/widgets/constants.dart';

import 'package:oficihome/templates/pages/pageInscription.dart';
import 'package:oficihome/templates/pages/pageLogin.dart';

import 'package:oficihome/templates/Connexion/Tools/bouton.dart';
import 'package:oficihome/templates/Connexion/Tools/background.dart';  





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
              "BIENVENUE SUR OFICI'HOME",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            SvgPicture.asset(
              "assets/icons/chat.svg",
              height: size.height * 0.45,
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            RoundedButton(
              text: "CONNEXION",
              press: () {
                Navigator.push(
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
                Navigator.push(
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
