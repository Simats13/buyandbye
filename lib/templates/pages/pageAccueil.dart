import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:buyandbye/templates/pages/address_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Pages/cart.dart';
import 'package:buyandbye/templates/Pages/pageAddressEdit.dart';
import 'package:buyandbye/templates/Pages/pageAddressNext.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates/pages/pageDetail.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:buyandbye/theme/styles.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/widgets/custom_slider.dart';

import 'package:buyandbye/templates/Pages/place_service.dart';
import 'package:truncate/truncate.dart';
import 'package:uuid/uuid.dart';

class PageAccueil extends StatefulWidget {
  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  int activeMenu = 0;
  bool isVisible = true;
  bool near = false;

  String userid;

  // INITIALISATION DE SHARE_PREFERENCES (PERMET DE GARDER EN MEMOIRE DES INFORMATIONS, ICI LA LONGITUDE ET LA LATITUDE)
  static SharedPreferences _preferences;
  static const _keyLatitude = "UserLatitudeKey";
  static const _keyLongitude = "UserLongitudeKey";
  static const _keyAddress = "UserAddressKey";
  static const _keyCity = "UserCityKey";

  // Future _future = DatabaseMethods().getCart();
  var currentLocation;
  var position;
  String _currentAddress = "";
  String _currentAddressLocation = "";
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street;
  String _city;
  // ignore: unused_field
  String _zipCode = '';
  double longitude = 0;
  double latitude = 0;
  double currentLatitude;
  double currentLongitude;
  LocationPermission permission;
  bool locationEnabled = false;
  @override
  void initState() {
    super.initState();
    userID();
    _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        locationEnabled = false;
      });
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationEnabled = false;
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationEnabled = false;
      });

      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    setState(() {
      locationEnabled = true;
    });

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  userID() async {
    final User user = await AuthMethods().getCurrentUser();

    if (locationEnabled == false) {
      latitude = await SharedPreferenceHelper().getUserLatitude() ?? 43.834647;
      longitude = await SharedPreferenceHelper().getUserLongitude() ?? 4.359620;
      _currentAddressLocation =
          await SharedPreferenceHelper().getUserAddress() ?? "Arènes de Nîmes";

      _city = await SharedPreferenceHelper().getUserCity() ?? "Nîmes";
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final coordinates =
          new geocode.Coordinates(position.latitude, position.longitude);
      var addresses = await geocode.Geocoder.local
          .findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      latitude =
          await SharedPreferenceHelper().getUserLatitude() ?? position.latitude;
      longitude = await SharedPreferenceHelper().getUserLongitude() ??
          position.longitude;

      _currentAddress = "${first.featureName}, ${first.locality}";
      _currentAddressLocation =
          await SharedPreferenceHelper().getUserAddress() ??
              "${first.featureName}, ${first.locality}";

      _city =
          await SharedPreferenceHelper().getUserCity() ?? "${first.locality}";
    }

    userid = user.uid;

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
      stream = radius.switchMap((rad) {
        var collectionReference =
            FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
            );
          }

          if (!snapshot.hasData) return CupertinoActivityIndicator();

          if (snapshot.data.length > 0) {
            return ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 70,
                        decoration: BoxDecoration(
                          color: textFieldColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  if (_currentAddress != null)
                                    SizedBox(
                                      height: 30,
                                      width: size.width - 150,
                                      child: InkWell(
                                        onTap: () async {
                                          affichageAddress();
                                        },
                                        child: Container(
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
                      ])
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
                      child: CustomSliderWidget(
                        items: [SliderAccueil1(latitude, longitude)],
                      ),
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

                    //trait gris de séparation rajouté après avoir désactivé le code au dessus.
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

                    //trait gris de séparation rajouté après avoir désactivé le code au dessus.
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
                    //   child: CustomSliderWidget(
                    //     items: [SliderAccueil4()],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Container(
                      width: size.width,
                      height: 10,
                      decoration: BoxDecoration(color: textFieldColor),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          affichageAllStores();
                        },
                        child: Container(
                          height: 50,
                          width: 210,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: BuyandByeAppTheme.black_electrik),
                          child: Text(
                            "Afficher tous les commerçants",
                            style: TextStyle(color: white),
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    if (_currentAddress != null)
                                      SizedBox(
                                        height: 30,
                                        width: size.width - 150,
                                        child: InkWell(
                                          onTap: () async {
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
        });
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                    child: SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 50,
                      child: InkWell(
                        onTap: () async {
                          // generate a new token here
                          final sessionToken = Uuid().v4();
                          final Suggestion result = await showSearch(
                            context: context,
                            delegate: AddressSearch(sessionToken),
                          );
                          // This will change the text displayed in the TextField
                          if (result != null) {
                            final placeDetails =
                                await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(result.placeId);

                            setState(() {
                              _controller.text = result.description;
                              _streetNumber = placeDetails.streetNumber;
                              _street = placeDetails.street;
                              _city = placeDetails.city;
                              _zipCode = placeDetails.zipCode;
                              _currentAddressLocation =
                                  "$_streetNumber $_street, $_city ";
                            });

                            final query = "$_streetNumber $_street , $_city";

                            var addresses = await geocode.Geocoder.local
                                .findAddressesFromQuery(query);
                            var first = addresses.first;

                            Navigator.of(context).pop();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PageAddressNext(
                                          lat: first.coordinates.latitude,
                                          long: first.coordinates.longitude,
                                          adresse: first.addressLine,
                                        )));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.15),
                          ),
                          padding: EdgeInsets.only(top: 5),
                          child: Row(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                  locationEnabled
                      ? Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 50,
                                child: InkWell(
                                  onTap: () async {
                                    Position position =
                                        await Geolocator.getCurrentPosition(
                                            desiredAccuracy:
                                                LocationAccuracy.high);
                                    final coordinates = new geocode.Coordinates(
                                        position.latitude, position.longitude);
                                    var addresses = await geocode.Geocoder.local
                                        .findAddressesFromCoordinates(
                                            coordinates);
                                    var first = addresses.first;

                                    setState(() {
                                      _city = first.locality;
                                      latitude = position.latitude;
                                      longitude = position.longitude;
                                      _currentAddressLocation =
                                          "${first.featureName + ", " + first.locality}";

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
                                        _keyLatitude, position.latitude);

                                    await _preferences.setDouble(
                                        _keyLongitude, position.longitude);

                                    await _preferences.setString(
                                        _keyAddress, _currentAddressLocation);

                                    await _preferences.setString(
                                        _keyCity, _city);

                                    SharedPreferenceHelper()
                                        .saveUserCity(_city);

                                    SharedPreferenceHelper().saveUserAddress(
                                        _currentAddressLocation);

                                    SharedPreferenceHelper()
                                        .saveUserLatitude(position.latitude);

                                    SharedPreferenceHelper()
                                        .saveUserLongitude(position.longitude);

                                    Navigator.of(context).pop();

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PageAddressNext(
                                                  lat: position.latitude,
                                                  long: position.longitude,
                                                  adresse:
                                                      _currentAddressLocation,
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
                                              Text(_currentAddressLocation)
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
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // todo : showDialog for ios
                                    return showCupertinoDialog(
                                        context: context,
                                        builder: (_) => CupertinoAlertDialog(
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
                                                  onPressed: () {
                                                    AppSettings
                                                        .openAppSettings();

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
                        if (snapshot.data.docs.length > 0) {
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final coordinates =
                                            new geocode.Coordinates(
                                                snapshot.data.docs[index]
                                                    ["latitude"],
                                                snapshot.data.docs[index]
                                                    ["longitude"]);
                                        var addresses = await geocode
                                            .Geocoder.local
                                            .findAddressesFromCoordinates(
                                                coordinates);
                                        var first = addresses.first;

                                        setState(() {
                                          _city = first.locality;
                                          latitude = snapshot.data.docs[index]
                                              ["latitude"];
                                          longitude = snapshot.data.docs[index]
                                              ["longitude"];
                                          _currentAddressLocation =
                                              "${first.featureName + ", " + first.locality}";

                                          geo = Geoflutterfire();
                                          GeoFirePoint center = geo.point(
                                              latitude: snapshot
                                                  .data.docs[index]["latitude"],
                                              longitude: snapshot.data
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
                                            snapshot.data.docs[index]
                                                ["latitude"]);

                                        await _preferences.setString(
                                            _keyCity, _city);

                                        await _preferences.setDouble(
                                            _keyLongitude,
                                            snapshot.data.docs[index]
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
                                            .saveUserLatitude(snapshot
                                                .data.docs[index]["latitude"]);

                                        SharedPreferenceHelper()
                                            .saveUserLongitude(snapshot
                                                .data.docs[index]["longitude"]);

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
                                                    snapshot.data.docs[index]
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
                                                    child: Text(snapshot
                                                            .data.docs[index]
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
                                                                adresse: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index]
                                                                    ["address"],
                                                                adressTitle: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "addressName"],
                                                                buildingDetails: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "buildingDetails"],
                                                                buildingName: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "buildingName"],
                                                                familyName: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "familyName"],
                                                                lat: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "latitude"],
                                                                long: snapshot
                                                                            .data
                                                                            .docs[
                                                                        index][
                                                                    "longitude"],
                                                                iD: snapshot.data
                                                                            .docs[
                                                                        index]
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
                              Container(
                                  child: Text("Aucun adresses enregistrées")),
                            ],
                          );
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
  double latitude;
  double longitude;
  @override
  _SliderAccueil1State createState() => _SliderAccueil1State();
}
//BON PLANS

class _SliderAccueil1State extends State<SliderAccueil1> {
  var currentLocation;
  var position;
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();

    //FONCTION PERMETTANT DE RECUPERER LES MAGASINS ET DE LES AFFICHER EN FONCTION DE LA POSITION DE L'UTLISATEUR

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo.point(latitude: widget.latitude, longitude: widget.longitude);
      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance
            .collection('magasins')
            .where("sponsored", isEqualTo: true);
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
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
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
            );
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return CustomSliderWidget(
              items: [
                (PageView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageDetail(
                                            img: documents[index]['imgUrl'],
                                            name: documents[index]['name'],
                                            description: documents[index]
                                                ['description'],
                                            adresse: documents[index]
                                                ['adresse'],
                                            clickAndCollect: documents[index]
                                                ['ClickAndCollect'],
                                            livraison: documents[index]
                                                ['livraison'],
                                          )));
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            snapshot.data[index]['imgUrl']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      );
                    }))
              ],
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
  double latitude;
  double longitude;
  @override
  _SliderAccueil2State createState() => _SliderAccueil2State();
}

//PRES DE CHEZ VOUS
class _SliderAccueil2State extends State<SliderAccueil2> {
  var currentLocation;
  var position;
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo.point(latitude: widget.latitude, longitude: widget.longitude);
      stream = radius.switchMap((rad) {
        var collectionReference =
            FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 3, field: 'position', strictMode: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
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
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
            );
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return CustomSliderWidget(
              items: [
                PageView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageDetail(
                                            img: documents[index]['imgUrl'],
                                            name: documents[index]['name'],
                                            description: documents[index]
                                                ['description'],
                                            adresse: documents[index]
                                                ['adresse'],
                                            clickAndCollect: documents[index]
                                                ['ClickAndCollect'],
                                            livraison: documents[index]
                                                ['livraison'],
                                          )));
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(documents[index]['imgUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                      );
                    })
              ],
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
  double latitude;
  double longitude;
  @override
  _SliderAccueil3State createState() => _SliderAccueil3State();
}

class _SliderAccueil3State extends State<SliderAccueil3> {
  var currentLocation;
  var position;
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo.point(latitude: widget.latitude, longitude: widget.longitude);
      stream = radius.switchMap((rad) {
        var collectionReference =
            FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
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
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
            );
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return CustomSliderWidget(
              items: [
                PageView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return Container(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PageDetail(
                                              img: documents[index]['imgUrl'],
                                              name: documents[index]['name'],
                                              description: documents[index]
                                                  ['description'],
                                              adresse: documents[index]
                                                  ['adresse'],
                                              clickAndCollect: documents[index]
                                                  ['ClickAndCollect'],
                                              livraison: documents[index]
                                                  ['livraison'],
                                            )));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        documents[index]['imgUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )));
                    })
              ],
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseMethods().getStoreInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
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
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
            );
          return PageView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return Container(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data.docs[index]
                                            ['imgUrl'],
                                        name: snapshot.data.docs[index]['name'],
                                        description: snapshot.data.docs[index]
                                            ['description'],
                                        adresse: snapshot.data.docs[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data
                                            .docs[index]['ClickAndCollect'],
                                        livraison: snapshot.data.docs[index]
                                            ['livraison'],
                                      )));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                  snapshot.data.docs[index]['imgUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )));
              });
        });
  }
}

class AllStores extends StatefulWidget {
  @override
  _AllStoresState createState() => _AllStoresState();
}

class _AllStoresState extends State<AllStores> {
  var currentLocation;
  var position;
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;

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
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
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
                                        description: snapshot.data[index]
                                            ['description'],
                                        adresse: snapshot.data[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data[index]
                                            ['ClickAndCollect'],
                                        livraison: snapshot.data[index]
                                            ['livraison'],
                                      )));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                snapshot.data[index]["imgUrl"],
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(snapshot.data[index]['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data[index]['description'],
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
