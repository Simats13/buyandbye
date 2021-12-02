import 'dart:async';
import 'package:buyandbye/templates/pages/cart.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates/pages/user_address.dart';
import 'package:buyandbye/templates/widgets/slide_items.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart' as geocoder;

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:buyandbye/templates/pages/pageDetail.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
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

  // Future _future = DatabaseMethods().getCart();
  var currentLocation, position;

  String? currentAddress,
      currentAddressLocation = "",
      streetNumber,
      street,
      city,
      zipCode,
      idAddress,
      userid;
  double latitude = 0, longitude = 0, currentLatitude = 0, currentLongitude = 0;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;
  final controller = TextEditingController();
  final serviceEnabled = Geolocator.isLocationServiceEnabled();

  @override
  void initState() {
    super.initState();
    _determinePermission();
    getCoordinates();
    userinfo();
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
            _locationData.latitude!, _locationData.longitude!);
    var first = addresses.first;

    setState(() {
      //Latitude de l'utilisateur via la localisation
      currentLatitude = _locationData.latitude ?? 0;
      //Longitude de l'utilisateur via la localisation
      currentLongitude = _locationData.longitude ?? 0;
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

  String? username;
  userinfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    QuerySnapshot appBarUser = await DatabaseMethods().getMyInfo(userid);
    username = "${appBarUser.docs[0]['fname']}" + ' ' + '👋';
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    positionCheck();

    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: CupertinoSliverNavigationBar(
                middle: Container(
                  height: 45,
                  width: MediaQuery.of(context).size.width - 70,
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: BuyandByeAppTheme.orangeMiFonce),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 40,
                          // width: size.width - 150,
                          child: InkWell(
                            onTapCancel: () {
                              Navigator.of(context).pop();
                            },
                            onTap: () {
                              affichageAddress();
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                currentAddressLocation!,
                                style: TextStyle(fontSize: 13.5),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.only(
                    left: 6,
                    right: 6,
                  ),
                  child: IconButton(
                    icon: Container(
                      child: Center(
                        child: Icon(Icons.shopping_cart,
                            color: BuyandByeAppTheme.orangeMiFonce
                            // size: 22,
                            ),
                      ),
                    ),
                    onPressed: () {
                      affichageCart();
                    },
                  ),
                ),
                largeTitle: RichText(
                  text: TextSpan(
                    // style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      TextSpan(
                          text: 'Bienvenue ',
                          style: TextStyle(
                            fontSize: 25,
                            color: BuyandByeAppTheme.orangeMiFonce,
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(
                        text: username,
                        style: TextStyle(
                          fontSize: 23,
                          color: BuyandByeAppTheme.black_electrik,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: StreamBuilder(
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              );
            }
            if (snapshot.data!.length > 0) {
              return ListView(
                padding: EdgeInsets.all(0.0),
                children: [
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Slider bons plans
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
                          "Des bons plans à $city  🤲",
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

                      // Slider près de chez vous
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

                      // Slider plus à découvrir
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
                      //trait gris de séparation
                      Container(
                        width: size.width,
                        height: 10,
                        decoration: BoxDecoration(color: textFieldColor),
                      ),
                      SizedBox(
                        height: 15,
                      ),

                      // Slider favoris
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText2,
                            children: [
                              TextSpan(
                                text: 'Mes magasins préférés',
                                style: customTitle,
                              ),
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: SliderFavorite(latitude, longitude, userid),
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
                      // Container(
                      //   width: size.width,
                      //   height: 10,
                      //   decoration: BoxDecoration(color: textFieldColor),
                      // ),
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
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       margin: EdgeInsets.only(left: 15),
                      //       height: 45,
                      //       width: size.width - 70,
                      //       decoration: BoxDecoration(
                      //         color: textFieldColor,
                      //         borderRadius: BorderRadius.circular(30),
                      //       ),
                      //       child: Row(
                      //         mainAxisAlignment:
                      //             MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Padding(
                      //             padding: EdgeInsets.all(12),
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.location_on,
                      //                 ),
                      //                 SizedBox(
                      //                   width: 5,
                      //                 ),
                      //                 SizedBox(
                      //                   height: 30,
                      //                   width: size.width - 150,
                      //                   child: InkWell(
                      //                     onTap: () async {
                      //                       // permissionChecked =
                      //                       //     await _determinePermission();

                      //                       affichageAddress();
                      //                     },
                      //                     child: Container(
                      //                       width: size.width - 150,
                      //                       padding:
                      //                           EdgeInsets.only(top: 5),
                      //                       child: Text(
                      //                         _currentAddressLocation,
                      //                         textAlign: TextAlign.left,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
          },
        ),
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
    showGeneralDialog(
      barrierLabel: "Panier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(minHeight: 325, maxHeight: 900),
            margin: EdgeInsets.only(top: 100, left: 12, right: 12),
            child: CartPage(),
          ),
        );
      },
    );
  }

  void affichageAddress() {
    Size size = MediaQuery.of(context).size;
    showGeneralDialog(
        barrierLabel: "Adresse",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 400),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(minHeight: size.height / 2.5, maxHeight: 600),
                margin: EdgeInsets.only(top: 100, left: 12, right: 12),
                child: UserAddress(),
              ));
        });
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
  bool? loved;

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
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                      img: documents[index]["imgUrl"],
                      name: documents[index]["name"],
                      address: documents[index]["adresse"],
                      description: documents[index]["description"],
                      livraison: documents[index]["livraison"],
                      sellerID: documents[index]["id"],
                      colorStore: documents[index]["colorStore"],
                      clickAndCollect: documents[index]["ClickAndCollect"],
                      mainCategorie: [],
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
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                      img: documents[index]["imgUrl"],
                      name: documents[index]["name"],
                      address: documents[index]["adresse"],
                      description: documents[index]["description"],
                      livraison: documents[index]["livraison"],
                      sellerID: documents[index]["id"],
                      colorStore: documents[index]["colorStore"],
                      clickAndCollect: documents[index]["ClickAndCollect"],
                      mainCategorie: [],
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
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                      img: documents[index]["imgUrl"],
                      name: documents[index]["name"],
                      address: documents[index]["adresse"],
                      description: documents[index]["description"],
                      livraison: documents[index]["livraison"],
                      sellerID: documents[index]["id"],
                      colorStore: documents[index]["colorStore"],
                      clickAndCollect: documents[index]["ClickAndCollect"],
                      mainCategorie: [],
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
class SliderFavorite extends StatefulWidget {
  SliderFavorite(
    this.latitude,
    this.longitude,
    this.userID,
  );
  double latitude;
  double longitude;
  String? userID;
  @override
  _SliderFavoriteState createState() => _SliderFavoriteState();
}

class _SliderFavoriteState extends State<SliderFavorite> {
  var currentLocation;
  var position;
  Geoflutterfire? geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      geo = Geoflutterfire();
      GeoFirePoint center =
          geo!.point(latitude: widget.latitude, longitude: widget.longitude);
      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userID)
            .collection('liked');
        return geo!.collection(collectionRef: collectionReference).within(
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
          final documents = snapshot.data!..shuffle();
          if (documents.length > 0) {
            return Container(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SlideItem(
                        img: documents[index]["imgUrl"],
                        name: documents[index]["name"],
                        address: documents[index]["adresse"],
                        description: documents[index]["description"],
                        livraison: documents[index]["livraison"],
                        sellerID: documents[index]["id"],
                        colorStore: documents[index]["colorStore"],
                        clickAndCollect: documents[index]["ClickAndCollect"],
                        mainCategorie: documents[index]["mainCategorie"]),
                  );
                },
              ),
            );
          } else {
            return Container(
              child: Center(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Vous n'avez aucun magasin en favoris. Ajoutez en depuis leur vitrine",
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
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            List shopImages = listImages(documents);
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
                                        img: documents[carouselItem]['imgUrl'],
                                        colorStore: documents[carouselItem]
                                            ['colorStore'],
                                        name: documents[carouselItem]['name'],
                                        description: documents[carouselItem]
                                            ['description'],
                                        adresse: documents[carouselItem]
                                            ['adresse'],
                                        clickAndCollect: documents[carouselItem]
                                            ['ClickAndCollect'],
                                        livraison: documents[carouselItem]
                                            ['livraison'],
                                        sellerID: documents[carouselItem]['id'],
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
                                    child: Text(documents[carouselItem]["name"],
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
                            // Container(
                            //   width: size.width,
                            //   height: 10,
                            //   decoration: BoxDecoration(color: textFieldColor),
                            // ),
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
