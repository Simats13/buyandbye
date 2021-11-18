import 'dart:async';
import 'dart:io';
import 'package:buyandbye/templates/widgets/slide_items.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart' as geocoder;

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Pages/cart.dart';
import 'package:buyandbye/templates/Pages/pageAddressEdit.dart';
import 'package:buyandbye/templates/Pages/pageAddressNext.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:buyandbye/templates/pages/pageDetail.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:buyandbye/theme/styles.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/widgets/custom_slider.dart';

class PageAccueil extends StatefulWidget {
  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  late LocationData _locationData;
  Location location = Location();
  late bool permissionChecked;
  bool chargementChecked = false;

  // INITIALISATION DE SHARE_PREFERENCES (PERMET DE GARDER EN MEMOIRE DES INFORMATIONS, ICI LA LONGITUDE ET LA LATITUDE)
  static late SharedPreferences _preferences;
  static const _keyLatitude = "UserLatitudeKey";
  static const _keyLongitude = "UserLongitudeKey";
  static const _keyAddress = "UserAddressKey";
  static const _keyCity = "UserCityKey";

  // Future _future = DatabaseMethods().getCart();
  var currentLocation, position;

  String _currentAddress = "",
      _currentAddressLocation = "",
      streetNumber = "",
      street = "",
      _city = "",
      zipCode = "",
      idAddress = "",
      userid = "";
  double latitude = 0, longitude = 0, currentLatitude = 0, currentLongitude = 0;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;
  final controller = TextEditingController();
  final serviceEnabled = Geolocator.isLocationServiceEnabled();

