import 'package:flutter/material.dart';
import 'package:oficihome/templates/pages/pageCompte.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oficihome/templates/compte/constants.dart';

class SettingsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "informations",
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Mes informations",
                    style: TextStyle(color: Colors.black)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 1,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: OficihomeAppTheme.orange,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PageCompte()));
                  },
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: OficihomeAppTheme.orange,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => PageCompte()));
                    },
                  ),
                ],
              ),
              body: Container(
                padding: EdgeInsets.only(left: 16, top: 25, right: 16),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: kSpacingUnit.w * 15,
                        width: kSpacingUnit.w * 15,
                        margin: EdgeInsets.only(left: kSpacingUnit.w * 14),
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                snapshot.data.photoURL,
                                height: 97,
                                width: 97,
                              ),
                            ),
                            Positioned(
                                bottom: kSpacingUnit.w * 3,
                                right: kSpacingUnit.w * 13,
                                child: Container(
                                  height: kSpacingUnit.w * 5,
                                  width: kSpacingUnit.w * 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 3,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: OficihomeAppTheme.orange,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      buildTextField(
                          "Nom Complet", snapshot.data.displayName, false),
                      buildTextField("E-mail", snapshot.data.email, false),
                      buildTextField("Mot de Passe", "********", true),
                      buildTextField("Localisation", "Nimes", false),
                      SizedBox(
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlineButton(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ProfileScreen()),
                                  (Route<dynamic> route) => false);
                            },
                            child: Text("ANNULER",
                                style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2.2,
                                    color: Colors.black)),
                          ),
                          RaisedButton(
                            onPressed: () {},
                            color: OficihomeAppTheme.orange,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              "ENREGISTRER",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.2,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }
}
