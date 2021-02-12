import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oficihome/services/auth.dart';

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
  @override
  Widget build(BuildContext context) {
  bool enCoursChargement = false;
    Size size = MediaQuery.of(context).size;
    return enCoursChargement ? Chargement() : Background(
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
                  press: () {},
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
                    AuthMethods _auth = AuthMethods();
                    dynamic result = await _auth.signInWithGoogle(context);
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
                    return SignUpScreen();
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
