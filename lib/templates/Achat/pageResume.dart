import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/widgets/loader.dart';

import '../buyandbye_app_theme.dart';

class PageResume extends StatefulWidget {
  final String idCommand;
  final String userId;
  final String sellerID;
  const PageResume({Key key, this.idCommand, this.userId, this.sellerID})
      : super(key: key);

  @override
  _PageResumeState createState() => _PageResumeState();
}

class _PageResumeState extends State<PageResume> {
  var produits;
  String idProduit;
  String nomBoutique;
  String nomProduit;
  String userAddressChoose;
  String adresseBoutique;
  double livraison;
  double latitude;
  double longitude;
  GoogleMapController _mapController;
  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor mapMarker;
  @override
  void initState() {
    super.initState();
    getThisUserInfo();
    getCommand();
  }

  getCommand() async {
    print(widget.sellerID);
    String id = widget.sellerID + widget.userId;
    produits = await FirebaseFirestore.instance
        .collection('commandes')
        .doc(id)
        .collection('commands')
        .doc(widget.idCommand)
        .get();
  }

  getThisUserInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfoViaID(widget.sellerID);
    nomBoutique = "${querySnapshot.docs[0]["name"]}";
    latitude = double.parse(
        "${querySnapshot.docs[0]['position']['geopoint'].latitude}");
    longitude = double.parse(
        "${querySnapshot.docs[0]['position']['geopoint'].longitude}");
    adresseBoutique = "${querySnapshot.docs[0]["adresse"]}";

    final idMarker = MarkerId(latitude.toString() + longitude.toString());
    _markers.add(Marker(
      markerId: idMarker,
      position: LatLng(latitude, longitude),
      //icon: mapMarker,
    ));

    setState(() {});
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            title: Text('Récapitulatif de commande'),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: BuyandByeAppTheme.black_electrik,
            automaticallyImplyLeading: false,
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 0, 0),
                  child: Column(children: [
                    Row(children: [
                      Text("Ma Commande : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          )),
                    ]),
                    SizedBox(height: 10),
                    Row(children: [
                      FutureBuilder(
                          future: DatabaseMethods().getPurchaseDetails(
                              "users", widget.userId, widget.idCommand),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Expanded(
                                child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Row(children: [
                                                Container(
                                                    child: Detail(
                                                        widget.sellerID,
                                                        snapshot.data
                                                                .docs[index]
                                                            ["produit"],
                                                        snapshot.data
                                                                .docs[index]
                                                            ["quantite"])),
                                              ])),
                                        ],
                                      );
                                    }),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ]),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(children: [
                              Row(children: [
                                Text("Click & Collect",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 21,
                                    )),
                              ]),
                              SizedBox(height: 10),
                              Row(children: [
                                nomBoutique == null
                                    ? CircularProgressIndicator()
                                    : Text("Vendeur : " + nomBoutique,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        )),
                              ]),
                              SizedBox(height: 10),
                              Row(children: [
                                Text("Adresse du magasin : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    )),
                              ]),
                              SizedBox(height: 10),
                              Row(children: [
                                adresseBoutique == null
                                    ? CircularProgressIndicator()
                                    : Text(adresseBoutique,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        )),
                              ]),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Center(
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 30,
                            height:
                                MediaQuery.of(context).size.height * (1 / 3),
                            child: GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(latitude, longitude),
                                  zoom: 15.0),
                              markers: _markers,
                              myLocationButtonEnabled: false,
                              myLocationEnabled: true,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 50,
                    )
                  ]))
            ])));
  }
}

// Affiche le détail de chaque produit commandé
class Detail extends StatefulWidget {
  Detail(this.shopId, this.productId, this.quantite);
  final String shopId, productId;
  final int quantite;
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            DatabaseMethods().getOneProduct(widget.shopId, widget.productId),
        builder: (context, snapshot) {
          var amount = widget.quantite;
          var money = snapshot.data["prix"];
          var allMoneyForProduct = money * amount;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
            );
          }
          if (snapshot.hasData) {
            return Expanded(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.scaleDown,
                                      image: NetworkImage(
                                          snapshot.data["images"][0])),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text(
                                  snapshot.data["nom"],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "$allMoneyForProduct€",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Quantité : $amount",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 7,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
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
