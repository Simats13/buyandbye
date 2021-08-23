import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oficihome/helperfun/sharedpref_helper.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/Pages/cart.dart';
import 'package:oficihome/templates/Pages/pageAddressEdit.dart';
import 'package:oficihome/templates/Pages/pageAddressNext.dart';
import 'package:oficihome/templates/Widgets/loader.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/templates/pages/pageDetail.dart';
import 'package:oficihome/theme/colors.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:oficihome/theme/styles.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/widgets/custom_slider.dart';
import 'package:oficihome/templates/Pages/address_search.dart';
import 'package:oficihome/templates/Pages/place_service.dart';
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

  // Future _future = DatabaseMethods().getCart();
  var currentLocation;
  var position;
  String _currentAddress;
  String _currentAddressLocation = "";
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street;
  String _city = '';
  // ignore: unused_field
  String _zipCode = '';
  double longitude = 0;
  double latitude = 0;
  double currentLatitude;
  double currentLongitude;

  @override
  void initState() {
    super.initState();
    userID();

    _getLocation();
    //FONCTION PERMETTANT DE RECUPERER LES COORDONNEES GPS DE L'UTILISATEUR
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
      });
    });

    //FONCTION PERMETTANT DE RECUPERER LES MAGASINS ET DE LES AFFICHER EN FONCTION DE LA POSITION DE L'UTLISATEUR
    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        position = value;

        if (latitude == 0 && longitude == 0) {
          latitude = position.latitude;
          longitude = position.longitude;
        }
        geo = Geoflutterfire();
        GeoFirePoint center =
            geo.point(latitude: latitude, longitude: longitude);
        stream = radius.switchMap((rad) {
          var collectionReference =
              FirebaseFirestore.instance.collection('magasins');
          return geo.collection(collectionRef: collectionReference).within(
              center: center, radius: 10, field: 'position', strictMode: true);
        });
      });
    });
  }

