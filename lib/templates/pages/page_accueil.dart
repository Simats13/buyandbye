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

import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:buyandbye/templates/pages/page_detail.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:buyandbye/theme/styles.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/widgets/custom_slider.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({Key? key}) : super(key: key);

  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  Location location = Location();
  late bool permissionChecked;
  bool chargementChecked = false;

  String? currentLocationAddress, currentAddress = "", locationCity, streetNumber, street, city, zipCode, idAddress, userid;
  double latitude = 0, longitude = 0, currentLocationLatitude = 0, currentLocationLongitude = 0;
  late GeoFlutterFire geo;
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

  String _textReplace(String str) {
    str = str.replaceAll('Avenue', 'Av');
    str = str.replaceAll('Boulevard', 'Bd');
    str = str.replaceAll('Chemin', 'Ch');
    str = str.replaceAll('Impasse', 'Imp');
    return str;
  }

  //Fonction permettant de determiner si l'utilisateur a accepté la localisation ou non
  //S'il n'a pas accepté alors cela renvoit false
  //S'il a accepté alors ça renvoie la localisation périodiquement
  Future<bool> _determinePermission() async {
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

    return true;
  }

  getCoordinates() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getChosenAddress(userid);
    latitude = double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");
    List<geocoder.Placemark> addresses = await geocoder.placemarkFromCoordinates(latitude, longitude);

    var first = addresses.first;
    currentAddress = "${first.name}, ${first.locality}";
    currentAddress = _textReplace(currentAddress!);
    idAddress = "${querySnapshot.docs[0]['idDoc']}";
    city = "${first.locality}";
    chargementChecked = true;
    setState(() {});
  }

  positionCheck() async {
    final geo = GeoFlutterFire();
    GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
    stream = radius.switchMap((rad) {
      var collectionReference = FirebaseFirestore.instance.collection('magasins');

      return geo.collection(collectionRef: collectionReference).within(center: center, radius: 10, field: 'position', strictMode: true);
    });
  }

  userinfo() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    positionCheck();

    return chargementChecked
        ? CupertinoPageScaffold(
            child: StreamBuilder<dynamic>(
              stream: ProviderUserInfo().returnData(),
              builder: (context, snapshot) {
                return NestedScrollView(
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
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: BuyandByeAppTheme.orangeMiFonce),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: InkWell(
                                      onTapCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                      onTap: () {
                                        affichageAddress();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          currentAddress!,
                                          style: const TextStyle(fontSize: 13.5),
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
                            padding: const EdgeInsets.only(
                              left: 6,
                              right: 6,
                            ),
                            child: IconButton(
                              icon: const Center(
                                child: Icon(Icons.shopping_cart, color: BuyandByeAppTheme.orangeMiFonce
                                    // size: 22,
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
                                const TextSpan(
                                    text: 'Bienvenue ',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: BuyandByeAppTheme.orangeMiFonce,
                                      fontWeight: FontWeight.bold,
                                    )),
                                TextSpan(
                                  text: snapshot.hasData ? snapshot.data['fname'] + " 👋" : "",
                                  style: const TextStyle(
                                    fontSize: 23,
                                    color: BuyandByeAppTheme.blackElectrik,
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
                    builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
            
                      if (!snapshot.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ColorLoader3(
                                radius: 15.0,
                                dotRadius: 6.0,
                              ),
                              Text("Chargement, veuillez patienter"),
                            ],
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: ColorLoader3(
                            radius: 15.0,
                            dotRadius: 6.0,
                          ),
                        );
                      }
                      if (snapshot.data!.isNotEmpty) {
                        return ListView(
                          padding: const EdgeInsets.all(0.0),
                          children: [
                            const SizedBox(height: 10),
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
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  child: SliderAccueil1(latitude, longitude),
                                ),
            
                                const Center(
                                    child: Text(
                                  "Sponsorisé",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.00),
                                )),
                                const SizedBox(
                                  height: 15,
                                ),
            
                                //trait gris de séparation
                                Container(
                                  width: size.width,
                                  height: 10,
                                  decoration: BoxDecoration(color: textFieldColor),
                                ),
                                const SizedBox(
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
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: Text(
                                    "-3km 📍",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  child: SliderAccueil2(latitude, longitude),
                                ),
                                //trait gris de séparation
                                Container(
                                  width: size.width,
                                  height: 10,
                                  decoration: BoxDecoration(color: textFieldColor),
                                ),
                                const SizedBox(
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
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                  child: Text(
                                    "-10km 🗺️",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  child: SliderAccueil3(latitude, longitude),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                //trait gris de séparation
                                Container(
                                  width: size.width,
                                  height: 10,
                                  decoration: BoxDecoration(color: textFieldColor),
                                ),
                                const SizedBox(
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
                                        const WidgetSpan(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                                  padding: const EdgeInsets.all(20),
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
            
                                const SizedBox(
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
                              children: const [
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                            Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/splash_2.png',
                                  width: 300,
                                  height: 300,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
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
                          ],
                        );
                      }
                    },
                  ),
                );
              }
            ),
          )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
              Text("Chargement, veuillez patienter"),
            ],
          ));
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
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(minHeight: 325, maxHeight: 900),
            margin: const EdgeInsets.only(top: 100, left: 12, right: 12),
            child: const CartPage(),
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
        transitionDuration: const Duration(milliseconds: 400),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: BoxConstraints(minHeight: size.height / 2.5, maxHeight: 600),
                margin: const EdgeInsets.only(top: 100, left: 12, right: 12),
                child: const UserAddress(),
              ));
        });
  }
}