  @override
  void initState() {
    super.initState();
    // userID();

    _determinePermission();
    getCoordinates();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  positionCheck() async {
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
    stream = radius.switchMap((rad) {
      var collectionReference =
          FirebaseFirestore.instance.collection('magasins');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: 10, field: 'position', strictMode: true);
    });
  }

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
      currentLatitude = _locationData.latitude ?? 0;
      //Longitude de l'utilisateur via la localisation
      currentLongitude = _locationData.longitude ?? 0;
      //Adresse de l'utilisateur via la localisation
      _currentAddress = "${first.name}, ${first.locality}";
      //Ville de l'utilisateur via la localisation
      _city = "${first.locality}";
      chargementChecked = true;
    });
  }

  getCoordinates() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    QuerySnapshot querySnapshot =
        await (DatabaseMethods().getChosenAddress(userid) /*as Future<QuerySnapshot<Object>>*/);
    latitude =
        double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");

    List<geocoder.Placemark> addresses =
        await geocoder.placemarkFromCoordinates(latitude, longitude);

    var first = addresses.first;
    _currentAddressLocation =
        "${first.name}, ${first.locality}";
    idAddress = "${querySnapshot.docs[0]['idDoc']}";
    _city = "${first.locality}";
    // chargementChecked = true;
    setState(() {});
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    // getCoordinates();
    positionCheck();

    return chargementChecked
        ? StreamBuilder(
            stream: stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData)
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorLoader3(
                        radius: 15.0,
                        dotRadius: 6.0,
                      ),
                      Text("Chargement, veuillez patienter"),
                    ],
                  ),
                );

              if (snapshot.data!.length > 0) {
                return ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width - 70,
                                decoration: BoxDecoration(
                                  color: textFieldColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            height: 30,
                                            width: size.width - 150,
                                            child: InkWell(
                                              onTapCancel: () {
                                                Navigator.of(context).pop();
                                              },
                                              onTap: () async {
                                                permissionChecked =
                                                    await _determinePermission();

                                                affichageAddress();
                                              },
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(top: 5),
                                                child: Text(
                                                  _currentAddressLocation,
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 6,
                                    right: 6,
                                  ),
                                  child: IconButton(
                                    icon: Container(
                                      child: Center(
                                        child: Icon(
                                          Icons.shopping_cart,
                                          // size: 22,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      affichageCart();
                                    },
                                  ),
                                ),
                              ]),
                            ]),
                        SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          height: 15,
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "Les bons plans du moment",
                            style: customTitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "Des bons plans à $_city  🤲",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.all(20),
                          child: SliderAccueil1(latitude, longitude),
                        ),

                        Center(
                            child: Text(
                          "Sponsorisé",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.00),
                        )),
                        SizedBox(
                          height: 15,
                        ),

                        //trait gris de séparation
                        Container(
                          width: size.width,
                          height: 10,
                          decoration: BoxDecoration(color: textFieldColor),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "Près de chez vous",
                            style: customTitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "-3km 📍",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: SliderAccueil2(latitude, longitude),
                        ),

                        //trait gris de séparation
                        Container(
                          width: size.width,
                          height: 10,
                          decoration: BoxDecoration(color: textFieldColor),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "Plus à découvrir",
                            style: customTitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Text(
                            "-10km 🗺️",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: SliderAccueil3(latitude, longitude),
                        ),

                        SizedBox(
                          height: 15,
                        ),
                        // Text(
                        //   "    Vous avez acheté chez eux récemment",
                        //   style: customTitle,
                        // ),
                        // Container(
                        //   padding: EdgeInsets.all(20),
                        //   child: SliderAccueil4(latitude, longitude),
                        //   ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        Container(
                          width: size.width,
                          height: 10,
                          decoration: BoxDecoration(color: textFieldColor),
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // Center(
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       affichageAllStores();
                        //     },
                        //     child: Container(
                        //       height: 50,
                        //       width: 210,
                        //       decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(20),
                        //           color: BuyandByeAppTheme.black_electrik),
                        //       child: Text(
                        //         "Afficher tous les commerçants",
                        //         style: TextStyle(color: white),
                        //       ),
                        //       alignment: Alignment.center,
                        //     ),
                        //   ),
                        // ),

                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              height: 45,
                              width: size.width - 70,
                              decoration: BoxDecoration(
                                color: textFieldColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 30,
                                          width: size.width - 150,
                                          child: InkWell(
                                            onTap: () async {
                                              permissionChecked =
                                                  await _determinePermission();

                                              affichageAddress();
                                            },
                                            child: Container(
                                              width: size.width - 150,
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text(
                                                _currentAddressLocation,
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Container(
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/splash_2.png',
                            width: 300,
                            height: 300,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Aucun commerce n'est disponible pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                              style: TextStyle(
                                fontSize: 18,
                                // color: Colors.grey[700]
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      )),
                    ),
                  ],
                );
              }
            })
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
                Text("Chargement, veuillez patienter"),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  void affichageCart() {
    slideDialog.showSlideDialog(context: context, child: CartPage());
  }

  void affichageAllStores() {
    slideDialog.showSlideDialog(
        context: context,
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Tous les commerçants",
                style: customTitle,
              ),
              SizedBox(
                height: 10,
              ),
              Text("À proximité de vous",
                  style: TextStyle(
                    fontSize: 15,
                  )),
              SizedBox(
                height: 10,
              ),
              AllStores(),
            ]),
          ),
        ));
  }

  void affichageAddress() {
    slideDialog.showSlideDialog(
        context: context,
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              Column(
                children: [
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
                  //TODO Réparer et remettre les adresses x2
                  /*Padding(
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
                            delegate: AddressSearch(sessionToken),
                          );
                          // This will change the text displayed in the TextField
                          if (result != null) {
                            final placeDetails =
                                await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(result.placeId);

                            setState(() {
                              _controller.text = result.description!;
                              _streetNumber = placeDetails.streetNumber;
                              _street = placeDetails.street;
                              _city = placeDetails.city;
                              zipCode = placeDetails.zipCode;
                              _currentAddressLocation =
                                  "$_streetNumber $_street, $_city ";
                            });

                            final query = "$_streetNumber $_street , $_city";

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
                  ),*/
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
                                      _city = first.locality!;

                                      _currentAddressLocation =
                                          "${first.name! + ", " + first.locality!}";
                                      geo = Geoflutterfire();
                                      GeoFirePoint center = geo.point(
                                          latitude: latitude,
                                          longitude: longitude);
                                      stream = radius.switchMap((rad) {
                                        var collectionReference =
                                            FirebaseFirestore.instance
                                                .collection('magasins');
                                        return geo
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

                                    _preferences =
                                        await SharedPreferences.getInstance();

                                    await _preferences.setDouble(
                                        _keyLatitude, latitude);

                                    await _preferences.setDouble(
                                        _keyLongitude, longitude);

                                    await _preferences.setString(
                                        _keyAddress, _currentAddressLocation);

                                    await _preferences.setString(
                                        _keyCity, _city);

                                    SharedPreferenceHelper()
                                        .saveUserCity(_city);

                                    SharedPreferenceHelper().saveUserAddress(
                                        _currentAddressLocation);

                                    SharedPreferenceHelper()
                                        .saveUserLatitude(latitude);

                                    SharedPreferenceHelper()
                                        .saveUserLongitude(longitude);
                                    setState(() {});
                                    Navigator.of(context).pop();

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PageAddressNext(
                                                  lat: currentLatitude,
                                                  long: currentLongitude,
                                                  adresse: _currentAddress,
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
                                        SizedBox(width: 10),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Position actuelle"),
                                              SizedBox(height: 10),
                                              _currentAddress != null
                                                  ? Text(_currentAddress)
                                                  : CircularProgressIndicator(),
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
                                          title:
                                              Text("Localisation desactivée"),
                                          content: Text(
                                              "Afin d'obtenir votre position exacte vous devez activer la localisation depuis les paramètres de votre smartphone"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Annuler"),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                            ),
                                            TextButton(
                                                child: Text("Activer"),
                                                onPressed: () async {
                                                  await Geolocator
                                                      .openLocationSettings();
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }),
                                          ],
                                        ),
                                      );
                                    }

                                    // todo : showDialog for ios
                                    return showCupertinoDialog(
                                        context: context,
                                        builder: (context) =>
                                            CupertinoAlertDialog(
                                              title: Text(
                                                  "Localisation desactivée"),
                                              content: Text(
                                                  "Afin d'obtenir votre position exacte vous devez activer la localisation depuis les paramètres de votre smartphone"),
                                              actions: [
                                                // Close the dialog
                                                // You can use the CupertinoDialogAction widget instead
                                                CupertinoButton(
                                                    child: Text('Annuler'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 10),
                          IconButton(
                              onPressed: () async {
                                // generate a new token here
                                final sessionToken = Uuid().v4();
                                final Suggestion? result = await showSearch(
                                  context: context,
                                  delegate: AddressSearch(sessionToken),
                                );
                                // This will change the text displayed in the TextField
                                if (result != null) {
                                  final placeDetails =
                                      await PlaceApiProvider(sessionToken)
                                          .getPlaceDetailFromId(result.placeId);

                                  setState(() {
                                    _controller.text = result.description!;
                                    _streetNumber = placeDetails.streetNumber;
                                    _street = placeDetails.street;
                                    _city = placeDetails.city;
                                    zipCode = placeDetails.zipCode;
                                    _currentAddressLocation =
                                        "$_streetNumber $_street, $_city ";
                                  });

                                  final query =
                                      "$_streetNumber $_street , $_city";

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
                      ),*/
                    ],
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(userid)
                          .collection("Address")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          List<geocoder.Placemark> addresses =
                                              await geocoder
                                                  .placemarkFromCoordinates(
                                                      (snapshot.data! as QuerySnapshot).docs[index]
                                                          ["latitude"],
                                                      (snapshot.data! as QuerySnapshot).docs[index]
                                                          ["longitude"]);
                                          var first = addresses.first;

                                          await DatabaseMethods()
                                              .changeChosenAddress(
                                                  userid,
                                                  (snapshot.data! as QuerySnapshot).docs[index]
                                                      ["idDoc"],
                                                  idAddress);
                                          setState(() {
                                            _city = first.locality!;
                                            idAddress = (snapshot.data! as QuerySnapshot).docs[index]["idDoc"];
                                            latitude = (snapshot.data! as QuerySnapshot).docs[index]
                                                ["latitude"];
                                            longitude = (snapshot.data! as QuerySnapshot).docs[index]["longitude"];
                                            _currentAddressLocation =
                                                "${first.name! + ", " + first.locality!}";

                                            geo = Geoflutterfire();
                                            GeoFirePoint center = geo.point(
                                                latitude: (snapshot.data! as QuerySnapshot)
                                                    .docs[index]["latitude"],
                                                longitude: (snapshot.data! as QuerySnapshot)
                                                    .docs[index]["longitude"]);
                                            stream = radius.switchMap((rad) {
                                              var collectionReference =
                                                  FirebaseFirestore.instance
                                                      .collection('magasins');
                                              return geo
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

                                          _preferences = await SharedPreferences
                                              .getInstance();

                                          await _preferences.setDouble(
                                              _keyLatitude,
                                              (snapshot.data! as QuerySnapshot).docs[index]
                                                  ["latitude"]);

                                          await _preferences.setString(
                                              _keyCity, _city);

                                          await _preferences.setDouble(
                                              _keyLongitude,
                                              (snapshot.data! as QuerySnapshot).docs[index]
                                                  ["longitude"]);

                                          await _preferences.setString(
                                              _keyAddress,
                                              _currentAddressLocation);

                                          SharedPreferenceHelper()
                                              .saveUserAddress(
                                                  _currentAddressLocation);
                                          SharedPreferenceHelper()
                                              .saveUserCity(_city);

                                          SharedPreferenceHelper()
                                              .saveUserLatitude((snapshot.data! as QuerySnapshot)
                                                  .docs[index]["latitude"]);

                                          SharedPreferenceHelper()
                                              .saveUserLongitude((snapshot.data! as QuerySnapshot)
                                                  .docs[index]["longitude"]);

                                          Navigator.of(context).pop();
                                        },
                                        child: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 0, 0),
                                                  child:
                                                      Icon(Icons.place_rounded),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 30),
                                                  Container(
                                                    child: Text(
                                                      (snapshot.data! as QuerySnapshot).docs[index]
                                                          ["addressName"],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              120,
                                                      child: Text((snapshot.data! as QuerySnapshot).docs[index]
                                                          ["address"]),
                                                    ),
                                                  ),
                                                  SizedBox(height: 30),
                                                ]),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PageAddressEdit(
                                                                  adresse: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "address"],
                                                                  adressTitle: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "addressName"],
                                                                  buildingDetails: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "buildingDetails"],
                                                                  buildingName: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "buildingName"],
                                                                  familyName: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "familyName"],
                                                                  lat: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "latitude"],
                                                                  long: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      [
                                                                      "longitude"],
                                                                  iD: (snapshot.data! as QuerySnapshot)
                                                                          .docs[index]
                                                                      ["idDoc"],
                                                                )));
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                        children: [
                                          TextSpan(
                                              text:
                                                  "Aucune adresse n'est enregistrée.\n\nEnregistrez en une depuis la page d'Accueil ou bien en cliquant sur la "),
                                          WidgetSpan(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                      }),
                ],
              )
            ]),
          ),
        ));
  }
}

