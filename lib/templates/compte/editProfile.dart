import 'dart:io';

import 'package:buyandbye/templates/Connexion/Tools/social_icon.dart';
import 'package:buyandbye/templates/Pages/pageAddressEdit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String myID,
      myFirstName,
      myLastName,
      myUserName,
      myEmail,
      myProfilePic,
      myPhone;

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
    myFirstName = "${querySnapshot.docs[0]["fname"]}";
    myLastName = "${querySnapshot.docs[0]["lname"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    myPhone = "${querySnapshot.docs[0]["phone"]}";

    if (user.providerData.length < 2) {
      print(user.providerData[0].providerId);
    }

    setState(() {});
  }

  // Première classe qui affiche les informations du commerçant
  bool isVisible = true;
  Widget build(BuildContext context) {
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
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                          myLastName == null
                              ? CircularProgressIndicator()
                              : Text(myLastName),
                          SizedBox(height: 20),
                          Text("Prénom :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 20),
                          myFirstName == null
                              ? CircularProgressIndicator()
                              : Text(myFirstName),
                          SizedBox(height: 20),
                          Text("E-mail :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 20),
                          myEmail == null
                              ? CircularProgressIndicator()
                              : Text(myEmail),
                          SizedBox(height: 20),
                          Text("Numéro de téléphone :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 20),
                          myPhone == null
                              ? CircularProgressIndicator()
                              : myPhone == ""
                                  ? Text("Pas de numéro enregistré",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))
                                  : Text(myPhone),
                          SizedBox(height: 20),
                          Divider(thickness: 0.5, color: Colors.black),
                          Text("Méthode de connexion"),
                          SocialIcon(
                            iconSrc: "assets/icons/facebook.svg",
                            press: () async {
                              try {
                                dynamic result = await AuthMethods.instanace
                                    .signInWithFacebook(context);
                              } catch (e) {
                                if (e is FirebaseAuthException) {}
                              }
                            },
                          ),
                          SocialIcon(
                            iconSrc: "assets/icons/google-plus.svg",
                            press: () async {
                              try {
                                await AuthMethods.instanace.linkFbToGoogle();
                              } catch (e) {
                                throw (e);
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          Divider(thickness: 0.5, color: Colors.black),
                          Text("Mes adresses"),
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(myID)
                                  .collection("Address")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.docs.length > 0) {
                                    return ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.docs.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    50,
                                                child: InkWell(
                                                  onTap: () async {},
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                                height: 30),
                                                            Container(
                                                              child: Text(
                                                                snapshot.data
                                                                            .docs[
                                                                        index][
                                                                    "addressName"],
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    100,
                                                                child: Text(snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "address"])),
                                                            SizedBox(
                                                                height: 30),
                                                          ]),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.edit),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          PageAddressEdit(
                                                                            adresse:
                                                                                snapshot.data.docs[index]["address"],
                                                                            adressTitle:
                                                                                snapshot.data.docs[index]["addressName"],
                                                                            buildingDetails:
                                                                                snapshot.data.docs[index]["buildingDetails"],
                                                                            buildingName:
                                                                                snapshot.data.docs[index]["buildingName"],
                                                                            familyName:
                                                                                snapshot.data.docs[index]["familyName"],
                                                                            lat:
                                                                                snapshot.data.docs[index]["latitude"],
                                                                            long:
                                                                                snapshot.data.docs[index]["longitude"],
                                                                            iD: snapshot.data.docs[index]["idDoc"],
                                                                          )));
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    return Column(
                                      children: [
                                        SizedBox(height: 20),
                                        Container(
                                            child: Text(
                                                "Aucune adresse enregistrée",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500))),
                                      ],
                                    );
                                  }
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                          Divider(thickness: 0.5, color: Colors.black),
                          Text("Mes moyens de paiement"),
                          SizedBox(height: 20),
                          Text("Pas de moyen de paiement enregistré",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Divider(thickness: 0.5, color: Colors.black),
                        ]),
                  )),
              // Affiche les champs de texte pour modifier les informations
              // lorsque le bouton est pressé
              Visibility(
                  visible: !isVisible,
                  child: ModifyProfile(
                      myFirstName, myLastName, myEmail, myPhone, myID))
            ],
          ),
          // ),
        ),
      ),
    );
  }
}

class ModifyProfile extends StatefulWidget {
  ModifyProfile(
      this.myFirstName, this.myLastName, this.myEmail, this.myPhone, this.myId);
  final String myFirstName, myLastName, myEmail, myPhone, myId;
  _ModifyProfileState createState() => _ModifyProfileState();
}

// Afiche les champ de modification des informations
class _ModifyProfileState extends State<ModifyProfile> {
  Widget build(BuildContext context) {
    // Déclaration des variables pour les champs de modification
    final lnameField = TextEditingController();
    final fnameField = TextEditingController();
    final emailField = TextEditingController();
    final phoneField = TextEditingController();
    final passwordField = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appelle les fonctions d'affichage des champs de texte
        buildTextField("Nom", widget.myLastName, lnameField, true),
        buildTextField("Prénom", widget.myFirstName, fnameField, true),
        buildTextField("E-mail", widget.myEmail, emailField, false),
        buildTextField("Téléphone", widget.myPhone, phoneField, false),
        buildTextField("Mot de Passe", "********", passwordField, false),
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
                      // Si un champ est vide, on envoi la valeur déjà présente
                      var lname = lnameField.text == ""
                          ? widget.myLastName
                          : lnameField.text;
                      var fname = fnameField.text == ""
                          ? widget.myFirstName
                          : fnameField.text;
                      var email = emailField.text == ""
                          ? widget.myEmail
                          : emailField.text;
                      var phone = phoneField.text == ""
                          ? widget.myPhone
                          : phoneField.text;
                      DatabaseMethods().updateUserInfo(
                          widget.myId, lname, fname, email, phone);
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
  Widget buildTextField(String labelText, String placeholder, fieldController,
      bool capitalization) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: fieldController,
        autocorrect: false,
        textCapitalization: capitalization
            ? TextCapitalization.sentences
            : TextCapitalization.none,
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
