import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/Pages/pageAddressEdit.dart';
import 'package:oficihome/templates/Paiement/payment.dart';
import 'package:oficihome/templates/Widgets/loader.dart';
import 'package:truncate/truncate.dart';

import '../oficihome_app_theme.dart';

class PageLivraison extends StatefulWidget {
  const PageLivraison({Key key, this.idCommercant, this.total})
      : super(key: key);
  final String idCommercant;
  final double total;

  @override
  _PageLivraisonState createState() => _PageLivraisonState();
}

enum Type { Type1, Type2 }

class _PageLivraisonState extends State<PageLivraison> {
  String val = "0";
  String userid;
  String nomBoutique;
  String adresseBoutique;
  double deliveryChoose = 0;
  String userAddressChoose;
  double latitude;
  double longitude;
  GoogleMapController _mapController;
  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor mapMarker;

  @override
  void initState() {
    super.initState();
    userID();
    getThisUserInfo();
  }

  userID() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
  }

  getThisUserInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfoViaID(widget.idCommercant);
    nomBoutique = "${querySnapshot.docs[0]["name"]}";
    latitude = double.parse(
        "${querySnapshot.docs[0]['position']['geopoint'].latitude}");
    longitude = double.parse(
        "${querySnapshot.docs[0]['position']['geopoint'].longitude}");
    adresseBoutique = "${querySnapshot.docs[0]["adresse"]}";
    userAddressChoose = adresseBoutique;

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
    if (nomBoutique != null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Choisir un mode de livraison'),
            backwardsCompatibility: false, // 1
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: OficihomeAppTheme.black_electrik,
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
                child: Column(
                  children: [
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
                          future: DatabaseMethods().getCart(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Expanded(
                                child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder: (context, index) {
                                      var amount =
                                          snapshot.data.docs[index]["amount"];
                                      var money = snapshot.data.docs[index]
                                          ["prixProduit"];
                                      var allMoneyForProduct = money * amount;
                                      return Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Center(
                                                    child: Container(
                                                      width: 60,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              image: NetworkImage(snapshot
                                                                          .data
                                                                          .docs[
                                                                      index][
                                                                  "imgProduit"])),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 100,
                                                        child: Text(
                                                          snapshot.data
                                                                  .docs[index]
                                                              ["nomProduit"],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "$allMoneyForProduct€",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "- $amount",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                      );
                                    }),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.total.toString() + "€",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Divider(
                color: Colors.black,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Row(
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
                            Text("Vendeur : " + nomBoutique,
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
                            Text(adresseBoutique,
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
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Row(children: [
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
                          markers: _markers,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              RadioListTile(
                title: Text("Retrait en magasin chez " + nomBoutique),
                value: "0",
                groupValue: val,
                onChanged: (v) => {
                  setState(() {
                    val = v;
                    deliveryChoose = 0;
                    print(deliveryChoose);
                    userAddressChoose = adresseBoutique;
                    print(userAddressChoose);
                  })
                },
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
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          Row(children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                "Livraison à Domicile",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                ),
                              ),
                            ),
                          ]),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Container(
                                  child: Text("Mes adresses enregistrées : "),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(userid)
                                  .collection("Address")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data.docs.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(00, 0, 0, 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    RadioListTile(
                                                      title: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(Icons
                                                                  .place_rounded),
                                                              SizedBox(
                                                                  width: 10),
                                                              Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                        height:
                                                                            30),
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        snapshot
                                                                            .data
                                                                            .docs[index]["addressName"],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        child:
                                                                            Row(
                                                                      children: [
                                                                        Text(truncate(
                                                                            snapshot.data.docs[index][
                                                                                "address"],
                                                                            25,
                                                                            omission:
                                                                                "...",
                                                                            position:
                                                                                TruncatePosition.end)),
                                                                        Row(
                                                                            children: [
                                                                              IconButton(
                                                                                icon: Icon(Icons.edit),
                                                                                onPressed: () {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => PageAddressEdit(
                                                                                                adresse: snapshot.data.docs[index]["address"],
                                                                                                adressTitle: snapshot.data.docs[index]["addressName"],
                                                                                                buildingDetails: snapshot.data.docs[index]["buildingDetails"],
                                                                                                buildingName: snapshot.data.docs[index]["buildingName"],
                                                                                                familyName: snapshot.data.docs[index]["familyName"],
                                                                                                lat: snapshot.data.docs[index]["latitude"],
                                                                                                long: snapshot.data.docs[index]["longitude"],
                                                                                                iD: snapshot.data.docs[index]["idDoc"],
                                                                                              )));
                                                                                },
                                                                              ),
                                                                            ]),
                                                                      ],
                                                                    )),
                                                                  ]),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      value: snapshot
                                                              .data.docs[index]
                                                          ["addressName"],
                                                      groupValue: val,
                                                      onChanged: (v) => {
                                                        setState(() {
                                                          val = v;

                                                          userAddressChoose =
                                                              snapshot.data
                                                                          .docs[
                                                                      index]
                                                                  ["address"];
                                                          deliveryChoose = 2;
                                                          print(
                                                              userAddressChoose);
                                                          print(deliveryChoose);
                                                        })
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              )),
                                            ],
                                          ),
                                        );
                                      });
                                } else {
                                  return Container(
                                      child:
                                          Text("Pas d'adresses enregistrées"));
                                }
                              }),
                          MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AccueilPaiement(
                                            userId: userid,
                                            idCommercant: widget.idCommercant,
                                            total: widget.total,
                                            userAddress: userAddressChoose,
                                            deliveryChoose: deliveryChoose,
                                          )));
                            },
                            color: OficihomeAppTheme.orange,
                            height: 50,
                            minWidth: MediaQuery.of(context).size.width - 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "PASSER AU PAIEMENT",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: ColorLoader3(
          radius: 15.0,
          dotRadius: 6.0,
        ),
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