// ignore: must_be_immutable
class SliderAccueil1 extends StatefulWidget {
  SliderAccueil1(
    this.latitude,
    this.longitude,
  );
  double? latitude;
  double? longitude;
  @override
  _SliderAccueil1State createState() => _SliderAccueil1State();
}
//BON PLANS

class _SliderAccueil1State extends State<SliderAccueil1> {
  var currentLocation;
  var position;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    //FONCTION PERMETTANT DE RECUPERER LES MAGASINS ET DE LES AFFICHER EN FONCTION DE LA POSITION DE L'UTLISATEUR

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo.point(latitude: widget.latitude!, longitude: widget.longitude!);
      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance
            .collection('magasins')
            .where("sponsored", isEqualTo: true);
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  List listImages(documents) {
    List shopImages = [];
    for (int i = 0; i < documents.length; i++) {
      shopImages.add(documents[i]["imgUrl"]);
    }
    return shopImages;
  }

  int carouselItem = 0;
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
              child: Container(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          // final documents = (snapshot.data! as QuerySnapshot)..shuffle();
          if (snapshot.data!().length > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!().length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                      img: snapshot.data!()[index]["imgUrl"],
                      name: snapshot.data!()[index]["name"],
                      address: snapshot.data!()[index]["adresse"],
                      description: snapshot.data!()[index]["description"],
                      livraison: snapshot.data!()[index]["livraison"],
                      sellerID: snapshot.data!()[index]["id"],
                      colorStore: snapshot.data!()[index]["colorStore"],
                      clickAndCollect: snapshot.data!()[index]["ClickAndCollect"],
                    ),
                  );
                },
              ),
            );
          } else {
            return Container(
              child: Center(
                  child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/splash_2.png',
                    width: 50,
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Aucun commerce n'est disponible près de chez vous pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                      style: TextStyle(
                        fontSize: 18,
                        // color: Colors.grey[700]
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              )),
            );
          }
        });
  }
}