class Geoflutterfire {}

// ignore: must_be_immutable
class SliderAccueil1 extends StatefulWidget {
  SliderAccueil1(this.latitude, this.longitude, {Key? key}) : super(key: key);
  double? latitude;
  double? longitude;
  @override
  _SliderAccueil1State createState() => _SliderAccueil1State();
}
//BON PLANS

class _SliderAccueil1State extends State<SliderAccueil1> {
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;
  bool? loved;

  @override
  void initState() {
    super.initState();

    //FONCTION PERMETTANT DE RECUPERER LES MAGASINS ET DE LES AFFICHER EN FONCTION DE LA POSITION DE L'UTLISATEUR

    setState(() {
      final geo = GeoFlutterFire();
      GeoFirePoint center = geo.point(latitude: widget.latitude!, longitude: widget.longitude!);
      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance.collection('magasins').where("sponsored", isEqualTo: true);
        return geo.collection(collectionRef: collectionReference).within(center: center, radius: 10, field: 'position', strictMode: true);
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
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
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return SizedBox(
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
                      horairesOuverture: documents[index]["horairesOuverture"],
                      colorStore: documents[index]["colorStore"],
                      clickAndCollect: documents[index]["ClickAndCollect"],
                      mainCategorie: documents[index]["mainCategorie"],
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
                child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/splash_2.png',
                  width: 50,
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
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
            ));
          }
        });
  }
}

// ignore: must_be_immutable
class SliderAccueil2 extends StatefulWidget {
  SliderAccueil2(this.latitude, this.longitude, {Key? key}) : super(key: key);
  double? latitude;
  double? longitude;
  @override
  _SliderAccueil2State createState() => _SliderAccueil2State();
}

//PRES DE CHEZ VOUS
class _SliderAccueil2State extends State<SliderAccueil2> {
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      final geo = GeoFlutterFire();
      GeoFirePoint center = geo.point(latitude: widget.latitude!, longitude: widget.longitude!);
      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(center: center, radius: 3, field: 'position', strictMode: true);
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
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
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return SizedBox(
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
                      horairesOuverture: documents[index]["horairesOuverture"],
                      colorStore: documents[index]["colorStore"],
                      clickAndCollect: documents[index]["ClickAndCollect"],
                      mainCategorie: const [],
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
                child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/splash_2.png',
                  width: 50,
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
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
            ));
          }
        });
  }
}

// ignore: must_be_immutable
class SliderAccueil3 extends StatefulWidget {
  SliderAccueil3(this.latitude, this.longitude, {Key? key}) : super(key: key);
  double? latitude;
  double? longitude;
  @override
  _SliderAccueil3State createState() => _SliderAccueil3State();
}

class _SliderAccueil3State extends State<SliderAccueil3> {
  // late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    setState(() {
      final geo = GeoFlutterFire();
      GeoFirePoint center = geo.point(latitude: widget.latitude!, longitude: widget.longitude!);
      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(center: center, radius: 10, field: 'position', strictMode: true);
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
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
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          final documents = snapshot.data..shuffle();
          if (documents.length > 0) {
            return SizedBox(
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
                      horairesOuverture: documents[index]["horairesOuverture"],
                      colorStore: documents[index]["colorStore"],
                      clickAndCollect: documents[index]["ClickAndCollect"],
                      mainCategorie: const [],
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
                child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/splash_2.png',
                  width: 50,
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
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
            ));
          }
        });
  }
}

// ignore: must_be_immutable
class SliderFavorite extends StatefulWidget {
  SliderFavorite(this.latitude, this.longitude, this.userID, {Key? key}) : super(key: key);
  double latitude;
  double longitude;
  String? userID;
  @override
  _SliderFavoriteState createState() => _SliderFavoriteState();
}

