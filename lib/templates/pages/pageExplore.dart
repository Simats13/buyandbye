import 'dart:io';

import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Pages/pageDetail.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PageExplore extends StatefulWidget {
  @override
  _PageExploreState createState() => _PageExploreState();
}

class _PageExploreState extends State<PageExplore> {
  var currentLocation;
  var position;
  var radius = BehaviorSubject<double>.seeded(10);
  late Geoflutterfire geo;
  bool mapToggle = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final Set<Marker> marker = new Set();
  int? prevPage;
  LocationPermission? permission;
  Stream<List<DocumentSnapshot>>? stream;
  late BitmapDescriptor mapMaker, mapMakerUser;
  PanelController _pc = new PanelController();
  
  List magasins = [];
  String label = 'kms';
  late String city;
  bool localisation = false;
  late double latitude, longitude;

  GoogleMapController? _mapController;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    setCustomMarker();
    userID();

    fetchDatabaseList();
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

      stream!.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });
      _mapController!.setMapStyle(MapStyle.mapStyle);
    });
  }

  void showHome() async {
    _mapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 10.0,
      ),
    ));
  }

  userID() async {
    label = await SharedPreferenceHelper().getLabelSliderUser() ?? "";
    final User user = await AuthMethods().getCurrentUser();
    var userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getChosenAddress(userid);
    latitude = double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");
    List<Placemark> addresses =
        await placemarkFromCoordinates(latitude, longitude);
    var first = addresses.first;
    setState(() {
      mapToggle = true;
      geo = Geoflutterfire();
      city = first.locality!;
      GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);
      stream = radius.switchMap((rad) {
        var collectionReference =
            FirebaseFirestore.instance.collection('magasins');
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: rad, field: 'position', strictMode: true);
      });
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/shop.png')
        .then((value) {
      mapMaker = value;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/icons/location-pin.png')
        .then((value) {
      mapMakerUser = value;
    });
    final id = MarkerId(latitude.toString() + longitude.toString());
    final markerUser = Marker(
      //add second marker
      markerId: MarkerId(latitude.toString() + longitude.toString()),
      position: LatLng(latitude, longitude), //position of marker
      icon: mapMakerUser, //Icon for Marker
    );

    setState(() {
      markers[id] = markerUser;
    });

    // print(markerUser);

    //String userid = user.uid;
  }

  //FONCTION ALERT PERMETTANT DE MONTRER PLUS D'INFOS SUR LES MAGASINS
  void _magasinAffichage(double lat, double lng, String? name, idSeller) {
    Size size = MediaQuery.of(context).size;
    showGeneralDialog(
        barrierLabel: "Affichage magasins",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 400),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Card(
            margin: EdgeInsets.only(
                top: size.height / 1.9, left: 20, right: 20, bottom: 30),
            child: Align(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
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
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              (snapshot.data! as QuerySnapshot).docs.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Center(
                                  child: Text(
                                    name!,
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
                                        (snapshot.data! as QuerySnapshot)
                                            .docs[index]['imgUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text("Adresse : " +
                                      (snapshot.data! as QuerySnapshot)
                                          .docs[index]['adresse']),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text("Description : " +
                                      (snapshot.data! as QuerySnapshot)
                                          .docs[index]['description']),
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
                                                    img: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs[index]['imgUrl'],
                                                    name: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs[index]['name'],
                                                    colorStore: (snapshot.data!
                                                                as QuerySnapshot)
                                                            .docs[index]
                                                        ['colorStore'],
                                                    description: (snapshot.data!
                                                                as QuerySnapshot)
                                                            .docs[index]
                                                        ['description'],
                                                    adresse: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs[index]['adresse'],
                                                    clickAndCollect: (snapshot
                                                                    .data!
                                                                as QuerySnapshot)
                                                            .docs[index]
                                                        ['ClickAndCollect'],
                                                    livraison: (snapshot.data!
                                                                as QuerySnapshot)
                                                            .docs[index]
                                                        ['livraison'],
                                                    sellerID: (snapshot.data!
                                                            as QuerySnapshot)
                                                        .docs[index]['id'],
                                                  )));
                                    },
                                    child: Center(
                                      child: Text(
                                        "Accéder au magasin",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    }),
              ),
            ),
          );
        });
  }

  //FONCTION ALERT PERMETTANT DE MODIFIER LE PERIMETRE DES MARQUEURS

  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/image/shop.png')
        .then((value) {
      mapMaker = value;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/icons/location-pin.png')
        .then((value) {
      mapMakerUser = value;
    });
  }

  void _addMarker(double lat, double lng, String? name, String? idSeller) {
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
    _mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lng), zoom: 14.0, bearing: 45.0, tilt: 45.0)));
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document.get('position')['geopoint'];
      final name = document.get('name');
      final idSeller = document.get('id');
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showHome();
              },
              child: const Icon(Icons.near_me),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
                  ),
                ),
                StreamBuilder<dynamic>(
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
                    //Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                    // final double _initFabHeight = 120.0;
                    // double _fabHeight = 0;
                    // double _panelHeightOpen = 0;
                    // double _panelHeightClosed = 95.0;
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        SlidingUpPanel(
                          // maxHeight: 30,
                          parallaxEnabled: true,
                          parallaxOffset: .5,
                          controller:_pc,
                          panelBuilder: (sc) {
                            return MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView(
                                controller: sc,
                                children: <Widget>[
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 30,
                                        height: 5,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12.0))),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 18.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Explorer $city",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 24.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 36.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      _button("Tous", Icons.store, Colors.blue),
                                      _button("Alimentation", Icons.restaurant,
                                          Colors.red),
                                      _button(
                                          "Events", Icons.event, Colors.amber),
                                      _button("More", Icons.more_horiz,
                                          Colors.green),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 36.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Découvrir les magasins",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 24.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 36.0,
                                  ),
                                  Container(
                              
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        StreamBuilder<dynamic>(
                                            stream: stream,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Shimmer.fromColors(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Center(
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Center(
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Center(
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                );
                                              }
                                              return ListView.builder(
                                                primary: false,
                                                shrinkWrap: true,
                                                itemCount: snapshot.data.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PageDetail(
                                                            img: snapshot
                                                                    .data[index]
                                                                ['imgUrl'],
                                                            colorStore: snapshot
                                                                    .data[index]
                                                                ['colorStore'],
                                                            name: snapshot
                                                                    .data[index]
                                                                ['name'],
                                                            description: snapshot
                                                                    .data[index]
                                                                ['description'],
                                                            adresse: snapshot
                                                                    .data[index]
                                                                ['adresse'],
                                                            clickAndCollect:
                                                                snapshot.data[
                                                                        index][
                                                                    'ClickAndCollect'],
                                                            livraison: snapshot
                                                                    .data[index]
                                                                ['livraison'],
                                                            sellerID: snapshot
                                                                    .data[index]
                                                                ['id'],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    leading: Container(
                                                      child: Image.network(
                                                        snapshot.data[index]
                                                            ['imgUrl'],
                                                      ),
                                                      
                                                    ),
                                                    trailing: Wrap(
                                                      // space between two icons
                                                      children: <Widget>[
                                                        IconButton(
                                                          onPressed: () {
                                                            _pc.close();
                                                            moveCamera(
                                                              snapshot
                                                                  .data[index][
                                                                      'position']
                                                                      [
                                                                      'geopoint']
                                                                  .latitude,
                                                              snapshot
                                                                  .data[index][
                                                                      'position']
                                                                      [
                                                                      'geopoint']
                                                                  .longitude,
                                                            );
                                                          },
                                                          icon:
                                                              Icon(Icons.place),
                                                        ),
                                                      ],
                                                    ),
                                                    title: Text(
                                                      snapshot.data[index]
                                                          ['name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0),
                                                    ),
                                                    subtitle: Text(
                                                      snapshot.data[index]
                                                          ['description'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15.0),
                                                    ),
                                                  );
                                                },
                                              );
                                            })
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                ],
                              ),
                            );
                          },
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
                                onPressed: () {})
                            : TextButton(
                                child: Text("Activer la localisation"),
                                onPressed: () {},
                              ),
                      ],
                    )
                  : Text("Locatlisation activé"),
            ],
          );
  }

  Widget _button(
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            onPressed: () {
              if (label == "Tous") {
                setState(() {
                  GeoFirePoint center =
                      geo.point(latitude: latitude, longitude: longitude);
                  stream = radius.switchMap((rad) {
                    var collectionReference =
                        FirebaseFirestore.instance.collection('magasins');
                    return geo
                        .collection(collectionRef: collectionReference)
                        .within(
                            center: center,
                            radius: rad,
                            field: 'position',
                            strictMode: true);
                  });
                  markers.clear();
                  BitmapDescriptor.fromAssetImage(
                          ImageConfiguration(), 'assets/icons/location-pin.png')
                      .then((value) {
                    mapMakerUser = value;
                  });
                  final id =
                      MarkerId(latitude.toString() + longitude.toString());
                  final markerUser = Marker(
                    //add second marker
                    markerId:
                        MarkerId(latitude.toString() + longitude.toString()),
                    position: LatLng(latitude, longitude), //position of marker
                    icon: mapMakerUser, //Icon for Marker
                  );

                  setState(() {
                    markers[id] = markerUser;
                  });
                  stream!.listen((List<DocumentSnapshot> documentList) {
                    _updateMarkers(documentList);
                  });
                });
              }
              if (label == "Alimentation") {
                setState(() {
                  GeoFirePoint center =
                      geo.point(latitude: latitude, longitude: longitude);
                  stream = radius.switchMap((rad) {
                    var collectionReference = FirebaseFirestore.instance
                        .collection('magasins')
                        .where("mainCategorie", arrayContains: label);
                    return geo
                        .collection(collectionRef: collectionReference)
                        .within(
                            center: center,
                            radius: rad,
                            field: 'position',
                            strictMode: true);
                  });
                  BitmapDescriptor.fromAssetImage(
                          ImageConfiguration(), 'assets/icons/location-pin.png')
                      .then((value) {
                    mapMakerUser = value;
                  });
                  markers.clear();
                  final id =
                      MarkerId(latitude.toString() + longitude.toString());
                  final markerUser = Marker(
                    //add second marker
                    markerId:
                        MarkerId(latitude.toString() + longitude.toString()),
                    position: LatLng(latitude, longitude), //position of marker
                    icon: mapMakerUser, //Icon for Marker
                  );

                  setState(() {
                    markers[id] = markerUser;
                  });
                  stream!.listen((List<DocumentSnapshot> documentList) {
                    _updateMarkers(documentList);
                  });
                });
              }
            },
            icon: Icon(icon),
            color: Colors.white,
          ),
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(label),
      ],
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