// ignore: must_be_immutable
class SliderAccueil2 extends StatefulWidget {
  SliderAccueil2(
    this.latitude,
    this.longitude,
  );
  double? latitude;
  double? longitude;
  @override
  _SliderAccueil2State createState() => _SliderAccueil2State();
}

//PRES DE CHEZ VOUS
class _SliderAccueil2State extends State<SliderAccueil2> {
  var currentLocation;
  var position;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo.point(latitude: widget.latitude!, longitude: widget.longitude!);
      stream = radius.switchMap((rad) {
        var collectionReference =
            FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 3, field: 'position', strictMode: true);
      });
    });
  }

  List listImages(documents) {
    List shopImages = [];
    for (int i = 0; i < documents.length; i++) {
      shopImages.add(documents[i]["imgUrl"]);
    }
    return shopImages;
  }

  int carouselItem = 0;
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
              child: Container(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          // final documents = (snapshot.data! as QuerySnapshot)..shuffle();
          if (snapshot.data.length > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                      img: snapshot.data[index]["imgUrl"],
                      name: snapshot.data[index]["name"],
                      address: snapshot.data[index]["adresse"],
                      description: snapshot.data[index]["description"],
                      livraison: snapshot.data[index]["livraison"],
                      sellerID: snapshot.data[index]["id"],
                      colorStore: snapshot.data[index]["colorStore"],
                      clickAndCollect: snapshot.data[index]["ClickAndCollect"],
                    ),
                  );
                },
              ),
            );
          } else {
            return Container(
              child: Center(
                  child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/splash_2.png',
                    width: 50,
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Aucun commerce n'est disponible près de chez vous pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                      style: TextStyle(
                        fontSize: 18,

                        // color: Colors.grey[700]
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              )),
            );
          }
        });
  }
}

