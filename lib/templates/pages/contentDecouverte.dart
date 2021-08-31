import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Connexion/Tools/bouton.dart';
import 'package:buyandbye/templates/Pages/pageBienvenue.dart';
import 'package:buyandbye/templates/Widgets/splash_decouverte.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates/Widgets/size_config.dart';

class ContentDecouverte extends StatefulWidget {
  @override
  _ContentDecouverteState createState() => _ContentDecouverteState();
}

class _ContentDecouverteState extends State<ContentDecouverte> {
  int currentPage = 0;

  List<Map<String, String>> splashData = [
    {
      "text": "Bienvenue sur Buy&Bye ! \nL'application proche de chez vous",
      "image": "assets/images/splash_1.png"
    },
    {
      "text": "Découvrez ou redecouvrez les commerces proches de chez vous",
      "image": "assets/images/splash_2.png"
    },
    {
      "text": "N'attendez plus et achetez local !",
      "image": "assets/images/splash_3.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) => SplashContent(
                  image: splashData[index]["image"],
                  text: splashData[index]["text"],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(20),
                ),
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                    RoundedButton(
                      text: "Continuer",
                      press: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return PageBienvenue();
                        }));
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: BuyandByeAppTheme.kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index
            ? BuyandByeAppTheme.orangeFonce
            : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
