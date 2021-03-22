import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ndialog/ndialog.dart';
import 'package:oficihome/services/auth.dart';
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
  Geoflutterfire geo;
  bool mapToggle = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int prevPage;
  final radius = BehaviorSubject<double>.seeded(1.0);
  bool showContainer = false;
  Stream<List<DocumentSnapshot>> stream;
  BitmapDescriptor mapMaker;

  List magasins = [];

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

    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
      });
    });

    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 43.837636, longitude: 4.359415);
    stream = radius.switchMap((rad) {
      var collectionReference = _firestore.collection('magasins');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'position', strictMode: true);
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
    dynamic result = await AuthMethods().getMagasin();
    if (result == null) {
      print('Impossible de retrouver les données');
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

  void _magasinAffichage(String name, double lat, double lng) {
    slideDialog.showSlideDialog(
        context: context,
        child: Container(
          child: Row(
            children: [
              Text(name),
              TextButton(
                  onPressed: () {
                    moveCamera(lat, lng);
                    Navigator.of(context).pop();
                  },
                  child: Text("Voir sur la carte"))
            ],
          ),
        ));
  }

//FONCTION ALERT PERMETTANT DE MODIFIER LE PERIMETRE DES MARQUEURS
  _perimeterMap() {
    double _value = 20.0;
    String _label = '';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, innerSetState) {
            return DialogBackground(
              dialog: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
                title: Text("Changer de Périmètre"),
                content: Container(
                  width: double.infinity,
                  height: 100,
                  child: Slider(
                    min: 1,
                    max: 200,
                    divisions: 10,
                    value: _value,
                    label: _label,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withOpacity(0.2),
                    onChanged: (double value) {
                      innerSetState(() {
                        _value = value;
                        _label = '${_value.toInt().toString()} km';
                        markers.clear();
                      });
                      radius.add(value);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"))
                ],
              ),
            );
          });
        });
  }

  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/shop.png')
        .then((value) {
      mapMaker = value;
    });
  }

  void _addMarker(double lat, double lng, String name) {
    final id = MarkerId(lat.toString() + lng.toString());
    final _marker = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      icon: mapMaker,
      infoWindow: InfoWindow(title: '$name', snippet: '$lat,$lng'),
    );
    setState(() {
      markers[id] = _marker;
    });
  }

  moveCamera(double lat, double lng) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.0,
      bearing: 45.0,
      tilt: 45.0,
    )));
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document.data()['position']['geopoint'];
      final name = document.data()['name'];
      _addMarker(point.latitude, point.longitude, name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: OficihomeAppTheme.black_electrik,
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
                    _perimeterMap();
                  },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 50.0,
            width: MediaQuery.of(context).size.width,
            child: mapToggle
                ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(currentLocation.latitude,
                            currentLocation.longitude),
                        zoom: 15.0),
                    markers: Set<Marker>.of(markers.values),
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                  )
                : Stack(children: [
                    Container(
                      child: Center(
                        child: Text(
                          "Chargement.... Veuillez Patienter",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ]),
          ),
          mapToggle
              ? Positioned(
                  bottom: 10.0,
                  child: Container(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: magasins.length,
                      itemBuilder: (context, index) {
                        double value = 1;
                        return Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: magasins.length,
                            itemBuilder: (context, int index) {
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, widget) {
                                  return Center(
                                    child: SizedBox(
                                      height:
                                          Curves.easeInOut.transform(value) *
                                              125.0,
                                      width: Curves.easeInOut.transform(value) *
                                          350.0,
                                      child: widget,
                                    ),
                                  );
                                },
                                child: InkWell(
                                  onTap: () {
                                    GeoPoint geoPoint =
                                        magasins[index]['position']['geopoint'];
                                    _magasinAffichage(
                                      magasins[index]['name'],
                                      geoPoint.latitude,
                                      geoPoint.longitude,
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
                                                BorderRadius.circular(10.0),
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
                                                  BorderRadius.circular(10.0),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 90.0,
                                                  width: 90.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10.0),
                                                      topLeft:
                                                          Radius.circular(10.0),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          magasins[index]
                                                              ['photoUrl']),
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      magasins[index]['name'],
                                                      style: TextStyle(
                                                          color: OficihomeAppTheme
                                                              .black_electrik,
                                                          fontSize: 12.5,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      magasins[index]
                                                          ['adresse'],
                                                      style: TextStyle(
                                                          color: OficihomeAppTheme
                                                              .black_electrik,
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Container(
                                                      width: 170.0,
                                                      child: Text(
                                                        magasins[index]
                                                            ['description'],
                                                        style: TextStyle(
                                                            color: OficihomeAppTheme
                                                                .black_electrik,
                                                            fontSize: 11.0,
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
                )
              : Center(),
        ],
      ),
    );
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