// ignore: must_be_immutable
class SliderAccueil3 extends StatefulWidget {
  SliderAccueil3(
    this.latitude,
    this.longitude,
  );
  double? latitude;
  double? longitude;
  @override
  _SliderAccueil3State createState() => _SliderAccueil3State();
}

class _SliderAccueil3State extends State<SliderAccueil3> {
  var currentLocation;
  var position;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo.point(latitude: widget.latitude!, longitude: widget.longitude!);
      stream = radius.switchMap((rad) {
        var collectionReference =
            FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  List listImages(documents) {
    List shopImages = [];
    for (int i = 0; i < documents.length; i++) {
      shopImages.add(documents[i]["imgUrl"]);
    }
    return shopImages;
  }

  int carouselItem = 0;
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
              child: Container(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          // final documents = (snapshot.data! as QuerySnapshot)..shuffle();
          if (snapshot.data!.legth > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                      img: snapshot.data[index]["imgUrl"],
                      name: snapshot.data[index]["name"],
                      address: snapshot.data[index]["adresse"],
                      description: snapshot.data[index]["description"],
                      livraison: snapshot.data[index]["livraison"],
                      sellerID: snapshot.data[index]["id"],
                      colorStore: snapshot.data[index]["colorStore"],
                      clickAndCollect: snapshot.data[index]["ClickAndCollect"],
                    ),
                  );
                },
              ),
            );
          } else {
            return Container(
              child: Center(
                  child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/splash_2.png',
                    width: 50,
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Aucun commerce n'est disponible près de chez vous pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                      style: TextStyle(
                        fontSize: 18,

                        // color: Colors.grey[700]
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              )),
            );
          }
        });
  }
}

class SliderAccueil4 extends StatefulWidget {
  @override
  _SliderAccueil4State createState() => _SliderAccueil4State();
}

