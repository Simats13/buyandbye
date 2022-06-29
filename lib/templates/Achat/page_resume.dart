import 'package:buyandbye/templates/Pages/page_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/widgets/loader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../buyandbye_app_theme.dart';

class PageResume extends StatefulWidget {
  final String? idCommand,
      userId,
      sellerID,
      nomBoutique,
      addressSeller,
      userAddressChoose;

  final double? deliveryChoose;
  final double? latitude, longitude;

  const PageResume(
      {Key? key,
      this.idCommand,
      this.userId,
      this.sellerID,
      this.latitude,
      this.longitude,
      this.nomBoutique,
      this.addressSeller,
      this.userAddressChoose,
      this.deliveryChoose})
      : super(key: key);

  @override
  _PageResumeState createState() => _PageResumeState();
}

class _PageResumeState extends State<PageResume> {

  late GoogleMapController _mapController;
  final Set<Marker> _markers = <Marker>{};
  BitmapDescriptor? mapMarker;
  String? shopName, profilePic, description, adresse, colorStore;
  bool? clickAndCollect, livraison;
  @override
  void initState() {
    super.initState();
    getThisUserInfo();
    getShopInfos();
  }

  getThisUserInfo() async {
    final idMarker =
        MarkerId(widget.latitude.toString() + widget.longitude.toString());
    _markers.add(Marker(
      markerId: idMarker,
      position: LatLng(widget.latitude!, widget.longitude!),
      //icon: mapMarker,
    ));

    setState(() {});
  }

  getShopInfos() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(widget.sellerID);
    shopName = "${querySnapshot.docs[0]["name"]}";
    profilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    description = "${querySnapshot.docs[0]["description"]}";
    adresse = "${querySnapshot.docs[0]["adresse"]}";
    clickAndCollect = "${querySnapshot.docs[0]["ClickAndCollect"]}" == 'true';
    colorStore = "${querySnapshot.docs[0]["colorStore"]}";
    livraison = "${querySnapshot.docs[0]["livraison"]}" == 'true';

    if (mounted) {
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;

      _mapController.setMapStyle(MapStyle.mapStyle);
    });
  }

  void setCustomMarker() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/images/shop.png')
        .then((value) {
      mapMarker = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BuyandByeAppTheme.white,
        appBar: AppBar(
          title: RichText(
            text: const TextSpan(
              // style: Theme.of(context).textTheme.bodyText2,
              children: [
                TextSpan(
                    text: "Récapitulatif",
                    style: TextStyle(
                      fontSize: 20,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.shopping_cart,
                      color: BuyandByeAppTheme.orangeFonce,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: BuyandByeAppTheme.white,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          bottomOpacity: 0.0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: BuyandByeAppTheme.orange,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 0, 0),
                  child: Column(children: [
                    Row(children: const [
                      Text("Ma Commande : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      StreamBuilder<dynamic>(
                          stream: DatabaseMethods().getPurchaseResumeDetails(
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
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              children: [
                                                Detail(
                                                  widget.sellerID!,
                                                  snapshot.data.docs[index]
                                                      ["produit"],
                                                  snapshot.data.docs[index]
                                                      ["quantite"],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              );
                            } else {
                              return Shimmer.fromColors(
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width -
                                            40,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 10,)
                                  ],
                                ),
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                              );
                            }
                          }),
                    ]),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(children: [
                              Row(children: [
                                widget.deliveryChoose == 0
                                    ? const Text("Click & Collect",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21,
                                        ))
                                    : const Text("Livraison à domicile",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21,
                                        )),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                const Text("Vendeur :",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                widget.nomBoutique == null
                                    ? const CircularProgressIndicator()
                                    : TextButton(
                                        child: Text(widget.nomBoutique!,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PageDetail(
                                                        img: profilePic,
                                                        name: shopName,
                                                        description:
                                                            description,
                                                        adresse: adresse,
                                                        clickAndCollect:
                                                            clickAndCollect,
                                                        livraison: livraison,
                                                        colorStore: colorStore,
                                                        sellerID:
                                                            widget.sellerID,
                                                      )));
                                        }),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                widget.deliveryChoose == 0
                                    ? const Text(
                                        "Adresse du magasin à retirer le produit :",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ))
                                    : const Text("Livraison à domicile :",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        )),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                widget.addressSeller == null
                                    ? const CircularProgressIndicator()
                                    : widget.deliveryChoose == 0
                                        ? TextButton.icon(
                                            onPressed: () {
                                              MapUtils.openMap(widget.addressSeller!);
                                            },
                                            icon: const Icon(Icons.storefront),
                                            label: Text(widget.addressSeller!),
                                          )
                                        : TextButton.icon(
                                            onPressed: () {
                                              MapUtils.openMap(widget.addressSeller!);
                                            },
                                            icon: const Icon(Icons.home),
                                            label:
                                                Text(widget.userAddressChoose!),
                                          )
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
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 30,
                            height:
                                MediaQuery.of(context).size.height * (1 / 3),
                            child: GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      widget.latitude!, widget.longitude!),
                                  zoom: 15.0),
                              markers: _markers,
                              myLocationButtonEnabled: false,
                              myLocationEnabled: true,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 50,
                    )
                  ]))
            ])));
  }
}

// Affiche le détail de chaque produit commandé
class Detail extends StatefulWidget {
  const Detail(this.shopId, this.productId, this.quantite, {Key? key}) : super(key: key);
  final String shopId, productId;
  final int quantite;
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream:
            DatabaseMethods().getOneProduct(widget.shopId, widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
            );
          }
          if (snapshot.hasData) {
            var amount = widget.quantite;
            var money = snapshot.data["prix"];
            var allMoneyForProduct = money * amount;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
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
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 100,
                                child: Text(
                                  snapshot.data["nom"],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "$allMoneyForProduct€",
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Quantité : $amount",
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
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
            return const CircularProgressIndicator();
          }
        });
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(String addressSeller) async {
    /*String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';*/
    
    var googleUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: "maps/place/$addressSeller",
    );
    if (await canLaunch("$googleUri")) {
      await launch("$googleUri");
    } else {
      throw 'Could not open the map.';
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
