// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:shimmer/shimmer.dart';

class EditProfileComPage extends StatefulWidget {
  @override
  const EditProfileComPage({Key? key}) : super(key: key);
  @override
  _EditProfileComPageState createState() => _EditProfileComPageState();
}

class _EditProfileComPageState extends State<EditProfileComPage> {
  String? myID,
      myFirstName,
      myLastName,
      myUserName,
      myEmail,
      myProfilePic,
      myPhone,
      myAdresse,
      premium,
      colorStore;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myFirstName = "${querySnapshot.docs[0]["fname"]}";
    myLastName = "${querySnapshot.docs[0]["lname"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    myPhone = "${querySnapshot.docs[0]["phone"]}";
    myAdresse = "${querySnapshot.docs[0]["adresse"]}";
    premium = "${querySnapshot.docs[0]["premium"]}";
    colorStore = "${querySnapshot.docs[0]["colorStore"]}";
    setState(() {});
  }

  // Première classe qui affiche les informations du commerçant
  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    String? dropdownValue = colorStore;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BuyandByeAppTheme.black_electrik,
        title: const Text("Mes informations"),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
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
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                child: const Icon(Icons.edit_rounded,
                    color: BuyandByeAppTheme.orange),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
          // Affiche les informations
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: 200,
                child: Stack(
                  children: <Widget>[
                    // Affiche l'image de profil
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: myProfilePic == null
                            ? Shimmer.fromColors(
                                child: Container(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                              )
                            : Image.network(myProfilePic as String),
                      ),
                    ),
                    // Boutons de changement d'image quand on est en mode modification
                    isVisible
                        ? const SizedBox.shrink()
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
                                icon: const Icon(Icons.edit,
                                    color: Colors.white, size: 14),
                                onPressed: () {},
                              ),
                            )),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Divider(thickness: 0.5, color: Colors.black),
              const SizedBox(height: 20),
              // De base, affiche les informations du commerçant
              Visibility(
                  visible: isVisible,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Nom :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),
                          myFirstName == null
                              ? const CircularProgressIndicator()
                              : Text(myFirstName! + " " + myLastName!),
                          const SizedBox(height: 20),
                          const Text("E-mail :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),
                          myEmail == null
                              ? const CircularProgressIndicator()
                              : Text(myEmail!),
                          const SizedBox(height: 20),
                          const Text("Numéro de téléphone :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),
                          myPhone == null
                              ? const CircularProgressIndicator()
                              : Text(myPhone!),
                          const SizedBox(height: 20),
                          const Text("Adresse :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),
                          myAdresse == null
                              ? const CircularProgressIndicator()
                              : Text(myAdresse!),
                          const SizedBox(height: 20),
                          premium == "true"
                              ? const Text("Couleur de mon magasin :",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700))
                              : Container(),
                          premium == "true"
                              ? Row(children: [
                                  DropdownButton<String>(
                                    value: dropdownValue,
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded),
                                    iconSize: 24,
                                    elevation: 16,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownValue = newValue;
                                        getMyInfo();
                                      });
                                    },
                                    items: colorName
                                        .map((value, value1) {
                                          return MapEntry(
                                              value,
                                              DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                                onTap: () {
                                                  DatabaseMethods()
                                                      .colorMyStore(
                                                          value1, value);
                                                },
                                              ));
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ])
                              : Container(),
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
  const ModifyProfile(
      this.myFirstName, this.myLastName, this.myEmail, this.myPhone, this.myID,
      {Key? key})
      : super(key: key);
  final String? myFirstName, myLastName, myEmail, myPhone, myID;
  @override
  _ModifyProfileState createState() => _ModifyProfileState();
}

// Déclaration des variables pour les champs de modification
final fNameField = TextEditingController();
final lNameField = TextEditingController();
final emailField = TextEditingController();
final phoneField = TextEditingController();
final passwordField = TextEditingController();

// Afiche les champ de modification des informations
class _ModifyProfileState extends State<ModifyProfile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appelle la fonction d'affiche des champs de texte
        buildTextField("Votre prénom", widget.myFirstName, fNameField, true),
        buildTextField("Votre nom", widget.myLastName, lNameField, true),
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
                  padding: const EdgeInsets.symmetric(
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
                    child: const Text("Annuler"),
                  )),
              Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: BuyandByeAppTheme.orangeFonce,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      var fName = fNameField.text == ""
                          ? widget.myFirstName
                          : fNameField.text;
                      var lName = lNameField.text == ""
                          ? widget.myLastName
                          : lNameField.text;
                      var email = emailField.text == ""
                          ? widget.myEmail
                          : emailField.text;
                      var phone = phoneField.text == ""
                          ? widget.myPhone
                          : phoneField.text;
                      DatabaseMethods().updateSellerInfo(
                          widget.myID, fName, lName, email, phone);
                      Navigator.pop(context);
                    },
                    child: const Text("Confirmer"),
                  ))
            ],
          ),
        ),
        const SizedBox(height: 20)
      ],
    );
  }

  // Fonction d'affichage des champs de texte
  Widget buildTextField(String labelText, String? placeholder, fieldController,
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
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
