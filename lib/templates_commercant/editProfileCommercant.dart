import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/auth.dart';

class EditProfileComPage extends StatefulWidget {
  @override
  _EditProfileComPageState createState() => _EditProfileComPageState();
}

class _EditProfileComPageState extends State<EditProfileComPage> {
  String myID,
      myName,
      myUserName,
      myEmail,
      myProfilePic,
      myPhone,
      colorStoreName;

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
    myName = "${querySnapshot.docs[0]["name"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    myPhone = "${querySnapshot.docs[0]["phone"]}";
    colorStoreName = "${querySnapshot.docs[0]["colorStoreName"]}";
    setState(() {});
  }

  // Première classe qui affiche les informations du commerçant
  bool isVisible = true;
  Widget build(BuildContext context) {
    String dropdownValue = colorStoreName;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
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
                          myName == null
                              ? CircularProgressIndicator()
                              : Text(myName),
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
                              : Text(myPhone),
                          SizedBox(height: 20),
                          Text("Couleur de mon magasin :",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          Row(children: [
                            DropdownButton<String>(
                              value: dropdownValue,
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                              iconSize: 24,
                              elevation: 16,
                              onChanged: (String newValue) {
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
                                                .colorMyStore(value1, value);
                                          },
                                        ));
                                  })
                                  .values
                                  .toList(),
                            ),
                          ]),
                          SizedBox(height: 10),
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
                  child: ModifyProfile(myName, myEmail, myPhone, myID))
            ],
          ),
          // ),
        ),
      ),
    );
  }
}

class ModifyProfile extends StatefulWidget {
  ModifyProfile(this.myName, this.myEmail, this.myPhone, this.myID);
  final String myName, myEmail, myPhone, myID;
  _ModifyProfileState createState() => _ModifyProfileState();
}

// Déclaration des variables pour les champs de modification
final nameField = TextEditingController();
final emailField = TextEditingController();
final phoneField = TextEditingController();
final passwordField = TextEditingController();

// Afiche les champ de modification des informations
class _ModifyProfileState extends State<ModifyProfile> {
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appelle la fonction d'affiche des champs de texte
        buildTextField("Nom du magasin", widget.myName, nameField, true),
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
                      var name =
                          nameField.text == "" ? widget.myName : nameField.text;
                      var email = emailField.text == ""
                          ? widget.myEmail
                          : emailField.text;
                      var phone = phoneField.text == ""
                          ? widget.myPhone
                          : phoneField.text;
                      DatabaseMethods()
                          .updateSellerInfo(widget.myID, name, email, phone);
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
