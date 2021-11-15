import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import '../buyandbye_app_theme.dart';

class PageAddressEdit extends StatefulWidget {
  const PageAddressEdit(
      {Key? key,
      this.lat,
      this.long,
      this.adresse,
      this.buildingDetails,
      this.buildingName,
      this.adressTitle,
      this.familyName,
      this.iD})
      : super(key: key);
  final double? lat;
  final double? long;
  final String? adresse;
  final String? buildingDetails;
  final String? buildingName;
  final String? adressTitle;
  final String? familyName;
  final String? iD;
  @override
  _PageAddressEditState createState() => _PageAddressEditState();
}

class _PageAddressEditState extends State<PageAddressEdit> {
  late GoogleMapController _mapController;
  Stream<List<DocumentSnapshot>>? stream;
  final _formKey = GlobalKey<FormState>();
  var currentLocation;
  var position;
  Geoflutterfire? geo;
  bool mapToggle = false;

  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor? mapMarker;
  String? userAddress;
  String? buildingDetailsEdit;
  String? buildingNameEdit;
  String? adressTitleEdit;
  String? familyNameEdit;

  // Controlleur des champs de texte. Remplace ceux crée précédemment
  TextEditingController? buildingDetailsController;
  TextEditingController? buildingNameController;
  TextEditingController? familyNameController;
  TextEditingController? addressTitleController;

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
    findAddress();

    buildingDetailsController =
        TextEditingController(text: widget.buildingDetails);

    buildingNameController = TextEditingController(text: widget.buildingName);

    familyNameController = TextEditingController(text: widget.familyName);

    addressTitleController = TextEditingController(text: widget.adressTitle);

    final idMarker = MarkerId(widget.lat.toString() + widget.long.toString());
    _markers.add(Marker(
      markerId: idMarker,
      position: LatLng(widget.lat!, widget.long!),
      //icon: mapMarker,
    ));

    setState(() {});
  }

  findAddress() async {
    List<geocoder.Placemark> addresses =
        await geocoder.placemarkFromCoordinates(widget.lat!, widget.long!);
    var first = addresses.first;
    setState(() {
      userAddress = "${first.name}, ${first.locality}, ${first.country}";
    });
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
          title: Text('Modifier une adresse'),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: BuyandByeAppTheme.black_electrik,
          automaticallyImplyLeading: false,
          actions: [
            // Boutons pour modifier les informations du commerçant
            Padding(
                padding: EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      Platform.isIOS
                          ? showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: Text("Suppression de l'adresse"),
                                    content: Text(
                                        "Souhaitez-vous réellement supprimer l'adresse ?"),
                                    actions: [
                                      // Close the dialog
                                      CupertinoButton(
                                          child: Text('Annuler'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      CupertinoButton(
                                        child: Text(
                                          'Suppression',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          DatabaseMethods()
                                              .deleteAddress(widget.iD);
                                          Navigator.of(context).pop(false);
                                          Navigator.of(context).pop(false);
                                        },
                                      )
                                    ],
                                  ))
                          : showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Suppression du compte"),
                                content: Text(
                                    "Souhaitez-vous réellement supprimer l'adresse ?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("Annuler"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Suppression',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () async {
                                      DatabaseMethods()
                                          .deleteAddress(widget.iD);
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              ),
                            );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Icon(Icons.delete_forever, color: Colors.red),
                ))
          ],
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
                        target: LatLng(widget.lat!, widget.long!), zoom: 15.0),
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
                      child: Text(userAddress ?? "Chargement",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
                      controller: buildingDetailsController,
                      autofocus: false,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        suffixIcon: IconButton(
                          onPressed: buildingDetailsController!.clear,
                          icon: Icon(Icons.clear),
                        ),
                        labelText: "Numéro d'appartement, porte, étage",
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
                      controller: buildingNameController,
                      autofocus: false,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: buildingNameController!.clear,
                          icon: Icon(Icons.clear),
                        ),
                        filled: true,
                        labelText: "Nom de l'entreprise ou de l'immeuble",
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
                      controller: familyNameController,
                      autofocus: false,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        suffixIcon: IconButton(
                          onPressed: familyNameController!.clear,
                          icon: Icon(Icons.clear),
                        ),
                        labelText: "Code porte et nom de famille",
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
                      autofocus: false,
                      controller: addressTitleController,
                      style: TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: addressTitleController!.clear,
                          icon: Icon(Icons.clear),
                        ),
                        labelText: "Ajouter un intitulé (p. ex : Maison)",
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
                  onPressed: () {
                    // Si un champ est vide, on envoi la valeur déjà présente

                    var buildingDetailsEdit =
                        buildingDetailsController!.text == ""
                            ? ""
                            : buildingDetailsController!.text;
                    var buildingNameEdit = buildingNameController!.text == ""
                        ? ""
                        : buildingNameController!.text;
                    var familyNameEdit = familyNameController!.text == ""
                        ? ""
                        : familyNameController!.text;
                    var adressTitleEdit = addressTitleController!.text == ""
                        ? ""
                        : addressTitleController!.text;

                    // Validate returns true if the form is valid, or false otherwise.

                    final isValid = _formKey.currentState!.validate();

                    if (isValid) {
                      _formKey.currentState!.save();

                      // final message =
                      //     "$buildingDetailsEdit, $buildingNameEdit, $familyNameEdit, $adressTitleEdit";

                      // final snackBar = SnackBar(content: Text(message));
                      // ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      editToDatabaseAddress(
                          buildingDetailsEdit,
                          buildingNameEdit,
                          familyNameEdit,
                          adressTitleEdit,
                          widget.long,
                          widget.lat,
                          userAddress,
                          widget.iD);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Enregistrer et continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> editToDatabaseAddress(
    String buildingDetails,
    String buildingName,
    String familyName,
    String adressTitle,
    double? latitude,
    double? longitude,
    String? address,
    String? id,
  ) async {
    try {
      await DatabaseMethods.instance.editAdresses(
          buildingDetails,
          buildingName,
          familyName,
          adressTitle,
          latitude,
          longitude,
          address,
          widget.iD);
    } catch (e) {
      !Platform.isIOS
          ? showAlertDialog(context,
              "Erreur lors de l'envoi, veuillez réesayer ultérieurement")
          : CupertinoAlertDialog(
              title: Text("Erreur"),
              content: Text(
                  "Erreur lors de l'envoi, veuillez réesayer ultérieurement"),
            );
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
