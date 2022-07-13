import 'dart:io';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/accueil.dart';
import 'package:buyandbye/templates/pages/address_search.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:buyandbye/services/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:buyandbye/templates/pages/place_service.dart';
import 'package:buyandbye/templates/Pages/page_address_edit.dart';
import 'package:buyandbye/templates/Pages/page_address_next.dart';
import 'package:geocoding/geocoding.dart' as geocoder;

class UserAddress extends StatefulWidget {
  const UserAddress({Key? key}) : super(key: key);

  @override
  _UserAddressState createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  String? currentLocationAddress = "",
      currentAddressSaved = "",
      currentCityLocation,
      streetNumber,
      street,
      city,
      zipCode,
      idAddress,
      userid;
  double latitude = 0,
      longitude = 0,
      currentLocationLatitude = 0,
      currentLocationLongitude = 0;

  LocationData? _locationData;
  Location location = Location();
  bool permissionChecked = false;
  bool chargementChecked = false;

  GeoFlutterFire? geo;
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

  String _textReplace(str) {
    str = str.replaceAll('Avenue', 'Av');
    str = str.replaceAll('Boulevard', 'Bd');
    str = str.replaceAll('Chemin', 'Ch');
    str = str.replaceAll('Impasse', 'Imp');
    str = str.replaceAll('Place', 'Pl');
    str = str.replaceAll('Square', 'Sq');
    str = str.replaceAll('Traverse', 'Tr');
    str = str.replaceAll('Quai', 'Q');
    str = str.replaceAll('Route', 'Rte');
    return str;
  }

  //Fonction permettant de determiner si l'utilisateur a accepté la localisation ou non
  //S'il n'a pas accepté alors cela renvoit false
  //S'il a accepté alors ça renvoie la localisation périodiquement
  _determinePermission() async {
    bool localisationActive;
    PermissionStatus permissionAutorise;

    localisationActive = await location.serviceEnabled();
    if (!localisationActive) {
      localisationActive = await location.requestService();
      if (!localisationActive) {
        return false;
      }
    }

    permissionAutorise = await location.hasPermission();
    if (permissionAutorise == PermissionStatus.denied) {
      permissionAutorise = await location.requestPermission();
      if (permissionAutorise != PermissionStatus.granted) {
        setState(() {
          chargementChecked = true;
        });
        return false;
      }
    }

    setState(() {
      permissionChecked = true;
    });

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _locationData = await location.getLocation();

    List<geocoder.Placemark> addresses =
        await geocoder.placemarkFromCoordinates(
            _locationData!.latitude!, _locationData!.longitude!);
    var first = addresses.first;

    setState(() {
      //Latitude de l'utilisateur via la localisation
      currentLocationLatitude = _locationData?.latitude ?? 0;
      //Longitude de l'utilisateur via la localisation
      currentLocationLongitude = _locationData?.longitude ?? 0;
      //Adresse de l'utilisateur via la localisation
      currentLocationAddress = "${first.name}, ${first.locality}";

      currentLocationAddress = _textReplace(currentLocationAddress!);

      //Ville de l'utilisateur via la localisation
      currentCityLocation = "${first.locality}";
      chargementChecked = true;
    });
    return true;
  }

