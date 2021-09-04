import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';

import '../buyandbye_app_theme.dart';

class PageAddressNext extends StatefulWidget {
  const PageAddressNext({Key key, this.lat, this.long, this.adresse})
      : super(key: key);
  final double lat;
  final double long;
  final String adresse;
  @override
  _PageAddressNextState createState() => _PageAddressNextState();
}

class _PageAddressNextState extends State<PageAddressNext> {
  GoogleMapController _mapController;
  Stream<List<DocumentSnapshot>> stream;
  final _formKey = GlobalKey<FormState>();
  var currentLocation;
  var position;
  Geoflutterfire geo;
  bool mapToggle = false;
  Set<Marker> _markers = Set<Marker>();
  bool isEnabled = false;
  String buildingDetails = "";
  String buildingName = "";
  String adressTitle = "";
  String familyName = "";

  BitmapDescriptor mapMarker;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;

      _mapController.setMapStyle(MapStyle.mapStyle);
    });
  }

  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), '../assets/images/shop.png')
        .then((value) {
      mapMarker = value;
    });
  }

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
      });
    });

    final idMarker = MarkerId(widget.lat.toString() + widget.long.toString());
    _markers.add(Marker(
      markerId: idMarker,
      position: LatLng(widget.lat, widget.long),
      //icon: mapMarker,
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Enregistrer une adresse'),
          backwardsCompatibility: false, // 1
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: BuyandByeAppTheme.black_electrik,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  height: MediaQuery.of(context).size.height * (1 / 5),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(widget.lat, widget.long), zoom: 15.0),
                    myLocationButtonEnabled: false,
                    markers: _markers,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
                    child: Container(
                      child: Text(widget.adresse,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 0) {
                            isEnabled = true;
                          } else {
                            isEnabled = false;
                          }
                        });
                      },
                      onSaved: (value) => buildingDetails = value,
                      autofocus: false,
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "Numéro d'appartement, porte, étage",
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 6.0, top: 8.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 0) {
                            isEnabled = true;
                          } else {
                            isEnabled = false;
                          }
                        });
                      },
                      onSaved: (value) => buildingName = value,
                      autofocus: false,
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "Nom de l'entreprise ou de l'immeuble",
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 6.0, top: 8.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 0) {
                            isEnabled = true;
                          } else {
                            isEnabled = false;
                          }
                        });
                      },
                      onSaved: (value) => familyName = value,
                      autofocus: false,
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Code porte et nom de famille',
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 6.0, top: 8.0),
                      ),
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
                height: 15,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
                    child: Container(
                      child: Text("Intitulé de l'adresse",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  child: Container(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 0) {
                            isEnabled = true;
                          } else {
                            isEnabled = false;
                          }
                        });
                      },
                      autofocus: false,
                      onSaved: (value) => adressTitle = value,
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Ajouter un intitulé (p. ex : Maison)',
                        //hintText: 'Ajouter un intitulé (p. ex : Maison)',
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.15),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 6.0, top: 8.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  onPressed: isEnabled
                      ? () {
                          // Validate returns true if the form is valid, or false otherwise.

                          final isValid = _formKey.currentState.validate();

                          if (isValid) {
                            _formKey.currentState.save();

                            sendToDatabaseAddress(
                                buildingDetails,
                                buildingName,
                                familyName,
                                adressTitle,
                                widget.long,
                                widget.lat,
                                widget.adresse);
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: const Text('Enregistrer et continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendToDatabaseAddress(
      String buildingDetails,
      String buildingName,
      String familyName,
      String adressTitle,
      double longitude,
      double latitude,
      String address) async {
    try {
      await DatabaseMethods.instanace.addAdresses(buildingDetails, buildingName,
          familyName, adressTitle, longitude, latitude, address);
    } catch (e) {
      showAlertDialog(context, 'Error user information to database');
    }
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
