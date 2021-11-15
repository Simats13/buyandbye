import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Pages/pageDetail.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:rxdart/rxdart.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

class PageExplore extends StatefulWidget {
  @override
  _PageExploreState createState() => _PageExploreState();
}

class _PageExploreState extends State<PageExplore> {
  var currentLocation;
  var position;
  var radius = BehaviorSubject<double>.seeded(10);
  Geoflutterfire geo;
  bool mapToggle = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int prevPage;
  LocationPermission permission;
  Stream<List<DocumentSnapshot>> stream;
  BitmapDescriptor mapMaker;
  Set<Marker> _markers = Set<Marker>();

  double _value = 40.0;
  List magasins = [];
  String _label = 'kms';
  bool localisation = false;
  double latitude, longitude;

  // INITIALISATION DE SHARE_PREFERENCES (PERMET DE GARDER EN MEMOIRE DES INFORMATIONS, ICI LA LONGITUDE ET LA LATITUDE)
  static SharedPreferences _preferences;
  static const _keySlider = "UserSliderKey";
  static const _keyLabel = "UserSliderLabelKey";

  // firestore init
  final _firestore = FirebaseFirestore.instance;

  GoogleMapController _mapController;
  PageController _pageController;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    userID();
    setCustomMarker();

    _pageController = PageController(initialPage: 1, viewportFraction: 0.8)
      ..addListener(_onScroll);

