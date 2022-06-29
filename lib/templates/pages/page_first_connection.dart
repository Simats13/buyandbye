import 'dart:io';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:buyandbye/templates/Pages/page_address_edit.dart';
import 'package:buyandbye/templates/Pages/page_address_next.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates/pages/address_search.dart';
import 'package:buyandbye/templates/pages/place_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoder;

class PageFirstConnection extends StatefulWidget {
  const PageFirstConnection({Key? key}) : super(key: key);

  @override
  _PageFirstConnectionState createState() => _PageFirstConnectionState();
}

class _PageFirstConnectionState extends State<PageFirstConnection> {
  bool isVisible1 = true;
  bool isVisible2 = false;

  @override
  void initState() {
    super.initState();
    userId();
  }

  final formKey = GlobalKey<FormState>();
  userId() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
  }

  String? userid;
  String? val;
  String? idAdress;
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Première connexion'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: BuyandByeAppTheme.blackElectrik,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Visibility(
            visible: isVisible1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Informations(),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isVisible1 = !isVisible1;
                        isVisible2 = !isVisible2;
                      });
                    },
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.only(
                        left: 56.0,
                        right: 56.0,
                        top: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38.0),
                        color: const Color(0xff132137),
                      ),
                      child: const Text(
                        "Mettre une adresse",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isVisible2,
            child: Column(
              children: [
                const AddressChoose(),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(userid)
                        .collection("Address")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(00, 0, 0, 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            RadioListTile(
                                              title: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.place_rounded),
                                                      const SizedBox(width: 10),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              height: 30),
                                                          Text(
                                                            snapshot.data!
                                                                    .docs[index]
                                                                ["addressName"],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Center(
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  200,
                                                              child: Text(snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ["address"]),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 30),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.edit),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          PageAddressEdit(
                                                                            adresse:
                                                                                snapshot.data!.docs[index]["address"],
                                                                            adressTitle:
                                                                                snapshot.data!.docs[index]["addressName"],
                                                                            buildingDetails:
                                                                                snapshot.data!.docs[index]["buildingDetails"],
                                                                            buildingName:
                                                                                snapshot.data!.docs[index]["buildingName"],
                                                                            familyName:
                                                                                snapshot.data!.docs[index]["familyName"],
                                                                            lat:
                                                                                snapshot.data!.docs[index]["latitude"],
                                                                            long:
                                                                                snapshot.data!.docs[index]["longitude"],
                                                                            iD: snapshot.data!.docs[index]["idDoc"],
                                                                          )));
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              value: snapshot.data!.docs[index]
                                                  ["addressName"],
                                              groupValue: val,
                                              onChanged: (dynamic v) => {
                                                setState(
                                                  () {
                                                    val = v;

                                                    idAdress = snapshot.data!
                                                        .docs[index]["idDoc"];
                                                    isEnabled = true;
                                                  },
                                                ),
                                              },
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                );
                              });
                        } else {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: RichText(
                                  text: TextSpan(
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    children: const [
                                      TextSpan(
                                          text:
                                              "Aucune adresse n'est enregistrée.\n\nEnregistrez en une depuis un des deux boutons en haut "),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: isEnabled
                        ? () {
                            // Si un champ est vide, on envoi la valeur déjà présente

                            sendToDatabaseAddress(userid, idAdress);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const Accueil()));
                          }
                        : null,
                    child: const Text('Enregistrer et continuer'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> sendToDatabaseAddress(
    String? userid,
    idAddress,
  ) async {
    try {
      await DatabaseMethods.instance.addFirstAddress(userid, idAddress);
    } catch (e) {
      showAlertDialog(context, 'Error user information to database');
    }
  }
}

class Informations extends StatefulWidget {
  const Informations({Key? key}) : super(key: key);

  @override
  _InformationsState createState() => _InformationsState();
}

class _InformationsState extends State<Informations> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
            child: Image.asset(
              'assets/logo/icon.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Bienvenue sur Buy&Bye ! ",
            style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Text(
              "Avant de commencer veuillez rentrer une adresse ou bien utilisez la géolocalisation afin de trouver les magasins prochent de chez vous !",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddressChoose extends StatefulWidget {
  const AddressChoose({Key? key}) : super(key: key);

  @override
  _AddressChooseState createState() => _AddressChooseState();
}

class _AddressChooseState extends State<AddressChoose> {
  @override
  void initState() {
    super.initState();
    _determinePermission();
  }

  late LocationData _locationData;
  Location location = Location();
  final _controller = TextEditingController();

//Fonction permettant de determiner si l'utilisateur a accepté la localisation ou non
//S'il n'a pas accepté alors cela renvoit false
//S'il a accepté alors ça renvoie la localisation périodiquement

  Future<bool> _determinePermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          permissionChecked = false;
        });
        return false;
      }
    }

    getLocationUser();
    return true;
  }

  //Fonction permettant de retourner la localisation exacte d'un utilisateur
  getLocationUser() async {
    // bool docExists = await DatabaseMethods().checkIfDocExists(userid);

    _locationData = await location.getLocation();

    List<geocoder.Placemark> addresses =
        await geocoder.placemarkFromCoordinates(
            _locationData.latitude!, _locationData.longitude!);
    var first = addresses.first;

    setState(() {
      //Latitude de l'utilisateur via la localisation
      currentLatitude = _locationData.latitude;
      //Longitude de l'utilisateur via la localisation
      currentLongitude = _locationData.longitude;
      //Adresse de l'utilisateur via la localisation
      _currentAddress = "${first.name}, ${first.locality}";
      //Ville de l'utilisateur via la localisation
      city = "${first.locality}";
      permissionChecked = true;
    });
  }

  String? _currentAddress,
      currentAddressLocation,
      streetNumber,
      street,
      city,
      zipCode,
      idAddress,
      userid;
  double? latitude, longitude, currentLatitude, currentLongitude;
  bool permissionChecked = false;
  final geo = GeoFlutterFire();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
            child: Text(
              "Selectionner une adresse",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
          ),
        ]),
        const SizedBox(
          height: 12,
        ),
        const Divider(
          color: Colors.black,
          thickness: 2,
          indent: 10,
          endIndent: 10,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
              child: Text(
                "Via la localisation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        permissionChecked == false
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 5),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 50,
                      child: InkWell(
                        onTap: () async {
                          if (!Platform.isIOS) {
                            return showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Localisation desactivée"),
                                content: const Text(
                                    "Afin d'obtenir votre position exacte vous devez activer la localisation depuis les paramètres de votre smartphone"),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("Annuler"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                      child: const Text("Activer"),
                                      onPressed: () async {
                                        // await Geolocator
                                        //     .openLocationSettings();
                                        await _determinePermission();
                                        Navigator.of(context).pop(true);
                                      }),
                                ],
                              ),
                            );
                          }

                          // todo : showDialog for ios
                          return showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title:
                                        const Text("Localisation desactivée"),
                                    content: const Text(
                                        "Afin d'obtenir votre position exacte vous devez activer la localisation depuis les paramètres de votre smartphone"),
                                    actions: [
                                      // Close the dialog
                                      // You can use the CupertinoDialogAction widget instead
                                      CupertinoButton(
                                          child: const Text('Annuler'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      CupertinoButton(
                                        child: const Text('Activer'),
                                        onPressed: () async {
                                          permissionChecked =
                                              await _determinePermission();

                                          // Then close the dialog
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  ));
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me_rounded),
                              const SizedBox(width: 10),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Ma position"),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      child: const Text(
                                          "Cliquez afin d'activer la localisation sur votre smartphone"),
                                    )
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 5),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 50,
                      child: InkWell(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageAddressNext(
                                        lat: currentLatitude!,
                                        long: currentLongitude!,
                                        adresse: _currentAddress!,
                                      )));
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me_rounded),
                              const SizedBox(width: 10),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Position actuelle"),
                                    const SizedBox(height: 10),
                                    _currentAddress != null
                                        ? Text(_currentAddress!)
                                        : const CircularProgressIndicator(),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        const SizedBox(
          height: 15,
        ),
        const Divider(
          color: Colors.black,
          thickness: 2,
          indent: 10,
          endIndent: 10,
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
              child: Text(
                "Via une saisie manuelle",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        //TODO Réparer et remettre les adresses
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
          child: SizedBox(
            height: 40,
            width: MediaQuery.of(context).size.width - 50,
            child: InkWell(
              onTap: () async {
                // generate a new token here
                final sessionToken = const Uuid().v4();
                final result = await showSearch(
                  context: context,
                  delegate: AddressSearch(sessionToken),
                );

                // This will change the text displayed in the TextField
                final placeDetails = await PlaceApiProvider(sessionToken)
                    .getPlaceDetailFromId(result.placeId);

                setState(() {
                  _controller.text = result.description!;
                  streetNumber = placeDetails.streetNumber;
                  street = placeDetails.street;
                  city = placeDetails.city;
                  zipCode = placeDetails.zipCode;
                  currentAddressLocation = "$streetNumber $street, $city ";
                });

                final query = "$streetNumber $street , $city";

                List<geocoder.Location> locations =
                    await geocoder.locationFromAddress(query);
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.15),
                ),
                padding: const EdgeInsets.only(left: 10),
                child: Row(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search),
                    ],
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Saisir une nouvelle adresse",
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
