import 'dart:convert';
import 'dart:io';
import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/Compte/page_cb_edit.dart';
import 'package:buyandbye/templates/Connexion/Tools/bouton.dart';
import 'package:buyandbye/templates/Pages/address_search.dart';
import 'package:buyandbye/templates/Pages/page_address_edit.dart';
import 'package:buyandbye/templates/Pages/page_address_next.dart';
import 'package:buyandbye/templates/Pages/place_service.dart';
import 'package:buyandbye/templates/pages/page_bienvenue.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:sign_button/sign_button.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:http/http.dart' as http;
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

class Customer {
  String name;
  int age;

  Customer(this.name, this.age);

  @override
  String toString() {
    return '{ $name, $age }';
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? myID = "",
      myFirstName = "",
      myLastName = "",
      myUserName = "",
      myEmail = "",
      myProfilePic = "",
      customerID = "",
      myPhone = "",
      nameCard = "",
      streetCard = "",
      streetCard2 = "",
      cityCard = "",
      postalCodeCard = "",
      stateCard = "",
      countryCard = "";
  bool? apple, facebook, mail, google;
  DateTime? dateTime;

  Map<String, dynamic>? paymentIntentData;
  final controller = TextEditingController();
  String streetNumber = '';
  String street = '';
  String city = '';
  String currentAddressLocation = "";
  String zipCode = '';
  double longitude = 0;
  double latitude = 0;
  List cards = [];
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getPaymentInfo(customerID) async {
    final url = "https://us-central1-oficium-11bf9.cloudfunctions.net/app/list_cards?customers=$customerID";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'a': 'a',
      }),
    );

    paymentIntentData = jsonDecode(response.body);

    setState(() {});
  }

  showMessage(String titre, e) {
    if (!Platform.isIOS) {
      showDialog(
          context: context,
          builder: (BuildContext builderContext) {
            return AlertDialog(
              title: Text(titre),
              content: Text(e),
              actions: [
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () async {
                    Navigator.of(builderContext).pop();
                  },
                )
              ],
            );
          });
    } else {
      return showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text(titre),
                content: Text(e),
                actions: [
                  // Close the dialog
                  CupertinoButton(
                      child: const Text('OK'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      }),
                ],
              ));
    }
  }

  // Première classe qui affiche les informations du commerçant
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: ProviderUserInfo().returnData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            myID = snapshot.data['id'];
            myFirstName = snapshot.data['fname'];
            myLastName = snapshot.data['lname'];
            myProfilePic = snapshot.data['imgUrl'];
            myEmail = snapshot.data['email'];
            myPhone = snapshot.data['phone'];
            customerID = snapshot.data['customerId'];
            apple = snapshot.data['providers']['Apple'];
            facebook = snapshot.data['providers']['Facebook'];
            mail = snapshot.data['providers']['Mail'];
            google = snapshot.data['providers']['Google'];
            getPaymentInfo(customerID);
          }
          return Scaffold(
            backgroundColor: BuyandByeAppTheme.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                title: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Mes Informations',
                          style: TextStyle(
                            fontSize: 20,
                            color: BuyandByeAppTheme.orangeMiFonce,
                            fontWeight: FontWeight.bold,
                          )),
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Icon(
                            Icons.settings,
                            color: BuyandByeAppTheme.orangeMiFonce,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: BuyandByeAppTheme.white,
                automaticallyImplyLeading: false,
                elevation: 0.0,
                bottomOpacity: 0.0,
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
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: const Icon(Icons.edit_rounded, color: BuyandByeAppTheme.orange),
                      ))
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
                // Affiche les informations
                child: Column(
                  children: [
                    SizedBox(
                      height: 95,
                      width: 95,
                      child: Stack(
                        children: <Widget>[
                          // Affiche l'image de profil
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: myProfilePic != ""
                                  ? Image.network(myProfilePic!)
                                  : Shimmer.fromColors(
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                    ),
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
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                      ),
                                      color: BuyandByeAppTheme.orange,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 14),
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
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text("Nom :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 20),
                            myLastName == ''
                                ? Shimmer.fromColors(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  )
                                : Text(myLastName!),
                            const SizedBox(height: 20),
                            const Text("Prénom :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 20),
                            myFirstName == ''
                                ? Shimmer.fromColors(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  )
                                : Text(myFirstName!),
                            const SizedBox(height: 20),
                            const Text("E-mail :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 20),
                            myEmail == ''
                                ? Shimmer.fromColors(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  )
                                : Text(myEmail!),
                            const SizedBox(height: 20),
                            const Text("Numéro de téléphone :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 20),
                            myPhone == ''
                                ? Shimmer.fromColors(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  )
                                : myPhone == ""
                                    ? RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.bodyText2,
                                          children: const [
                                            TextSpan(text: 'Aucun numéro enregistré.\n\nEnregistrez en un éditant votre profil en appuyant sur le  '),
                                            WidgetSpan(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 2.0),
                                                child: Icon(Icons.edit_rounded),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(myPhone!),
                            const SizedBox(height: 20),
                            const Divider(thickness: 0.5, color: Colors.black),
                            const Text("Méthode de connexion"),
                            facebook == true
                                ? Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Dissocier Facebook",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.facebook,
                                          onPressed: () async {
                                            await AuthMethods.instance.unlinkFacebook();
                                            showMessage("Lien Facebook", "Votre compte Facebook a bien été dissocié !");
                                            setState(() {
                                              facebook = false;
                                            });
                                          })
                                    ],
                                  )
                                : Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Associer Facebook",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.facebook,
                                          onPressed: () async {
                                            try {
                                              await AuthMethods.instance.linkExistingToFacebook();
                                              showMessage("Lien Facebook", "Votre compte Facebook a bien été lié !");
                                              setState(() {
                                                facebook = true;
                                              });
                                            } catch (e) {
                                              if (e is FirebaseAuthException) {
                                                print(e);
                                                if (e.code == 'credential-already-in-use') {
                                                  String erreur =
                                                      "Un compte existe déjà avec cette adresse mail, veuillez le Dissocier ou bien contactez le support.";
                                                  showMessage("Adresse mail déjà utilisée", erreur);
                                                }
                                              }
                                            }
                                          })
                                    ],
                                  ),
                            google == true
                                ? Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Dissocier Google",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.google,
                                          onPressed: () async {
                                            await AuthMethods.instance.unlinkGoogle();
                                            showMessage("Lien Google", "Votre compte Google a bien été dissocié !");
                                            setState(() {
                                              google = false;
                                            });
                                          })
                                    ],
                                  )
                                : Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Associer Google",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.google,
                                          onPressed: () async {
                                            try {
                                              await AuthMethods.instance.linkExistingToGoogle();
                                              showMessage("Lien Google", "Votre compte Google a bien été lié !");
                                              setState(() {
                                                google = true;
                                              });
                                            } catch (e) {
                                              if (e is FirebaseAuthException) {
                                                print(e);
                                                if (e.code == 'credential-already-in-use') {
                                                  String erreur =
                                                      "Un compte existe déjà avec cette adresse mail, veuillez le Dissocier ou bien contactez le support.";
                                                  showMessage("Adresse mail déjà utilisée", erreur);
                                                }
                                              }
                                            }
                                          })
                                    ],
                                  ),
                            mail == true
                                ? Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Dissocier Mail",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.mail,
                                          onPressed: () async {
                                            try {
                                              print('click');
                                            } catch (e) {
                                              if (e is FirebaseAuthException) {
                                                print(e);
                                                if (e.code == 'credential-already-in-use') {
                                                  String erreur =
                                                      "Un compte existe déjà avec cette adresse mail, veuillez le Dissocier ou bien contactez le support.";
                                                  showMessage("Adresse mail déjà utilisée", erreur);
                                                }
                                              }
                                            }
                                          })
                                    ],
                                  )
                                : Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Associer Mail",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.mail,
                                          onPressed: () async {
                                            try {
                                              print('click');
                                            } catch (e) {
                                              if (e is FirebaseAuthException) {
                                                print(e);
                                                if (e.code == 'credential-already-in-use') {
                                                  String erreur =
                                                      "Un compte existe déjà avec cette adresse mail, veuillez le Dissocier ou bien contactez le support.";
                                                  showMessage("Adresse mail déjà utilisée", erreur);
                                                }
                                              }
                                            }
                                          })
                                    ],
                                  ),
                            apple == true
                                ? Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Dissocier Apple",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.apple,
                                          onPressed: () async {
                                            try {
                                              await AuthMethods.instance.unlinkApple();
                                              showMessage("Lien Apple", "Votre compte Apple a bien été dissocié !");
                                              setState(() {
                                                apple = false;
                                              });
                                            } catch (e) {
                                              if (e is FirebaseAuthException) {
                                                print(e);
                                              }
                                            }
                                          })
                                    ],
                                  )
                                : Row(
                                    children: [
                                      SignInButton(
                                          btnText: "Associer Apple",
                                          imagePosition: ImagePosition.left, // left or right
                                          buttonType: ButtonType.apple,
                                          onPressed: () async {
                                            try {
                                              await AuthMethods.instance.linkExistingToApple();
                                              showMessage("Lien Apple", "Votre compte Apple a bien été lié !");
                                              setState(() {
                                                apple = true;
                                              });
                                            } catch (e) {
                                              if (e is FirebaseAuthException) {
                                                print(e);
                                                if (e.code == 'credential-already-in-use') {
                                                  String erreur =
                                                      "Un compte existe déjà avec cette adresse mail, veuillez le Dissocier ou bien contactez le support.";
                                                  showMessage("Adresse mail déjà utilisée", erreur);
                                                } else if (e.code == 'provider-already-linked') {
                                                  String erreur = "Ce mode d'authentification ne peut être lié au compte.";
                                                  showMessage("Impossible de lier ce mode d'authentification", erreur);
                                                }
                                              }
                                            }
                                          })
                                    ],
                                  ),
                            const SizedBox(height: 20),
                            const Divider(thickness: 0.5, color: Colors.black),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  const TextSpan(text: "Mes adresses "),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () async {
                                        // generate a new token here
                                        final sessionToken = const Uuid().v4();
                                        final Suggestion result = await showSearch(
                                          context: context,
                                          delegate: AddressSearch(sessionToken),
                                        ) as Suggestion;
                                        // This will change the text displayed in the TextField
                                        final placeDetails = await PlaceApiProvider(sessionToken).getPlaceDetailFromId(result.placeId!);

                                        setState(() {
                                          controller.text = result.description!;
                                          streetNumber = placeDetails.streetNumber!;
                                          street = placeDetails.street!;
                                          city = placeDetails.city!;
                                          zipCode = placeDetails.zipCode!;
                                          currentAddressLocation = "$streetNumber $street, $city ";
                                        });

                                        final query = "$streetNumber $street , $city";

                                        List<geocoder.Location> locations = await geocoder.locationFromAddress(query);
                                        var first = locations.first;

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PageAddressNext(
                                                      lat: first.latitude,
                                                      long: first.longitude,
                                                      adresse: query,
                                                    )));
                                      },
                                      child: const Icon(Icons.add),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            myID != ""
                                ? StreamBuilder<dynamic>(
                                    stream: ProviderGetAddresses().returnData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data.docs.length > 0) {
                                          return ListView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: snapshot.data.docs.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width - 50,
                                                      child: InkWell(
                                                        onTap: () async {},
                                                        child: Row(
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const SizedBox(height: 30),
                                                                Text(
                                                                  snapshot.data.docs[index]["addressName"],
                                                                ),
                                                                const SizedBox(height: 5),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width - 100,
                                                                  child: Text(
                                                                    snapshot.data.docs[index]["address"],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                IconButton(
                                                                  icon: const Icon(Icons.more_vert),
                                                                  onPressed: () {
                                                                    final action = CupertinoActionSheet(
                                                                      actions: <Widget>[
                                                                        CupertinoActionSheetAction(
                                                                          child: const Text("Modifier l'adresse"),
                                                                          isDefaultAction: true,
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop(false);
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => PageAddressEdit(
                                                                                  adresse: snapshot.data.docs[index]["address"],
                                                                                  adressTitle: snapshot.data.docs[index]["addressName"],
                                                                                  buildingDetails: snapshot.data.docs[index]["buildingDetails"],
                                                                                  buildingName: snapshot.data.docs[index]["buildingName"],
                                                                                  familyName: snapshot.data.docs[index]["familyName"],
                                                                                  lat: snapshot.data.docs[index]["latitude"],
                                                                                  long: snapshot.data.docs[index]["longitude"],
                                                                                  iD: snapshot.data.docs[index]["idDoc"],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                        CupertinoActionSheetAction(
                                                                            child: const Text("Supprimer mon adresse"),
                                                                            isDestructiveAction: true,
                                                                            onPressed: () async {
                                                                              final bool delete = await DatabaseMethods().deleteAddress(
                                                                                snapshot.data.docs[index]["idDoc"],
                                                                              );
                                                                              setState(() {
                                                                                if (delete == false) {
                                                                                  Navigator.of(context).pop(false);
                                                                                  showMessage("Suppression impossible",
                                                                                      "Vous ne pouvez pas supprimer votre adresse, vous devez impérativement en avoir une ! Ajoutez-en une autre puis réessayez de la supprimer.");
                                                                                } else {
                                                                                  Navigator.of(context).pop(false);
                                                                                  showMessage("Suppression adresse", "Votre adresse a bien été supprimé !");
                                                                                }
                                                                              });
                                                                            }),
                                                                      ],
                                                                      cancelButton: CupertinoActionSheetAction(
                                                                        child: const Text("Annuler"),
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                      ),
                                                                    );
                                                                    showCupertinoModalPopup(context: context, builder: (context) => action);
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
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width - 50,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: Theme.of(context).textTheme.bodyText2,
                                                        children: const [
                                                          TextSpan(
                                                              text:
                                                                  "Aucune adresse n'est enregistrée.\n\nEnregistrez en une depuis la page d'Accueil ou bien en cliquant sur la "),
                                                          WidgetSpan(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                                                              child: Icon(Icons.add),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                      } else {
                                        return Shimmer.fromColors(
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 30,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                        );
                                      }
                                    },
                                  )
                                : Shimmer.fromColors(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  ),
                            const Divider(thickness: 0.5, color: Colors.black),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: const [
                                  TextSpan(text: "Mes moyens de paiement "),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            paymentIntentData != null
                                ? (paymentIntentData != null && paymentIntentData!['paymentMethods']['data'].length != 0)
                                    ? ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: paymentIntentData!['paymentMethods']['data'].length,
                                        itemBuilder: (context, index) {
                                          nameCard = paymentIntentData!['paymentMethods']['data'][index]['billing_details']['name'];
                                          return paymentIntentData != null
                                              ? Column(
                                                  children: [
                                                    ListTile(
                                                      leading: paymentIntentData!['paymentMethods']['data'][index]['card']['brand'] == "mastercard"
                                                          ? Image.network("https://logos-marques.com/wp-content/uploads/2021/07/Mastercard-logo.png",
                                                              width: 50, height: 50)
                                                          : Image.network(
                                                              "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/1200px-Visa_Inc._logo.svg.png",
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                      title: const Text(
                                                        "Card Name",
                                                        // Erreur : type 'Null' is not a subtype of 'String'
                                                        // nameCard == ''
                                                        //     ? "Aucun nom"
                                                        //     : nameCard as String,
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                                                      ),
                                                      subtitle: Text(
                                                        "****" +
                                                            paymentIntentData!['paymentMethods']['data'][index]['card']['last4'] +
                                                            ' ' +
                                                            '\nExp: ' +
                                                            paymentIntentData!['paymentMethods']['data'][index]['card']['exp_month'].toString() +
                                                            '/' +
                                                            paymentIntentData!['paymentMethods']['data'][index]['card']['exp_year'].toString(),
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                                                      ),
                                                      trailing: IconButton(
                                                        icon: const Icon(Icons.more_vert),
                                                        onPressed: () async {
                                                          // Navigator.of(context)
                                                          //               .pop();

                                                          showAdaptiveActionSheet(
                                                            context: context,
                                                            title: const Text('Modification informations bancaires'),

                                                            actions: <BottomSheetAction>[
                                                              BottomSheetAction(
                                                                title: const Text(
                                                                  'Modifier les informations de ma carte',
                                                                  style: TextStyle(
                                                                    color: Colors.blue,
                                                                  ),
                                                                ),
                                                                onPressed: (context) async {
                                                                  Navigator.of(context).pop(false);
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => PageCBEdit(
                                                                        customerID: customerID,
                                                                        idCard: paymentIntentData!['paymentMethods']['data'][index]['id'],
                                                                        expYear: paymentIntentData!['paymentMethods']['data'][index]['card']['exp_year'],
                                                                        expMonth: paymentIntentData!['paymentMethods']['data'][index]['card']['exp_month'],
                                                                        nameCard: paymentIntentData!['paymentMethods']['data'][index]['billing_details']
                                                                            ['name'],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              BottomSheetAction(
                                                                  title: const Text(
                                                                    'Supprimer ma carte',
                                                                    style: TextStyle(
                                                                      color: Colors.red,
                                                                    ),
                                                                  ),
                                                                  onPressed: (context) async {
                                                                    String id = paymentIntentData!['paymentMethods']['data'][index]['id'];
                                                                    final url =
                                                                        "https://us-central1-oficium-11bf9.cloudfunctions.net/app/delete_cards?idCard=${paymentIntentData!['paymentMethods']['data'][index]['id']}";

                                                                    await http.post(
                                                                      Uri.parse(url),
                                                                      headers: {
                                                                        'Content-Type': 'application/json',
                                                                      },
                                                                      body: json.encode({
                                                                        'a': 'a',
                                                                      }),
                                                                    );
                                                                    Navigator.of(context).pop();
                                                                    showMessage("Suppression carte", "Votre carte a bien été supprimé !");

                                                                    for (var i = 0; i < paymentIntentData!['paymentMethods']['data'].length; i++) {
                                                                      if (paymentIntentData!['paymentMethods']['data'][i] == id) {}
                                                                    }
                                                                    List data = paymentIntentData!['paymentMethods']['data'];
                                                                    data.removeAt(index);

                                                                    setState(() {});
                                                                  }),
                                                            ],
                                                            cancelAction: CancelAction(
                                                                title: const Text(
                                                                    'Annuler')), // onPressed parameter is optional by default will dismiss the ActionSheet
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Shimmer.fromColors(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Center(
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            height: 30,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Center(
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            height: 30,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Center(
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            height: 30,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor: Colors.grey[100]!,
                                                );
                                        },
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.bodyText2,
                                          children: const [
                                            TextSpan(text: "Aucun moyens de paiement enregistrés.\n\nEnregistrez en un lors d'un achat ! "),
                                          ],
                                        ),
                                      )
                                : Shimmer.fromColors(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  ),
                            const Divider(thickness: 0.5, color: Colors.black),
                            const SizedBox(height: 20),
                            const Text("Suppression du compte"),
                            const SizedBox(height: 20),
                            Platform.isIOS
                                ? Center(
                                    child: CupertinoButton(
                                      color: Colors.red,
                                      onPressed: () {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) => CupertinoAlertDialog(
                                            title: const Text("Suppression du compte"),
                                            content: const Text("Souhaitez-vous réellement supprimer votre compte ?"),
                                            actions: [
                                              // Close the dialog
                                              CupertinoButton(
                                                  child: const Text('Annuler'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  }),
                                              CupertinoButton(
                                                child: const Text(
                                                  'Suppression',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                                onPressed: () async {
                                                  final url = "https://us-central1-oficium-11bf9.cloudfunctions.net/app/delete_customer?customers=$customerID";

                                                  final response = await http.post(
                                                    Uri.parse(url),
                                                    headers: {
                                                      'Content-Type': 'application/json',
                                                    },
                                                    body: json.encode({
                                                      'a': 'a',
                                                    }),
                                                  );
                                                  paymentIntentData = json.decode(response.body.toString());
                                                  User user = await ProviderUserId().returnUser();

                                                  user.delete();
                                                  await DatabaseMethods.instance.deleteUser(user.uid, customerID);
                                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                                  await preferences.clear();
                                                  AuthMethods().signOut().then((s) {
                                                    AuthMethods.toogleNavBar();
                                                  });
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(builder: (context) => const PageBienvenue()), (Route<dynamic> route) => false);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text("Supprimer mon compte"),
                                    ),
                                  )
                                : Center(
                                    child: RoundedButton(
                                      color: Colors.red,
                                      text: "Supprimer mon compte",
                                      press: () {
                                        return showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Suppression du compte"),
                                            content: const Text("Souhaitez-vous réellement supprimer votre compte ?"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("Annuler"),
                                                onPressed: () => Navigator.of(context).pop(false),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  'Suppression',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                                onPressed: () async {
                                                  User user = await ProviderUserId().returnUser();

                                                  user.delete();
                                                  await DatabaseMethods.instance.deleteUser(user.uid, customerID);
                                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                                  await preferences.clear();
                                                  AuthMethods().signOut().then((s) {
                                                    AuthMethods.toogleNavBar();
                                                  });
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(builder: (context) => const PageBienvenue()), (Route<dynamic> route) => false);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            const SizedBox(height: 20),
                          ]),
                        )),
                    // Affiche les champs de texte pour modifier les informations
                    // lorsque le bouton est pressé
                    Visibility(visible: !isVisible, child: ModifyProfile(myFirstName!, myLastName!, myEmail!, myPhone!, myID!))
                  ],
                ),
                // ),
              ),
            ),
          );
        });
  }
}

class ModifyProfile extends StatefulWidget {
  const ModifyProfile(this.myFirstName, this.myLastName, this.myEmail, this.myPhone, this.myId, {Key? key}) : super(key: key);
  final String myFirstName, myLastName, myEmail, myPhone, myId;
  @override
  _ModifyProfileState createState() => _ModifyProfileState();
}

// Déclaration des variables pour les champs de modification
final lnameField = TextEditingController();
final fnameField = TextEditingController();
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: BuyandByeAppTheme.orangeFonce,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Si un champ est vide, on envoi la valeur déjà présente
                      var lname = lnameField.text == "" ? widget.myLastName : lnameField.text;
                      var fname = fnameField.text == "" ? widget.myFirstName : fnameField.text;
                      var email = emailField.text == "" ? widget.myEmail : emailField.text;
                      var phone = phoneField.text == "" ? widget.myPhone : phoneField.text;
                      DatabaseMethods().updateUserInfo(widget.myId, lname, fname, email, phone);
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
  Widget buildTextField(String labelText, String placeholder, fieldController, bool capitalization) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: fieldController,
        autocorrect: false,
        textCapitalization: capitalization ? TextCapitalization.sentences : TextCapitalization.none,
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
