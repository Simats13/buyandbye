import 'package:flutter/material.dart';
import 'package:oficihome/templates/widgets/onBoardingImageCliper.dart';
import 'loginPage2.dart';

class LoginPage1 extends StatefulWidget {
  @override
  _LoginPage1State createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ClipPath(
            clipper: OnBoardingImageCliper(),
            child: Container(
              height: 500,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Image.asset('assets/images/logo.jpg'),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.8),
                          Colors.black12.withOpacity(.05),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 32.0, left: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Ofici'home",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5.5),
                ),
                Text(
                  "Achetez local",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                ),
                Text(
                  "N'attendez plus tous vos commerces favoris vous attendent !",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage2()));
                  },
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  child: Text(
                    "J'achète !",
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