    fetchDatabaseList();
  }

  void _onScroll() {
    if (_pageController.page.toInt() != prevPage) {
      prevPage = _pageController.page.toInt();
    }
  }

  fetchDatabaseList() async {
    dynamic result = await DatabaseMethods().getMagasin();
    if (result == null) {
      showAlertDialog(context, "Erreur, veuillez réesayer ultérieurement");
    } else {
      setState(() {
        magasins = result;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;

      stream.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });
      _mapController.setMapStyle(MapStyle.mapStyle);
    });
  }

  void showHome() async {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15.0,
      ),
    ));
  }

  userID() async {
    _value = await SharedPreferenceHelper().getUserSlider() ?? 1.0;
    _label = await SharedPreferenceHelper().getLabelSliderUser() ?? "";
    final User user = await AuthMethods().getCurrentUser();
    var userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getChosenAddress(userid);
    setState(() {
      mapToggle = true;
      geo = Geoflutterfire();

    latitude = double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");
      GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
      stream = radius.switchMap((rad) {
        var collectionReference = _firestore.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: rad, field: 'position', strictMode: true);
      });
    });

    final idMarker = MarkerId(latitude.toString() + longitude.toString());
    _markers.add(Marker(
      markerId: idMarker,
      position: LatLng(latitude, longitude),
      //icon: mapMarker,
    ));

    //String userid = user.uid;
  }

  //FONCTION ALERT PERMETTANT DE MONTRER PLUS D'INFOS SUR LES MAGASINS

  void _magasinAffichage(double lat, double lng, String name, idSeller) {
    slideDialog.showSlideDialog(
      context: context,
      child: FutureBuilder(
          future: DatabaseMethods().getMagasinInfo(idSeller),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              );
            }
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Center(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Image(
                            image: NetworkImage(
                                snapshot.data.docs[index]['imgUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Text("Adresse : " +
                              snapshot.data.docs[index]['adresse']),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Text("Description : " +
                              snapshot.data.docs[index]['description']),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageDetail(
                                            img: snapshot.data.docs[index]
                                                ['imgUrl'],
                                            name: snapshot.data.docs[index]
                                                ['name'],
                                            colorStore: snapshot
                                                .data.docs[index]['colorStore'],
                                            description: snapshot.data
                                                .docs[index]['description'],
                                            adresse: snapshot.data.docs[index]
                                                ['adresse'],
                                            clickAndCollect: snapshot.data
                                                .docs[index]['ClickAndCollect'],
                                            livraison: snapshot.data.docs[index]
                                                ['livraison'],
                                            sellerID: snapshot.data.docs[index]
                                                ['id'],
                                          )));
                            },
                            child: Center(
                              child: Text(
                                "Accéder au magasin",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }

  //FONCTION ALERT PERMETTANT DE MODIFIER LE PERIMETRE DES MARQUEURS
  void _perimeter() async {
    _preferences = await SharedPreferences.getInstance();

    slideDialog.showSlideDialog(
      context: context,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Changer de périmètre",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StatefulBuilder(builder: (context, innerSetState) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Slider(
                  min: 1,
                  max: 200,
                  divisions: 10,
                  value: _value,
                  label: _label,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue.withOpacity(0.2),
                  onChanged: (value) async {
                    innerSetState(() {
                      setState(() {
                        _value = value;

                        _label = '${_value.toInt().toString()} kms';
                        markers.clear();
                      });
                      radius.add(value);
                    });
                    // await _preferences.setString(_keyLabel, _label);
                    // await _preferences.setDouble(_keySlider, _value);
                    _preferences.setDouble(_keySlider, _value);
                    _preferences.setString(_keyLabel, _label);
                  }),
            );
          }),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      height: MediaQuery.of(context).size.height * (1 / 3),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(latitude, longitude), zoom: 15.0),
                        markers: Set<Marker>.of(markers.values),
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/shop.png')
        .then((value) {
      mapMaker = value;
    });
  }

  void _addMarker(double lat, double lng, String name, String idSeller) {
    final id = MarkerId(lat.toString() + lng.toString());
    final _marker = Marker(
        markerId: id,
        position: LatLng(lat, lng),
        icon: mapMaker,
        onTap: () {
          _magasinAffichage(
            lat,
            lng,
            name,
            idSeller,
          );
        });
    setState(() {
      markers[id] = _marker;
    });
  }

  moveCamera(double lat, double lng) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lng), zoom: 14.0, bearing: 45.0, tilt: 45.0)));
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document.get('position')['geopoint'];
      final name = document.get('name');
      final idSeller = document.get('id');
      print("idSeller");
      print(idSeller);
      // final clickAndCollect = document.get('ClickAndCollect');
      // final adresse = document.get('adresse');
      // final description = document.get('description');

      // final livraison = document.get('livraison');
      // final photoUrl = document.get('photoUrl');
      _addMarker(point.latitude, point.longitude, name, idSeller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return mapToggle
        ? Scaffold(
            backgroundColor: BuyandByeAppTheme.white,
            // appBar: PreferredSize(
            //   preferredSize: Size.fromHeight(50.0),
            //   child: AppBar(
            //     title: RichText(
            //       text: TextSpan(
            //         // style: Theme.of(context).textTheme.bodyText2,
            //         children: [
            //           TextSpan(
            //               text: 'Explorer',
            //               style: TextStyle(
            //                 fontSize: 20,
            //                 color: BuyandByeAppTheme.orangeMiFonce,
            //                 fontWeight: FontWeight.bold,
            //               )),
            //           WidgetSpan(
            //             child: Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 5.0),
            //               child: Icon(
            //                 Icons.public,
            //                 color: BuyandByeAppTheme.orangeFonce,
            //                 size: 30,
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     // actions: <Widget>[
            //     //   IconButton(
            //     //     icon: Icon(
            //     //       Icons.add_location_outlined,
            //     //       color: BuyandByeAppTheme.orange,
            //     //     ),
            //     //     onPressed: _mapController == null
            //     //         ? null
            //     //         : () {
            //     //             _perimeter();
            //     //           },
            //     //   )
            //     // ],
            //     backgroundColor: BuyandByeAppTheme.white,
            //     automaticallyImplyLeading: false,
            //     elevation: 0.0,
            //     bottomOpacity: 0.0,
            //   ),
            // ),
            body: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude), zoom: 10.0),
                    markers: Set<Marker>.of(markers.values),
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                  ),
                ),
                StreamBuilder(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            child: Center(
                          child: Platform.isIOS
                              ? Center(
                                  child: Column(
                                    children: [
                                      CupertinoActivityIndicator(),
                                      Text('Chargement...'),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      Text('Chargement...'),
                                    ],
                                  ),
                                ),
                        ));
                        //METTRE UN SHIMMER
                      }
                      if (!snapshot.hasData) return Container();
                      return Positioned(
                        bottom: 10.0,
                        child: Container(
                          height: 200.0,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              double value = 1;

                              return Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, int index) {
                                    return AnimatedBuilder(
                                      animation: _pageController,
                                      builder: (context, widget) {
                                        return Center(
                                          child: SizedBox(
                                            height: Curves.easeInOut
                                                    .transform(value) *
                                                125.0,
                                            width: Curves.easeInOut
                                                    .transform(value) *
                                                350.0,
                                            child: widget,
                                          ),
                                        );
                                      },
                                      child: InkWell(
                                        onTap: () {
                                          GeoPoint geoPoint = magasins[index]
                                              ['position']['geopoint'];
                                          _magasinAffichage(
                                            geoPoint.latitude,
                                            geoPoint.longitude,
                                            snapshot.data[index]['name'],
                                            snapshot.data[index]['id'],
                                            // snapshot.data[index]['adresse'],
                                            // snapshot.data[index]['imgUrl'],
                                            // snapshot.data[index]['description'],
                                            // snapshot.data[index]['livraison'],
                                            // snapshot.data[index]
                                            //     ['ClickAndCollect'],
                                          );
                                        },
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 20.0,
                                                ),
                                                height: 125.0,
                                                width: 275.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black54,
                                                      offset: Offset(0.0, 4.0),
                                                      blurRadius: 4.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: Colors.white,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 90.0,
                                                        width: 90.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                          ),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                snapshot.data[
                                                                        index]
                                                                    ['imgUrl']),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            snapshot.data[index]
                                                                ['name'],
                                                            style: TextStyle(
                                                                color: BuyandByeAppTheme
                                                                    .black_electrik,
                                                                fontSize: 12.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            snapshot.data[index]
                                                                ['adresse'],
                                                            style: TextStyle(
                                                                color: BuyandByeAppTheme
                                                                    .black_electrik,
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          Container(
                                                            width: 170.0,
                                                            child: Text(
                                                              snapshot.data[
                                                                      index][
                                                                  'description'],
                                                              style: TextStyle(
                                                                  color: BuyandByeAppTheme
                                                                      .black_electrik,
                                                                  fontSize:
                                                                      11.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
              ],
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Platform.isIOS
                      ? CupertinoActivityIndicator(
                          radius: 20,
                        )
                      : CircularProgressIndicator()),
              SizedBox(height: 10),
              Text("Chargement"),
              localisation == false
                  ? Column(
                      children: [
                        Text("Localisation desactivée"),
                        Platform.isIOS
                            ? CupertinoButton(
                                child: Text('Activer la localisation'),
                                onPressed: () {
                                  AppSettings.openLocationSettings();
                                })
                            : TextButton(
                                child: Text("Activer la localisation"),
                                onPressed: () => AppSettings.openAppSettings(),
                              ),
                      ],
                    )
                  : Text("Locatlisation activé"),
            ],
          );
  }
}

class MapStyle {
  static String mapStyle =
      ''' [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
] ''';
}
