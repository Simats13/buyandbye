import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String myID;
  String myName, myUserName, myEmail;
  String myProfilePic;
  String myPhone;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myName = "${querySnapshot.docs[0]["name"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    myPhone = "${querySnapshot.docs[0]["phone"]}";
    setState(() {});
  }

  // Première classe qui affiche les informations du commerçant
  bool isVisible = true;
  Widget build(BuildContext context) {
    // Affiche un chargement tant que les informations de l'utilisateur ne son pas charhées
    if (myID == null) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: BuyandByeAppTheme.black_electrik,
          title: Text("Mes informations"),
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: BuyandByeAppTheme.orange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            // Boutons pour modifier les informations du commerçant
            Padding(
                padding: EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  child:
                      Icon(Icons.edit_rounded, color: BuyandByeAppTheme.orange),
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 16, top: 40, right: 16),
            // Affiche les informations
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 200,
                  child: Stack(
                    children: <Widget>[
                      // Affiche l'image de profil
                      Center(
                        child: ClipRRect(
                            child: Image.network(
                          // S'il n'y a pas d'image on affiche celle par défaut
                          myProfilePic ??
                              "https://cdn.iconscout.com/icon/free/png-256/account-avatar-profile-human-man-user-30448.png",
                          height: MediaQuery.of(context).size.height,
                        )),
                      ),
                      // Boutons de changement d'image quand on est en mode modification
                      isVisible
                          ? SizedBox.shrink()
                          : Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  color: BuyandByeAppTheme.orange,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.edit,
                                      color: Colors.white, size: 14),
                                  onPressed: () {},
                                ),
                              )),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Divider(thickness: 0.5, color: Colors.black),
                SizedBox(height: 20),
                // De base, affiche les informations du commerçant
                Visibility(
                    visible: isVisible,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nom :",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 20),
                            Text(myName),
                            SizedBox(height: 20),
                            Text("Prénom :",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 20),
                            Text(myName),
                            SizedBox(height: 20),
                            Text("E-mail :",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 20),
                            Text(myEmail),
                            SizedBox(height: 20),
                            Text("Numéro de téléphone :",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 20),
                            Text(myPhone),
                            SizedBox(height: 20),
                            Divider(thickness: 0.5, color: Colors.black),
                            Text("Mes adresses"),
                            Divider(thickness: 0.5, color: Colors.black),
                            Text("Mes moyens de paiement"),
                            Divider(thickness: 0.5, color: Colors.black),
                          ]),
                    )),
                // Affiche les champs de texte pour modifier les informations
                // lorsque le bouton est pressé
                Visibility(
                    visible: !isVisible,
                    child: ModifyProfile(myName, myEmail, myPhone))
              ],
            ),
            // ),
          ),
        ),
      );
    }
  }
}

class ModifyProfile extends StatefulWidget {
  ModifyProfile(this.myName, this.myEmail, this.myPhone);
  final String myName, myEmail, myPhone;
  _ModifyProfileState createState() => _ModifyProfileState();
}

// Afiche les champ de modification des informations
class _ModifyProfileState extends State<ModifyProfile> {
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appelle la fonction d'affiche des champs de texte
        buildTextField("Nom", widget.myName),
        buildTextField("Prénom", widget.myName),
        buildTextField("E-mail", widget.myEmail),
        buildTextField("Téléphone", widget.myPhone),
        buildTextField("Mot de Passe", "********"),
        // Affichage des boutons d'annulation et de confirmation
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  height: 35,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: BuyandByeAppTheme.orange,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Annuler"),
                  )),
              Container(
                  height: 35,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: BuyandByeAppTheme.orangeFonce,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Confirmer"),
                  ))
            ],
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }

  // Fonction d'affichage des champs de texte
  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

// decoration: BoxDecoration(border:Border.all(color:Colors.black)),