  getCoordinates() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getChosenAddress(userid);
    latitude = double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");
    idAddress = "${querySnapshot.docs[0]['idDoc']}";
    chargementChecked = true;
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
            Row(children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                child: Text(
                  "Mes Adresses",
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
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width - 50,
                // Affichage de la barre de recherche
                child: InkWell(
                  onTap: () async {
                    // generate a new token here
                    final sessionToken = const Uuid().v4();
                    final result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken),
                    );
                    // This will change the text displayed in the TextField
                    if (result != null) {
                      final placeDetails = await PlaceApiProvider(sessionToken)
                          .getPlaceDetailFromId(result.placeId);

                      setState(() {
                        controller.text = result.description!;
                        streetNumber = placeDetails.streetNumber;
                        street = _textReplace(placeDetails.street);
                        city = placeDetails.city;
                        zipCode = placeDetails.zipCode;
                      });

                      //RECUPERE LA RECHERCHE DE L'UTILISATEUR ET LES CONVERTIT EN COORDONNEES
                      final query = "$street , $city";

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
                                    adresse: _textReplace(result.description),
                                  )));
                    }
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
                    "Proche de vous",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            //LOCALISATION DU TELEPHONE DE L'UTILISATEUR
            permissionChecked
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.20,
                          child: InkWell(
                              onTap: () async {
                                //RECUPERE LA LOCALISATION DE L'UTILISATEUR ET CONVERTIT LES COODORNEES EN ADRESSE
                                List<geocoder.Placemark> addresses =
                                    await geocoder.placemarkFromCoordinates(
                                        currentLocationLatitude,
                                        currentLocationLongitude,
                                        localeIdentifier: 'fr_FR');
                                var first = addresses.first;
                                setState(() {
                                  currentCityLocation = first.locality!;
                                  currentLocationAddress =
                                      first.name! + ', ' + first.locality!;
                                  //A CHANGER LORSQUE LE PROVIDER SERA MIS EN PLACE PREND EN COMPTE LA NOUVELLE ADRESSE ET RECHARGE L'APPLICATION
                                  geo = GeoFlutterFire();
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
                                              lat: currentLocationLatitude,
                                              long: currentLocationLongitude,
                                              adresse: currentLocationAddress,
                                            )));
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxHeight: 57, minHeight: 50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    const Icon(Icons.near_me_rounded),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Position actuelle"),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.40,
                                          child: Text(currentLocationAddress!),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 50,
                          child: InkWell(
                            onTap: () async {
                              Navigator.of(context).pop();
                              if (!Platform.isIOS) {
                                return showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text("Localisation desactivée"),
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
                                        title: const Text(
                                            "Localisation desactivée"),
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
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  const Icon(Icons.near_me_rounded),
                                  const SizedBox(width: 10),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Position actuelle"),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          child: const Text(
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
            const SizedBox(
              height: 15,
            ),
            const Divider(
              color: Colors.black,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    "Mes adresses enregistrées",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    SizedBox(width: 10),
                    Icon(Icons.home),
                    // IconButton(
                    //     onPressed: () async {
                    //       // generate a new token here
                    //       final sessionToken = const Uuid().v4();
                    //       final Suggestion? result = await showSearch(
                    //         context: context,
                    //         delegate: AddressSearch(sessionToken)
                    //             as SearchDelegate<Suggestion>,
                    //       );
                    //       // This will change the text displayed in the TextField
                    //       if (result != null) {
                    //         final placeDetails =
                    //             await PlaceApiProvider(sessionToken)
                    //                 .getPlaceDetailFromId(result.placeId);

                    //         setState(() {
                    //           controller.text = result.description!;
                    //           streetNumber = placeDetails.streetNumber;
                    //           street = placeDetails.street;
                    //           city = placeDetails.city;
                    //           zipCode = placeDetails.zipCode;
                    //           currentLocationAddress =
                    //               "$streetNumber $street, $city ";
                    //         });

                    //         final query = "$street , $city";

                    //         List<geocoder.Location> locations =
                    //             await geocoder.locationFromAddress(query);
                    //         var first = locations.first;

                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => PageAddressNext(
                    //                       lat: first.latitude,
                    //                       long: first.longitude,
                    //                       adresse: query,
                    //                     )));
                    //       }
                    //     },
                    //     icon: const Icon(Icons.home)),
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
                    return const Center(
                      child: ColorLoader3(
                        radius: 15.0,
                        dotRadius: 6.0,
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if ((snapshot.data! as QuerySnapshot).docs.isNotEmpty) {
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              (snapshot.data! as QuerySnapshot).docs.length,
                          itemBuilder: (context, index) {
                            return InkWell(
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
                                  idAddress = (snapshot.data! as QuerySnapshot)
                                      .docs[index]["idDoc"];
                                  latitude = (snapshot.data! as QuerySnapshot)
                                      .docs[index]["latitude"];
                                  longitude = (snapshot.data! as QuerySnapshot)
                                      .docs[index]["longitude"];
                                  currentAddressSaved =
                                      first.name! + ", " + first.locality!;

                                  geo = GeoFlutterFire();
                                  GeoFirePoint center = geo!.point(
                                      latitude:
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]["latitude"],
                                      longitude:
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]["longitude"]);
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
                                int count = 0;

                                Navigator.of(context).pushAndRemoveUntil(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            const Accueil(),
                                    transitionDuration:
                                        const Duration(seconds: 0),
                                  ),
                                  (_) =>
                                      count++ >=
                                      3, //3 is count of your pages you want to pop
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Icon(Icons.place_rounded),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]["addressName"],
                                        ),
                                        Center(
                                          child: SizedBox(
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
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PageAddressEdit(
                                                      adresse: (snapshot.data!
                                                              as QuerySnapshot)
                                                          .docs[index]["address"],
                                                      adressTitle: (snapshot
                                                                      .data!
                                                                  as QuerySnapshot)
                                                              .docs[index]
                                                          ["addressName"],
                                                      buildingDetails: (snapshot
                                                                      .data!
                                                                  as QuerySnapshot)
                                                              .docs[index]
                                                          ["buildingDetails"],
                                                      buildingName: (snapshot
                                                                      .data!
                                                                  as QuerySnapshot)
                                                              .docs[index]
                                                          ["buildingName"],
                                                      familyName: (snapshot
                                                                      .data!
                                                                  as QuerySnapshot)
                                                              .docs[index]
                                                          ["familyName"],
                                                      lat: (snapshot.data!
                                                              as QuerySnapshot)
                                                          .docs[index]["latitude"],
                                                      long: (snapshot.data!
                                                                  as QuerySnapshot)
                                                              .docs[index]
                                                          ["longitude"],
                                                      iD: (snapshot.data!
                                                              as QuerySnapshot)
                                                          .docs[index]["idDoc"],
                                                    )));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: const [
                                  TextSpan(
                                      text:
                                          "Aucune adresse n'est enregistrée.\n\nEnregistrez en une depuis la page d'Accueil ou bien en cliquant sur la "),
                                  WidgetSpan(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Icon(Icons.home),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
            const SizedBox(height: 15)
          ]),
        ));
  }
}