//ACHAT USER
class _SliderAccueil4State extends State<SliderAccueil4> {
  List listImages(documents) {
    List shopImages = [];
    for (int i = 0; i < documents.length; i++) {
      shopImages.add(documents[i]["imgUrl"]);
    }
    return shopImages;
  }

  int carouselItem = 0;
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: DatabaseMethods().getStoreInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
              child: Container(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          // final documents = (snapshot.data! as QuerySnapshot)..shuffle();
          if (snapshot.data.length > 0) {
            List shopImages = listImages((snapshot.data! as QuerySnapshot));
            return CarouselSlider(
                options: CarouselOptions(
                    height: 200,
                    // Les images tournent en boucle sauf s'il n'y en a qu'une
                    enableInfiniteScroll: shopImages.length > 1 ? true : false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        carouselItem = index;
                      });
                    }),
                items: shopImages.map((i) {
                  return Builder(builder: (context) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data[carouselItem]
                                            ['imgUrl'],
                                        colorStore: snapshot.data[carouselItem]
                                            ['colorStore'],
                                        name: snapshot.data[carouselItem]
                                            ['name'],
                                        description: snapshot.data[carouselItem]
                                            ['description'],
                                        adresse: snapshot.data[carouselItem]
                                            ['adresse'],
                                        clickAndCollect:
                                            snapshot.data[carouselItem]
                                                ['ClickAndCollect'],
                                        livraison: snapshot.data[carouselItem]
                                            ['livraison'],
                                        sellerID: snapshot.data[carouselItem]
                                            ['id'],
                                      )));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                                // border: Border.all(color: Colors.black),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 4,
                                      offset: Offset(4, 4))
                                ]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 10,
                                  child: Image.network(i),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 10, top: 40),
                                    child: Text(
                                        snapshot.data!()[carouselItem]["name"],
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700))),
                              ],
                            )));
                  });
                }).toList());
          } else {
            return Container(
              child: Center(
                  child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/splash_2.png',
                    width: 50,
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Aucun commerce n'est disponible près de chez vous pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                      style: TextStyle(
                        fontSize: 18,

                        // color: Colors.grey[700]
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              )),
            );
          }
        });
  }
}

class AllStores extends StatefulWidget {
  @override
  _AllStoresState createState() => _AllStoresState();
}

class _AllStoresState extends State<AllStores> {
  var currentLocation;
  late var position;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        position = value;
        geo = Geoflutterfire();
        GeoFirePoint center = geo.point(
            latitude: position.latitude, longitude: position.longitude);
        stream = radius.switchMap((rad) {
          var collectionReference =
              FirebaseFirestore.instance.collection('magasins');
          return geo.collection(collectionRef: collectionReference).within(
              center: center, radius: 50, field: 'position', strictMode: true);
        });
      });
    });
  }

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              height: 45,
                              width: size.width - 70,
                              decoration: BoxDecoration(
                                color: textFieldColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 30,
                                          width: size.width - 150,
                                          child: InkWell(
                                            onTap: () async {},
                                            child: Container(
                                              width: size.width - 150,
                                              padding: EdgeInsets.only(top: 5),
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //Carrée

                                SizedBox(
                                  height: 15,
                                ),

                                Expanded(
                                  child: CustomSliderWidget(
                                    items: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        width: 200,
                                        height: 300,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            //trait gris de séparation
                            Container(
                              width: size.width,
                              height: 10,
                              decoration: BoxDecoration(color: textFieldColor),
                            ),
                          ],
                        ),
                      ),
                      itemCount: 6,
                    ),
                  ),
                ],
              ),
            );
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        // color: buyandbyeAppTheme.white_grey,
                        borderRadius: BorderRadius.circular(20)),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data[index]['imgUrl'],
                                        name: snapshot.data[index]['name'],
                                        colorStore: snapshot.data[index]
                                            ['colorStore'],
                                        description: snapshot.data[index]
                                            ['description'],
                                        adresse: snapshot.data[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data[index]
                                            ['ClickAndCollect'],
                                        livraison: snapshot.data[index]
                                            ['livraison'],
                                        sellerID: snapshot.data[index]['id'],
                                      )));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                snapshot.data!()[index]["imgUrl"],
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(snapshot.data!()[index]['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data!()[index]['description'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        )));
              });
        });
  }
}
