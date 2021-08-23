import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:oficihome/templates/Widgets/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:rxdart/rxdart.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

class PageExplore extends StatefulWidget {
  @override
  _PageExploreState createState() => _PageExploreState();
}

class _PageExploreState extends State<PageExplore> {
  var currentLocation;
  var position;
  Geoflutterfire geo;
  bool mapToggle = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int prevPage;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;
  BitmapDescriptor mapMaker;
  double _value = 40.0;
  List magasins = [];

  // INITIALISATION DE SHARE_PREFERENCES (PERMET DE GARDER EN MEMOIRE DES INFORMATIONS, ICI LA LONGITUDE ET LA LATITUDE)
  static SharedPreferences _preferences;
  static const _keySlider = "UserSliderKey";

  // firestore init
  final _firestore = FirebaseFirestore.instance;

  TextEditingController _latitudeController, _longitudeController;
  GoogleMapController _mapController;
  PageController _pageController;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    radius.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    setCustomMarker();
    // userID();

    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
      });
    });

    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        position = value;
        geo = Geoflutterfire();
        GeoFirePoint center = geo.point(
            latitude: position.latitude, longitude: position.longitude);
        stream = radius.switchMap((rad) {
          var collectionReference = _firestore.collection('magasins');
          return geo.collection(collectionRef: collectionReference).within(
              center: center, radius: rad, field: 'position', strictMode: true);
        });
      });
    });

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

  void _showHome() {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15.0,
      ),
    ));
  }

  // userID() async {
  //   final User user = await AuthMethods().getCurrentUser();
  //   _value = await SharedPreferenceHelper().getUserSlider();
  // }

  //FONCTION ALERT PERMETTANT DE MONTRER PLUS D'INFOS SUR LES MAGASINS

  void _magasinAffichage(double lat, double lng, String name, adresse, imgUrl,
      description, List horaires, bool livraison, clickAndCollect) {
    slideDialog.showSlideDialog(
      context: context,
      child: Container(
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
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text("Adresse : " + adresse),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: TextButton(
                onPressed: () {
                  moveCamera(lat, lng);
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    "Voir sur la map",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //FONCTION ALERT PERMETTANT DE MODIFIER LE PERIMETRE DES MARQUEURS
  void _perimeter() async {
    String _label = '';
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
                    await _preferences.setDouble(_keySlider, _value);
                    _preferences.setDouble(_keySlider, _value);
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
                            target: LatLng(currentLocation.latitude,
                                currentLocation.longitude),
                            zoom: 15.0),
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

  void _addMarker(double lat, double lng, String name, adresse, imgUrl,
      description, List horaires, bool livraison, clickAndCollect) {
    final id = MarkerId(lat.toString() + lng.toString());
    final _marker = Marker(
        markerId: id,
        position: LatLng(lat, lng),
        icon: mapMaker,
        onTap: () {
          _magasinAffichage(lat, lng, name, adresse, imgUrl, description,
              horaires, livraison, clickAndCollect);
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
      final clickAndCollect = document.get('ClickAndCollect');
      final adresse = document.get('adresse');
      final description = document.get('description');
      final horaires = document.get('horaires');
      final livraison = document.get('livraison');
      final imgUrl = document.get('imgUrl');
      _addMarker(point.latitude, point.longitude, name, adresse, imgUrl,
          description, horaires, livraison, clickAndCollect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return mapToggle
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: OficihomeAppTheme.black_electrik,
              backwardsCompatibility: false, // 1
              systemOverlayStyle: SystemUiOverlayStyle.light,
              title: Text('Explorer'),
              actions: <Widget>[
                IconButton(
                  onPressed: _mapController == null
                      ? null
                      : () {
                          _showHome();
                        },
                  icon: Icon(
                    Icons.home,
                    color: OficihomeAppTheme.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_location_outlined,
                    color: OficihomeAppTheme.white,
                  ),
                  onPressed: _mapController == null
                      ? null
                      : () {
                          _perimeter();
                        },
                )
              ],
            ),
            body: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(currentLocation.latitude,
                            currentLocation.longitude),
                        zoom: 10.0),
                    markers: Set<Marker>.of(markers.values),
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                  ),
                ),
                StreamBuilder(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: ColorLoader3(
                            radius: 15.0,
                            dotRadius: 6.0,
                          ),
                        );
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
                                            snapshot.data[index]['adresse'],
                                            snapshot.data[index]['imgUrl'],
                                            snapshot.data[index]['description'],
                                            snapshot.data[index]['horaires'],
                                            snapshot.data[index]['livraison'],
                                            snapshot.data[index]
                                                ['ClickAndCollect'],
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
                                                                color: OficihomeAppTheme
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
                                                                color: OficihomeAppTheme
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
                                                                  color: OficihomeAppTheme
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
        : Center(child: CircularProgressIndicator());
  }
}

class MapStyle {
  static String mapStyle = ''' [
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
