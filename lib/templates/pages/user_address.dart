import 'dart:io';

import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/pages/address_search.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:buyandbye/templates/pages/place_service.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:buyandbye/templates/Pages/pageAddressEdit.dart';
import 'package:buyandbye/templates/Pages/pageAddressNext.dart';
import 'package:geocoding/geocoding.dart' as geocoder;

class UserAddress extends StatefulWidget {
  @override
  _UserAddressState createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  String? currentAddress = "",
      currentAddressLocation = "",
      streetNumber,
      street,
      city,
      zipCode,
      idAddress,
      userid;
  double latitude = 0, longitude = 0, currentLatitude = 0, currentLongitude = 0;

  LocationData? _locationData;
  Location location = Location();
  bool permissionChecked = false;
  bool chargementChecked = false;

  // Future _future = DatabaseMethods().getCart();
  var currentLocation, position;
  Geoflutterfire? geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;
  final controller = TextEditingController();
  final serviceEnabled = Geolocator.isLocationServiceEnabled();

  @override
  void initState() {
    super.initState();
    _determinePermission();
    getCoordinates();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // Fonction permettant de determiner si l'utilisateur a accepté la localisation ou non
  // S'il n'a pas accepté alors cela renvoit false
  // S'il a accepté alors ça renvoie la localisation périodiquement
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
          chargementChecked = true;
        });
        return false;
      }
    }

    setState(() {
      permissionChecked = true;
    });
    getLocationUser();
    return true;
  }

  //Fonction permettant de retourner la localisation exacte d'un utilisateur
  getLocationUser() async {
    // bool docExists = await DatabaseMethods().checkIfDocExists(userid);

    _locationData = await location.getLocation();
    List<geocoder.Placemark> addresses =
        await geocoder.placemarkFromCoordinates(
            _locationData!.latitude!, _locationData!.longitude!);
    var first = addresses.first;

    setState(() {
      //Latitude de l'utilisateur via la localisation
      currentLatitude = _locationData!.latitude ?? 0;
      //Longitude de l'utilisateur via la localisation
      currentLongitude = _locationData!.longitude ?? 0;
      //Adresse de l'utilisateur via la localisation
      currentAddress = "${first.name}, ${first.locality}";
      //Ville de l'utilisateur via la localisation
      city = "${first.locality}";
      chargementChecked = true;
    });
  }

  getCoordinates() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    QuerySnapshot querySnapshot = await (DatabaseMethods()
        .getChosenAddress(userid) /*as Future<QuerySnapshot<Object>>*/);
    latitude = double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");

    List<geocoder.Placemark> addresses =
        await geocoder.placemarkFromCoordinates(latitude, longitude);

    var first = addresses.first;
    currentAddressLocation = "${first.name}, ${first.locality}";
    idAddress = "${querySnapshot.docs[0]['idDoc']}";
    city = "${first.locality}";
    // chargementChecked = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
                child: Text(
                  "Mes Adresses",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
            ]),
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              child: SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width - 50,
                child: InkWell(
                  onTap: () async {
                    // generate a new token here
                    final sessionToken = Uuid().v4();
                    final Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken)
                          as SearchDelegate<Suggestion>,
                    );
                    // This will change the text displayed in the TextField
                    if (result != null) {
                      final placeDetails = await PlaceApiProvider(sessionToken)
                          .getPlaceDetailFromId(result.placeId);

                      setState(() {
                        controller.text = result.description!;
                        streetNumber = placeDetails.streetNumber;
                        street = placeDetails.street;
                        city = placeDetails.city;
                        zipCode = placeDetails.zipCode;
                        currentAddressLocation =
                            "$streetNumber $street, $city ";
                      });

                      final query = "$streetNumber $street , $city";

                      List<geocoder.Location> locations =
                          await geocoder.locationFromAddress(query);
                      var first = locations.first;

                      Navigator.of(context).pop();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PageAddressNext(
                                    lat: first.latitude,
                                    long: first.longitude,
                                    adresse: query,
                                  )));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.withOpacity(0.15),
                    ),
                    padding: EdgeInsets.only(left: 10),
                    child: Row(children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search),
                        ],
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
            Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
                  child: Container(
                    child: Text(
                      "Proche de vous",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            permissionChecked
                ? Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 50,
                          child: InkWell(
                            onTap: () async {
                              List<geocoder.Placemark> addresses =
                                  await geocoder.placemarkFromCoordinates(
                                      latitude, longitude);
                              var first = addresses.first;
                              setState(() {
                                city = first.locality!;

                                currentAddressLocation =
                                    "${first.name! + ", " + first.locality!}";
                                geo = Geoflutterfire();
                                GeoFirePoint center = geo!.point(
                                    latitude: latitude, longitude: longitude);
                                stream = radius.switchMap((rad) {
                                  var collectionReference = FirebaseFirestore
                                      .instance
                                      .collection('magasins');
                                  return geo!
                                      .collection(
                                          collectionRef: collectionReference)
                                      .within(
                                          center: center,
                                          radius: 100,
                                          field: 'position',
                                          strictMode: true);
                                });
                              });

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageAddressNext(
                                            lat: currentLatitude,
                                            long: currentLongitude,
                                            adresse: currentAddress,
                                          )));
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.near_me_rounded),
                                  SizedBox(width: 20),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Position actuelle"),
                                        SizedBox(height: 10),
                                        Text(currentAddress!)
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
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 50,
                          child: InkWell(
                            onTap: () async {
                              Navigator.of(context).pop();
                              if (!Platform.isIOS) {
                                return showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Localisation desactivée"),
                                    content: Text(
                                        "Afin d'obtenir votre position exacte vous devez activer la localisation depuis les paramètres de votre smartphone"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Annuler"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                          child: Text("Activer"),
                                          onPressed: () async {
                                            await Geolocator
                                                .openLocationSettings();
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
                                        title: Text("Localisation desactivée"),
                                        content: Text(
                                            "Afin d'obtenir votre position exacte vous devez activer la localisation depuis les paramètres de votre smartphone"),
                                        actions: [
                                          // Close the dialog
                                          // You can use the CupertinoDialogAction widget instead
                                          CupertinoButton(
                                              child: Text('Annuler'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }),
                                          CupertinoButton(
                                            child: Text('Activer'),
                                            onPressed: () async {
                                              await Geolocator
                                                  .openLocationSettings();

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
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.near_me_rounded),
                                  SizedBox(width: 10),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Position actuelle"),
                                        SizedBox(height: 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          child: Text(
                                              "Vous devez activer la localisation sur votre téléphone"),
                                        )
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: 15,
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Container(
                    child: Text(
                      "Mes adresses enregistrées",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 10),
                    IconButton(
                        onPressed: () async {
                          // generate a new token here
                          final sessionToken = Uuid().v4();
                          final Suggestion? result = await showSearch(
                            context: context,
                            delegate: AddressSearch(sessionToken)
                                as SearchDelegate<Suggestion>,
                          );
                          // This will change the text displayed in the TextField
                          if (result != null) {
                            final placeDetails =
                                await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(result.placeId);

                            setState(() {
                              controller.text = result.description!;
                              streetNumber = placeDetails.streetNumber;
                              street = placeDetails.street;
                              city = placeDetails.city;
                              zipCode = placeDetails.zipCode;
                              currentAddressLocation =
                                  "$streetNumber $street, $city ";
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
                          }
                        },
                        icon: Icon(Icons.home)),
                  ],
                ),
              ],
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(userid)
                    .collection("Address")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: ColorLoader3(
                        radius: 15.0,
                        dotRadius: 6.0,
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if ((snapshot.data! as QuerySnapshot).docs.length > 0) {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              (snapshot.data! as QuerySnapshot).docs.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    List<geocoder.Placemark> addresses =
                                        await geocoder.placemarkFromCoordinates(
                                            (snapshot.data! as QuerySnapshot)
                                                .docs[index]["latitude"],
                                            (snapshot.data! as QuerySnapshot)
                                                .docs[index]["longitude"]);
                                    var first = addresses.first;

                                    await DatabaseMethods().changeChosenAddress(
                                        userid,
                                        (snapshot.data! as QuerySnapshot)
                                            .docs[index]["idDoc"],
                                        idAddress);
                                    setState(() {
                                      city = first.locality!;
                                      idAddress =
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]["idDoc"];
                                      latitude =
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]["latitude"];
                                      longitude =
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]["longitude"];
                                      currentAddressLocation =
                                          "${first.name! + ", " + first.locality!}";

                                      geo = Geoflutterfire();
                                      GeoFirePoint center = geo!.point(
                                          latitude:
                                              (snapshot.data! as QuerySnapshot)
                                                  .docs[index]["latitude"],
                                          longitude:
                                              (snapshot.data! as QuerySnapshot)
                                                  .docs[index]["longitude"]);
                                      stream = radius.switchMap((rad) {
                                        var collectionReference =
                                            FirebaseFirestore.instance
                                                .collection('magasins');
                                        return geo!
                                            .collection(
                                                collectionRef:
                                                    collectionReference)
                                            .within(
                                                center: center,
                                                radius: 100,
                                                field: 'position',
                                                strictMode: true);
                                      });
                                    });
                                    Phoenix.rebirth(context);
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.place_rounded),
                                        SizedBox(width: 15),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (snapshot.data!
                                                      as QuerySnapshot)
                                                  .docs[index]["addressName"],
                                            ),
                                            Center(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.57,
                                                child: Text((snapshot.data!
                                                        as QuerySnapshot)
                                                    .docs[index]["address"]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PageAddressEdit(
                                                          adresse: (snapshot
                                                                          .data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              ["address"],
                                                          adressTitle: (snapshot
                                                                          .data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              ["addressName"],
                                                          buildingDetails: (snapshot
                                                                          .data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              [
                                                              "buildingDetails"],
                                                          buildingName: (snapshot
                                                                          .data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              [
                                                              "buildingName"],
                                                          familyName: (snapshot
                                                                          .data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              ["familyName"],
                                                          lat: (snapshot.data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              ["latitude"],
                                                          long: (snapshot.data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              ["longitude"],
                                                          iD: (snapshot.data!
                                                                      as QuerySnapshot)
                                                                  .docs[index]
                                                              ["idDoc"],
                                                        )));
                                          },
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
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Container(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyText2,
                                  children: [
                                    TextSpan(
                                        text:
                                            "Aucune adresse n'est enregistrée.\n\nEnregistrez en une depuis la page d'Accueil ou bien en cliquant sur la "),
                                    WidgetSpan(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Icon(Icons.home),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })
          ]),
        ));
  }
}