//FONCTION PERMETTANT DE RECUPERER L'ADRESSE POSTALE VIA LES COORDONNEES GPS DU TEL UTILISATEUR
  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final coordinates =
        new geocode.Coordinates(position.latitude, position.longitude);
    var addresses =
        await geocode.Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    setState(() {
      _currentAddress = "${first.featureName}, ${first.locality}";
    });
  }

  userID() async {
    final User user = await AuthMethods().getCurrentUser();
    latitude = await SharedPreferenceHelper().getUserLatitude() ?? 0.0;
    longitude = await SharedPreferenceHelper().getUserLongitude() ?? 0.0;
    _currentAddressLocation =
        await SharedPreferenceHelper().getUserAddress() ?? "";
    userid = user.uid;
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

          if (!snapshot.hasData) return Container();

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
                      // ...List.generate(menu.length, (index) {
                      //   return Padding(
                      //     padding: const EdgeInsets.only(right: 15.0),
                      //     child: GestureDetector(
                      //       onTap: () {
                      //         setState(() {
                      //           activeMenu = index;
                      //         });
                      //       },
                      //       child: activeMenu == index
                      //           ? ElasticIn(
                      //               child: Container(
                      //                 decoration: BoxDecoration(
                      //                   color: OficihomeAppTheme.orange,
                      //                   borderRadius: BorderRadius.circular(30),
                      //                 ),
                      //                 child: Padding(
                      //                   padding: EdgeInsets.only(
                      //                     left: 15,
                      //                     right: 15,
                      //                     bottom: 8,
                      //                     top: 8,
                      //                   ),
                      //                   child: Row(
                      //                     children: [
                      //                       Text(
                      //                         menu[index],
                      //                         style: TextStyle(
                      //                           fontSize: 16.0,
                      //                           fontWeight: FontWeight.w500,
                      //                         ),
                      //                       )
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ),
                      //             )
                      //           : Container(
                      //               decoration: BoxDecoration(
                      //                 color: Colors.transparent,
                      //                 borderRadius: BorderRadius.circular(30),
                      //               ),
                      //               child: Padding(
                      //                 padding: EdgeInsets.only(
                      //                   left: 15,
                      //                   right: 15,
                      //                   bottom: 8,
                      //                   top: 8,
                      //                 ),
                      //                 child: Row(
                      //                   children: [
                      //                     Text(
                      //                       menu[index],
                      //                       style: TextStyle(
                      //                         fontSize: 16.0,
                      //                         fontWeight: FontWeight.w500,
                      //                       ),
                      //                     )
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //     ),
                      //   );
                      // }),
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

                    Text("     Les Bons Plans du moment", style: customTitle),
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
                    Text(
                      "     Près de chez vous",
                      style: customTitle,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: CustomSliderWidget(
                        items: [SliderAccueil2(latitude, longitude)],
                      ),
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
                    Text("     Plus à Découvrir", style: customTitle),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: CustomSliderWidget(
                        items: [SliderAccueil3(latitude, longitude)],
                      ),
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
                    Text(
                      "    Vous avez acheté chez eux récemment",
                      style: customTitle,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: CustomSliderWidget(
                        items: [SliderAccueil4()],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: size.width,
                      height: 10,
                      decoration: BoxDecoration(color: textFieldColor),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    isVisible
                        ? Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              child: Container(
                                height: 50,
                                width: 210,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: OficihomeAppTheme.black_electrik),
                                child: Text(
                                  "Afficher tous les commerçants",
                                  style: TextStyle(color: white),
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          )
                        : Column(children: [
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
                            AllStores(),
                          ]),
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
                                        child: InkWell(onTap: () async {
                                          affichageAddress();
                                        }),
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
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Aucun commerce n'est disponible pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                          style: TextStyle(
                            fontSize: 18,
                            // color: Colors.grey[700]
                          ),
                          textAlign: TextAlign.center,
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
                                  "$_streetNumber $_street ";
                            });

                            final query = "$_streetNumber $_street , $_city";

                            var addresses = await geocode.Geocoder.local
                                .findAddressesFromQuery(query);
                            var first = addresses.first;

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
                            Icon(Icons.search),
                            Text(
                              "Saisir une nouvelle adresse",
                              textAlign: TextAlign.left,
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
                          child: Text("Proche de vous"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 50,
                          child: InkWell(
                            onTap: () async {
                              // affichageAdresse(latitude, longitude, adresseEntire);

                              setState(() {
                                _currentAddressLocation = _currentAddress;
                              });

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageAddressNext(
                                            lat: position.latitude,
                                            long: position.longitude,
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
                                        Text(_currentAddress)
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
                          child: Text("Mes adresses enregistrées"),
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
                        if (snapshot.hasData) {
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              latitude = snapshot
                                                  .data.docs[index]["latitude"];
                                              longitude = snapshot.data
                                                  .docs[index]["longitude"];
                                              _currentAddressLocation = snapshot
                                                  .data.docs[index]["address"];

                                              print(position);

                                              geo = Geoflutterfire();
                                              GeoFirePoint center = geo.point(
                                                  latitude: snapshot.data
                                                      .docs[index]["latitude"],
                                                  longitude:
                                                      snapshot.data.docs[index]
                                                          ["longitude"]);
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
                                                await SharedPreferences
                                                    .getInstance();

                                            await _preferences.setDouble(
                                                _keyLatitude,
                                                snapshot.data.docs[index]
                                                    ["latitude"]);

                                            await _preferences.setDouble(
                                                _keyLongitude,
                                                snapshot.data.docs[index]
                                                    ["longitude"]);

                                            await _preferences.setString(
                                                _keyAddress,
                                                snapshot.data.docs[index]
                                                    ["address"]);

                                            SharedPreferenceHelper()
                                                .saveUserAddress(snapshot.data
                                                    .docs[index]["address"]);

                                            SharedPreferenceHelper()
                                                .saveUserLatitude(snapshot.data
                                                    .docs[index]["latitude"]);

                                            SharedPreferenceHelper()
                                                .saveUserLongitude(snapshot.data
                                                    .docs[index]["longitude"]);

                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.place_rounded),
                                              SizedBox(width: 10),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 30),
                                                    Container(
                                                      child: Text(
                                                        snapshot.data
                                                                .docs[index]
                                                            ["addressName"],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(truncate(
                                                          snapshot.data
                                                                  .docs[index]
                                                              ["address"],
                                                          35,
                                                          omission: "...",
                                                          position:
                                                              TruncatePosition
                                                                  .end)),
                                                    ),
                                                    SizedBox(height: 30),
                                                  ]),
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
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        } else {
                          return Container(
                              child: Text("Pas d'adresses enregistrées"));
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
    //FONCTION PERMETTANT DE RECUPERER LES COORDONNEES GPS DE L'UTILISATEUR
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
      });
    });

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
            return PageView.builder(
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
                                        adresse: documents[index]['adresse'],
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
                });
          } else {
            return Container(
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
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Aucun commerce n'est disponible pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                      style: TextStyle(
                        fontSize: 18,
                        // color: Colors.grey[700]
                      ),
                      textAlign: TextAlign.center,
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
            return PageView.builder(
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
                                          adresse: documents[index]['adresse'],
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
                                image: NetworkImage(documents[index]['imgUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )));
                });
          } else {
            return Container(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/splash_2.png',
                    width: 50,
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Aucun commerce n'est disponible pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                      style: TextStyle(
                        fontSize: 18,
                        // color: Colors.grey[700]
                      ),
                      textAlign: TextAlign.center,
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
          return PageView.builder(
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
                                        adresse: documents[index]['adresse'],
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
                              image: NetworkImage(documents[index]['imgUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )));
              });
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
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
      });
    });

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
                        // color: OficihomeAppTheme.white_grey,
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
