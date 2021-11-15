import 'dart:io';

import 'package:buyandbye/templates/Achat/pageResume.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/pageAddressEdit.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart'
    as platform;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:truncate/truncate.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../buyandbye_app_theme.dart';

class PageLivraison extends StatefulWidget {
  const PageLivraison(
      {Key key, this.idCommercant, this.total, this.customerID, this.email})
      : super(key: key);
  final String idCommercant, email;
  final String customerID;
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
  String emailUser;
  GoogleMapController _mapController;
  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor mapMarker;
  Map<String, dynamic> paymentIntentData;

  @override
  void initState() {
    super.initState();
    userID();
    getThisUserInfo();
    stripe.Stripe.publishableKey =
        "pk_test_51Ida2rD6J4doB8CzgG8J7yTDrm7TWqar81qa5Dqz2kG5NzK9rOTDLUTCNcTAc4BkMJHkGqdndvwqLgM2xvuLBTTy00B98cOCSL";
    stripe.Stripe.merchantIdentifier = 'merchant.buyandbye.fr';
    stripe.Stripe.instance.applySettings();
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
            ImageConfiguration(), '../../assets/images/shop.png')
        .then((value) {
      mapMarker = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nomBoutique != null) {
      return Scaffold(
        backgroundColor: BuyandByeAppTheme.white,
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              // style: Theme.of(context).textTheme.bodyText2,
              children: [
                TextSpan(
                    text: 'Livraison',
                    style: TextStyle(
                      fontSize: 20,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.local_shipping,
                      color: BuyandByeAppTheme.orangeFonce,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: BuyandByeAppTheme.white,
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: BuyandByeAppTheme.orangeMiFonce),
            onPressed: () {
              Platform.isIOS
                  ? showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text("Annuler ma commande"),
                        content: Text(
                            "Souhaitez-vous annuler votre commande et revenir à l'accueil ?"),
                        actions: [
                          // Close the dialog
                          CupertinoButton(
                              child: Text('Non'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          CupertinoButton(
                            child: Text(
                              'Oui',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    )
                  : showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Annuler ma commande"),
                        content: Text(
                            "Souhaitez-vous annuler votre commande et revenir à l'accueil ?"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Non"),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text(
                              'Oui',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
            },
          ),
          elevation: 0.0,
          bottomOpacity: 0.0,
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
                          future: DatabaseMethods().getCartProducts(widget.idCommercant),
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
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width - 200,
                                                                          child:
                                                                              Text(
                                                                            snapshot.data.docs[index]["address"],
                                                                          ),
                                                                        ),
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
                                                          latitude = snapshot
                                                                  .data
                                                                  .docs[index]
                                                              ["latitude"];
                                                          longitude = snapshot
                                                                  .data
                                                                  .docs[index]
                                                              ["longitude"];
                                                          deliveryChoose = 2;
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
                              payViaNewCard(context);
                            },
                            color: Colors.deepOrangeAccent,
                            height: 50,
                            minWidth: MediaQuery.of(context).size.width - 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            child: RichText(
                              text: TextSpan(
                                text: 'PASSER AU PAIEMENT',
                                style: TextStyle(
                                  fontSize: 15,
                                  // color: BuyandByeAppTheme.orangeMiFonce,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: Icon(
                                        Icons.credit_card,
                                        color: BuyandByeAppTheme.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

//////////////////////////////////////////////////////////////////
//////////////////////// PAIEMENT ////////////////////////////////
//////////////////////////////////////////////////////////////////

  // Future<void> displayPaymentSheet() async {
  //   try {
  //     await stripe.Stripe.instance.presentPaymentSheet();
  //     setState(() {
  //       paymentIntentData = null;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  String idCommand = Uuid().v4();
  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        payViaNewCard(context);
        break;
      // case 1:
      //   cardExisting();
      //   break;
    }
  }

  dialogPaymentCancelled() {
    Platform.isIOS
        ? showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text("Paiement Annulé !"),
              content:
                  Text("Le paiement a été annulé, souhaitez-vous réssayer ?"),
              actions: [
                // Close the dialog
                CupertinoButton(
                    child: Text('Non'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                CupertinoButton(
                  child: Text(
                    'Oui',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // await dialog.show();
                    try {
                      await stripe.Stripe.instance.presentPaymentSheet();
                    } on Exception catch (e) {
                      if (e is stripe.StripeException) {
                        if (e.error.localizedMessage ==
                            "The payment has been canceled") {
                          dialogPaymentCancelled();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unforeseen error: ${e}'),
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          )
        : showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Paiement Annulé !"),
              content: Text(
                  "Souhaitez-vous annuler votre commande et revenir à l'accueil ?"),
              actions: <Widget>[
                TextButton(
                  child: Text("Non"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Oui',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await stripe.Stripe.instance.presentPaymentSheet();
                    } on Exception catch (e) {
                      if (e is stripe.StripeException) {
                        if (e.error.localizedMessage ==
                            "The payment has been canceled") {
                          dialogPaymentCancelled();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unforeseen error: ${e}'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
  }

  payViaNewCard(BuildContext context) async {
    print(deliveryChoose);
    ProgressDialog dialog = new ProgressDialog(context,isDismissible: false);
    dialog.style(message: 'Veuillez patienter...');
    await dialog.show();
    print(widget.total.ceil() * 100);

    var amount = (widget.total * 100).ceil().toString();
    final url =
        "https://us-central1-oficium-11bf9.cloudfunctions.net/app/payment-sheet?amount=$amount&customers=${widget.customerID}";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'a': 'a',
      }),
    );
    paymentIntentData = json.decode(response.body.toString());
    dialog.hide();
    try {
      await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: platform.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['paymentIntent'],
              applePay: true,
              googlePay: true,
              customerId: widget.customerID,
              customerEphemeralKeySecret: paymentIntentData['ephemeralKey'],
              style: ThemeMode.system,
              merchantCountryCode: 'FR',
              testEnv: true,
              merchantDisplayName: 'Buy&Bye'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    // print(paymentIntentData);

    setState(() {});

    try {
      // 3. display the payment sheet.
      await stripe.Stripe.instance.presentPaymentSheet();
 await dialog.show();
      DatabaseMethods().acceptPayment(widget.idCommercant, deliveryChoose,
          widget.total, userAddressChoose, idCommand);

      //ENVOI D'UN MAIL

      final smtpServer = SmtpServer(
        "mail.buyandbye.fr",
        username: "no-reply@buyandbye.fr",
        password: "0Wz7Bg&n(}-lOjn3NJ",
      );

      final message = Message()
        ..from = Address("no-reply@buyandbye.fr", 'Buy&Bye')
        ..recipients.add(widget.email)
        ..subject = 'Résumé de votre commande du ${DateTime.now()}'
        ..html = "<h1>Résumé</h1>\n<p>Hey! Here's some HTML content</p>";

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
     

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PageResume(
            deliveryChoose: deliveryChoose,
            idCommand: idCommand,
            sellerID: widget.idCommercant,
            userId: userid,
            latitude: latitude,
            longitude: longitude,
            nomBoutique: nomBoutique,
            addressSeller: adresseBoutique,
            userAddressChoose: userAddressChoose,
          ),
        ),
      );
    } on Exception catch (e) {
      if (e is stripe.StripeException) {
        if (e.error.localizedMessage == "The payment has been canceled") {
          dialogPaymentCancelled();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error from Stripe: ${e.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: ${e}'),
          ),
        );
      }
    }

    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(
    //       content: Text("response"),
    //       duration: new Duration(milliseconds: 1200),
    //     ))
    //     .closed
    //     .then((_) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => PageResume(
    //         idCommand: idCommand,
    //         sellerID: widget.idCommercant,
    //         userId: userid,
    //       ),
    //     ),
    //   );
    // });
  }
}

//////////////////////////////////////////////////////////////////////
//////////////////////// FIN PAIEMENT ////////////////////////////////
//////////////////////////////////////////////////////////////////////

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
