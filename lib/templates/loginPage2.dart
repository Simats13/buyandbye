import 'package:flutter/material.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/widgets/chargement.dart';
import 'package:oficihome/templates/widgets/onBoardingImageCliper2.dart';

class LoginPage2 extends StatefulWidget {
  @override
  _LoginPage2State createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  bool enCoursChargement = false;
  @override
  Widget build(BuildContext context) {
    return enCoursChargement
        ? Chargement()
        : Scaffold(
            body: Column(
              children: [
                ClipPath(
                  clipper: OnBoardingImageCliper2(),
                  child: Container(
                    height: 500,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/logo2.jpg',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(.8),
                                Colors.black12.withOpacity(.05)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 32.0, top: 32.0, left: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Ofici'Home",
                          style: Theme.of(context).textTheme.headline4.copyWith(
                              color: Colors.black, fontWeight: FontWeight.w900),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "En vous connectant avec votre compte Google, vous pourrez accéder à un large panel de magasins",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black38, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      MaterialButton(
                        onPressed: () async {
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
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.redAccent,
                        child: Text(
                          'CONNEXION AVEC GOOGLE',
                          style: Theme.of(context).textTheme.button.copyWith(
                                color: Colors.white,
                              ),
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