class _SliderFavoriteState extends State<SliderFavorite> {
  Geoflutterfire? geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;
  final lovedId = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      final geo = GeoFlutterFire();
      GeoFirePoint center = geo.point(latitude: widget.latitude, longitude: widget.longitude);
      stream = radius.switchMap((rad) {
        Query collectionReference = FirebaseFirestore.instance.collection('users').doc(widget.userID).collection('loved');
        return geo.collection(collectionRef: collectionReference).within(center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  int carouselItem = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot1) {
          if (!snapshot1.hasData) {
            return Shimmer.fromColors(
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
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            );
          }
          // Les éléments sont mélangés à chaque mouvement du carousel
          if (snapshot1.data.length > 0) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 2.4,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: snapshot1.data.length,
                itemBuilder: (context, index) {
                  return StreamBuilder<dynamic>(
                      stream: FirebaseFirestore.instance.collection('magasins').doc(snapshot1.data[index]["id"]).snapshots(),
                      builder: (context, snapshot2) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SlideItem(
                              img: snapshot2.data["imgUrl"],
                              name: snapshot2.data["name"],
                              address: snapshot2.data["adresse"],
                              description: snapshot2.data["description"],
                              livraison: snapshot2.data["livraison"],
                              sellerID: snapshot2.data["id"],
                              horairesOuverture: snapshot2.data["horairesOuverture"],
                              colorStore: snapshot2.data["colorStore"],
                              clickAndCollect: snapshot2.data["ClickAndCollect"],
                              mainCategorie: snapshot2.data["mainCategorie"]),
                        );
                      });
                },
              ),
            );
          } else {
            return Center(
                child: Column(
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
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
            ));
          }
        });
  }
}

class SliderAccueil4 extends StatefulWidget {
  const SliderAccueil4({Key? key}) : super(key: key);

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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: DatabaseMethods().getStoreInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
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
                                colorStore: documents[carouselItem]['colorStore'],
                                name: documents[carouselItem]['name'],
                                description: documents[carouselItem]['description'],
                                adresse: documents[carouselItem]['adresse'],
                                clickAndCollect: documents[carouselItem]['ClickAndCollect'],
                                livraison: documents[carouselItem]['livraison'],
                                sellerID: documents[carouselItem]['id'],
                                horairesOuverture: snapshot.data[carouselItem]['horairesOuverture'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4, offset: Offset(4, 4))]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height / 10,
                                  child: Image.network(i),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 10, top: 40),
                                    child: Text(documents[carouselItem]["name"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                              ],
                            )));
                  });
                }).toList());
          } else {
            return Center(
                child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/splash_2.png',
                  width: 50,
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
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
            ));
          }
        });
  }
}

class AllStores extends StatefulWidget {
  const AllStores({Key? key}) : super(key: key);

  @override
  _AllStoresState createState() => _AllStoresState();
}

class _AllStoresState extends State<AllStores> {
  late Position position;
  late Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;

  @override
  void initState() {
    super.initState();

    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        position = value;
        final geo = GeoFlutterFire();
        GeoFirePoint center = geo.point(latitude: position.latitude, longitude: position.longitude);
        stream = radius.switchMap((rad) {
          var collectionReference = FirebaseFirestore.instance.collection('magasins');
          return geo.collection(collectionRef: collectionReference).within(center: center, radius: 50, field: 'position', strictMode: true);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<dynamic>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 15),
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
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 30,
                                          width: size.width - 150,
                                          child: InkWell(
                                            onTap: () async {},
                                            child: Container(
                                              width: size.width - 150,
                                              padding: const EdgeInsets.only(top: 5),
                                              child: const SizedBox(
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
                      const SizedBox(
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

                                const SizedBox(
                                  height: 15,
                                ),

                                Expanded(
                                  child: CustomSliderWidget(
                                    items: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        width: 200,
                                        height: 300,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
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
          }
          return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: const EdgeInsets.all(15),
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
                                        colorStore: snapshot.data[index]['colorStore'],
                                        description: snapshot.data[index]['description'],
                                        adresse: snapshot.data[index]['adresse'],
                                        clickAndCollect: snapshot.data[index]['ClickAndCollect'],
                                        livraison: snapshot.data[index]['livraison'],
                                        sellerID: snapshot.data[index]['id'],
                                        horairesOuverture: snapshot.data[index]['horairesOuverture'],
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
                            const SizedBox(
                              height: 15,
                            ),
                            Text(snapshot.data[index]['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data[index]['description'],
                                textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        )));
              });
        });
  }
}
