import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/Pages/pageAddressEdit.dart';
import 'package:oficihome/templates/Pages/pageAddressNext.dart';
// import 'package:oficihome/templates/Pages/place_service.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:uuid/uuid.dart';
import 'package:truncate/truncate.dart';
import 'package:geocoder/geocoder.dart' as geocode;
// import 'address_search.dart';

class PageAddress extends StatefulWidget {
  const PageAddress({
    Key key,
    this.adresse,

    //Sthis.comments
  }) : super(key: key);

  final String adresse;

  get uid => null;

  @override
  _PageAddressState createState() => _PageAddressState();
}

class _PageAddressState extends State<PageAddress> {
  TextEditingController textController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // ignore: unused_field
  String _currentAddress;
  double latitude;
  double longitude;
  String adresseEntire;
  String userid;
  var currentLocation;
  var position;
  Geoflutterfire geo;
  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    _getLocation();
    userID();
  }

  userID() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
  }

  //FONCTION PERMETTANT DE RECUPERER L'ADRESSE POSTALE VIA LES COORDONNEES GPS DU TEL UTILISATEUR
  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude;
    longitude = position.longitude;
    final coordinates =
        new geocode.Coordinates(position.latitude, position.longitude);
    var addresses =
        await geocode.Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    adresseEntire = first.addressLine;

    setState(() {
      _currentAddress = "${first.featureName}, ${first.locality}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Mes Adresses",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
          child: SizedBox(
            height: 40,
            width: MediaQuery.of(context).size.width - 50,
            child: InkWell(
              onTap: () async {
                //generate a new token here
                // final sessionToken = Uuid().v4();
                // final Suggestion result = await showSearch(
                //   context: context,
                //   delegate: AddressSearch(sessionToken),
                // );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.15),
                ),
                padding: EdgeInsets.only(top: 5),
                child: Row(children: [
                  Icon(Icons.search),
                  Text(
                    "Saisir une nouvelle adresse",
                    textAlign: TextAlign.left,
                  ),
                ]),
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
          height: 5,
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 5),
              child: Container(
                child: Text("Proche de vous"),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: InkWell(
                  onTap: () async {
                    // affichageAdresse(latitude, longitude, adresseEntire);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PageAddressNext(
                                  lat: latitude,
                                  long: longitude,
                                  adresse: adresseEntire,
                                )));
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        Icon(Icons.near_me_rounded),
                        SizedBox(width: 10),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Position actuelle"),
                              SizedBox(height: 10),
                              Text(widget.adresse)
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Container(
                child: Text("Mes adresses enregistrées"),
              ),
            ),
          ],
        ),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(userid)
                .collection("Address")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 50,
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    geo = Geoflutterfire();
                                    GeoFirePoint center = geo.point(
                                        latitude: snapshot.data.docs[index]
                                            ["latitude"],
                                        longitude: snapshot.data.docs[index]
                                            ["longitude"]);
                                    stream = radius.switchMap((rad) {
                                      var collectionReference =
                                          FirebaseFirestore.instance
                                              .collection('magasins');
                                      return geo
                                          .collection(
                                              collectionRef:
                                                  collectionReference)
                                          .within(
                                              center: center,
                                              radius: 10,
                                              field: 'position',
                                              strictMode: true);
                                    });
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.place_rounded),
                                    SizedBox(width: 10),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 30),
                                          Container(
                                            child: Text(
                                              snapshot.data.docs[index]
                                                  ["addressName"],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            child: Text(truncate(
                                                snapshot.data.docs[index]
                                                    ["address"],
                                                35,
                                                omission: "...",
                                                position:
                                                    TruncatePosition.end)),
                                          ),
                                          SizedBox(height: 30),
                                        ]),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PageAddressEdit(
                                                      adresse: snapshot
                                                              .data.docs[index]
                                                          ["address"],
                                                      adressTitle: snapshot
                                                              .data.docs[index]
                                                          ["addressName"],
                                                      buildingDetails: snapshot
                                                              .data.docs[index]
                                                          ["buildingDetails"],
                                                      buildingName: snapshot
                                                              .data.docs[index]
                                                          ["buildingName"],
                                                      familyName: snapshot
                                                              .data.docs[index]
                                                          ["familyName"],
                                                      lat: snapshot
                                                              .data.docs[index]
                                                          ["latitude"],
                                                      long: snapshot
                                                              .data.docs[index]
                                                          ["longitude"],
                                                      iD: snapshot.data
                                                          .docs[index]["idDoc"],
                                                    )));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
              } else {
                return Container(child: Text("Pas d'adresses enregistrées"));
              }
            }),
      ],
    );
  }
}
