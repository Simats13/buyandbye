import 'dart:io';
import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/Achat/page_resume.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/page_address_edit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart'
    as platform;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../buyandbye_app_theme.dart';

class PageLivraison extends StatefulWidget {
  const PageLivraison(
      {Key? key, this.idCommercant, this.total, this.customerID, this.email})
      : super(key: key);
  final String? idCommercant, email, customerID;
  final double? total;

  @override
  _PageLivraisonState createState() => _PageLivraisonState();
}


class _PageLivraisonState extends State<PageLivraison> {
  String? val = "0";
  String? userid;
  String? nomBoutique;
  String? adresseBoutique;
  String productsList = "";
  double deliveryChoose = 0;
  String? userAddressChoose;
  double? latitude;
  double? longitude;
  String? emailUser, userName;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = <Marker>{};
  BitmapDescriptor? mapMarker;
  Map<String, dynamic>? paymentIntentData;
  List products = [];
  late double allMoneyForProduct;

  @override
  void initState() {
    super.initState();
    userID();
    getThisUserInfo();
    stripe.Stripe.publishableKey =
        "pk_test_51Ida2rD6J4doB8CzgG8J7yTDrm7TWqar81qa5Dqz2kG5NzK9rOTDLUTCNcTAc4BkMJHkGqdndvwqLgM2xvuLBTTy00B98cOCSL";
    stripe.Stripe.merchantIdentifier = 'merchant.buyandbye.fr';
    stripe.Stripe.instance.applySettings();
    initializeDateFormatting('fr_FR');
  }

  userID() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(userid);
    userName = "${querySnapshot.docs[0]["fname"]} ${querySnapshot.docs[0]["lname"]}";
  }

  getThisUserInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(widget.idCommercant);
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
      position: LatLng(latitude!, longitude!),
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
            const ImageConfiguration(), 'assets/images/shop.png')
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
            text: const TextSpan(
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
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                const Icon(Icons.arrow_back, color: BuyandByeAppTheme.orangeMiFonce),
            onPressed: () {
              Platform.isIOS
                  ? showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text("Annuler ma commande"),
                        content: const Text(
                            "Souhaitez-vous annuler votre commande et revenir à l'accueil ?"),
                        actions: [
                          // Close the dialog
                          CupertinoButton(
                              child: const Text('Non'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          CupertinoButton(
                            child: const Text(
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
                        title: const Text("Annuler ma commande"),
                        content: const Text(
                            "Souhaitez-vous annuler votre commande et revenir à l'accueil ?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Non"),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text(
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
                padding: const EdgeInsets.fromLTRB(20, 50, 0, 0),
                child: Column(
                  children: [
                    Row(children: const [
                      Text("Ma Commande : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      FutureBuilder<dynamic>(
                          future: DatabaseMethods()
                              .getCartProducts(widget.idCommercant),
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
                                      allMoneyForProduct = money * amount;

                                      products
                                          .add(snapshot.data.docs[index]["id"]);

                                      return Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
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
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 100,
                                                        child: Text(
                                                          snapshot.data
                                                                  .docs[index]
                                                              ["nomProduit"],
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "$allMoneyForProduct€",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "- $amount",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.total.toString() + "€",
                            style: const TextStyle(
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
              const SizedBox(height: 20),
              const Divider(
                color: Colors.black,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Row(children: const [
                            Text("Click & Collect",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                )),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text("Vendeur : " + nomBoutique!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: const [
                            Text("Adresse du magasin : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                )),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text(adresseBoutique!,
                                style: const TextStyle(
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
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Row(children: [
                  Center(
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        height: MediaQuery.of(context).size.height * (1 / 3),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(latitude!, longitude!),
                              zoom: 15.0),
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
                title: Text("Retrait en magasin chez " + nomBoutique!),
                value: "0",
                groupValue: val,
                onChanged: (v) => {
                  setState(() {
                    val = v as String?;
                    deliveryChoose = 0;
                    userAddressChoose = adresseBoutique;
                  })
                },
              ),
              const SizedBox(
                height: 15,
              ),
              const Divider(
                color: Colors.black,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          Row(children: const [
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
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text("Mes adresses enregistrées : "),
                              ),
                            ],
                          ),
                          StreamBuilder<dynamic>(
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
                                        return Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(00, 0, 0, 0),
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
                                                              const Icon(Icons
                                                                  .place_rounded),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                        height:
                                                                            30),
                                                                    Text(
                                                                        snapshot
                                                                      .data
                                                                      .docs[index]["addressName"],
                                                                      ),
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
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
                                                                        icon: const Icon(Icons.edit),
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
                                                                    ),
                                                                  ]),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      value: snapshot
                                                              .data.docs[index]
                                                          ["addressName"],
                                                      groupValue: val,
                                                      onChanged: (dynamic v) =>
                                                          {
                                                        setState(() {
                                                          val = v as String?;

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
                                  return const Text("Pas d'adresses enregistrées");
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
                              text: const TextSpan(
                                text: 'PASSER AU PAIEMENT',
                                style: TextStyle(
                                  fontSize: 15,
                                  // color: BuyandByeAppTheme.orangeMiFonce,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
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
                          const SizedBox(
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
      return const Center(
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

  String idCommand = const Uuid().v1();
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
              title: const Text("Paiement Annulé !"),
              content:
                  const Text("Le paiement a été annulé, souhaitez-vous réssayer ?"),
              actions: [
                // Close the dialog
                CupertinoButton(
                    child: const Text('Non'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                CupertinoButton(
                  child: const Text(
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
                            content: Text('Unforeseen error: $e'),
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
              title: const Text("Paiement Annulé !"),
              content: const Text(
                  "Souhaitez-vous annuler votre commande et revenir à l'accueil ?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("Non"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text(
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
                            content: Text('Unforeseen error: $e'),
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
    ProgressDialog dialog = ProgressDialog(context: context);
    dialog.show(
        max: 100,
        msg: 'Veuillez patienter ...',
        progressType: ProgressType.normal);

    var amount = (widget.total! * 100).ceil().toString();
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

    try {
      await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: platform.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['paymentIntent'],
              applePay: true,
              googlePay: true,
              customerId: widget.customerID,
              customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
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
      dialog.close();
      // 3. display the payment sheet.
      await stripe.Stripe.instance.presentPaymentSheet();

      final smtpServer = SmtpServer(
        "mail.buyandbye.fr",
        username: "no-reply@buyandbye.fr",
        password: "0Wz7Bg&n(}-lOjn3NJ",
      );
      QuerySnapshot querySnapshot =
          await DatabaseMethods().getCartProducts(widget.idCommercant);

      String? userchoose;

      if (deliveryChoose == 0) {
        userchoose = "Click & Collect";
      } else {
        userchoose = "Livraison à domicile";
      }

      String? numCommand = idCommand;
      DateTime now = DateTime.now();
      String? month = DateFormat('MMM').format(DateTime(0, now.month));
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        

        double totalPerProduct = querySnapshot.docs[i]['prixProduit'] * querySnapshot.docs[i]['amount'];

        productsList += """<tr>
                                        <td class='esdev-adapt-off' align='left'
                                            style='Margin:0;padding-top:10px;padding-bottom:10px;padding-left:20px;padding-right:20px'>
                                            <table cellpadding='0' cellspacing='0' class='esdev-mso-table'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;width:560px'>
                                                <tr>
                                                    <td class='esdev-mso-td' valign='top' style='padding:0;Margin:0'>
                                                        <table cellpadding='0' cellspacing='0' class='es-left'
                                                            align='left'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left'>
                                                            <tr>
                                                                <td class='es-m-p0r' align='center'
                                                                    style='padding:0;Margin:0;width:70px'>
                                                                    <table cellpadding='0' cellspacing='0' width='100%'
                                                                        role='presentation'
                                                                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                                        <tr>
                                                                            <td align='center'
                                                                                style='padding:0;Margin:0;font-size:0px'>
                                                                                <img class='adapt-img'
                                                                                    src='${querySnapshot.docs[i]['imgProduit']}'
                                                                                    alt
                                                                                    style='display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic'
                                                                                    width='70'></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td style='padding:0;Margin:0;width:20px'></td>
                                                    <td class='esdev-mso-td' valign='top' style='padding:0;Margin:0'>
                                                        <table cellpadding='0' cellspacing='0' class='es-left'
                                                            align='left'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left'>
                                                            <tr>
                                                                <td align='center'
                                                                    style='padding:0;Margin:0;width:265px'>
                                                                    <table cellpadding='0' cellspacing='0' width='100%'
                                                                        role='presentation'
                                                                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                                        <tr>
                                                                            <td align='left' style='padding:0;Margin:0'>
                                                                                <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                                    helvetica neue', helvetica,
                                                                                    sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                                    <strong>${querySnapshot.docs[i]['nomProduit']}</strong></p>
                                                                            </td>
                                                                        </tr>
                                                                     
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td style='padding:0;Margin:0;width:20px'></td>
                                                    <td class='esdev-mso-td' valign='top' style='padding:0;Margin:0'>
                                                        <table cellpadding='0' cellspacing='0' class='es-left'
                                                            align='left'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left'>
                                                            <tr>
                                                                <td align='left' style='padding:0;Margin:0;width:80px'>
                                                                    <table cellpadding='0' cellspacing='0' width='100%'
                                                                        role='presentation'
                                                                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                                        <tr>
                                                                            <td align='center'
                                                                                style='padding:0;Margin:0'>
                                                                                <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                                    helvetica neue', helvetica,
                                                                                    sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                                    ${querySnapshot.docs[i]['amount']}</p>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td style='padding:0;Margin:0;width:20px'></td>
                                                    <td class='esdev-mso-td' valign='top' style='padding:0;Margin:0'>
                                                        <table cellpadding='0' cellspacing='0' class='es-right'
                                                            align='right'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right'>
                                                            <tr>
                                                                <td align='left' style='padding:0;Margin:0;width:85px'>
                                                                    <table cellpadding='0' cellspacing='0' width='100%'
                                                                        role='presentation'
                                                                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                                        <tr>
                                                                            <td align='right'
                                                                                style='padding:0;Margin:0'>
                                                                                <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                                    helvetica neue', helvetica,
                                                                                    sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                                    $totalPerProduct €</p>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>""";
      }
      dialog.show(
          max: 100,
          msg: 'Veuillez patienter ...',
          progressType: ProgressType.normal);

      String? corpsDuMail = """<!DOCTYPE html
    PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xmlns:o='urn:schemas-microsoft-com:office:office' style='font-family:arial, '
    helvetica neue', helvetica, sans-serif'>

<head>
    <meta charset='UTF-8'>
    <meta content='width=device-width, initial-scale=1' name='viewport'>
    <meta name='x-apple-disable-message-reformatting'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <meta content='telephone=no' name='format-detection'>
    <title>Nouveau message</title>
    
</head>

<body style='width:100%;font-family:arial, ' helvetica neue', helvetica,
    sans-serif;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;padding:0;Margin:0'>
    <div class='es-wrapper-color' style='background-color:#FAFAFA'>

        <table class='es-wrapper' width='100%' cellspacing='0' cellpadding='0'
            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;padding:0;Margin:0;width:100%;height:100%;background-repeat:repeat;background-position:center top;background-color:#FAFAFA'>
            <tr>
                <td valign='top' style='padding:0;Margin:0'>
                    <table cellpadding='0' cellspacing='0' class='es-content' align='center'
                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%'>
                        <tr>
                            <td class='es-info-area' align='center' style='padding:0;Margin:0'>
                                <table class='es-content-body' align='center' cellpadding='0' cellspacing='0'
                                    style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:600px'
                                    bgcolor='#FFFFFF'>
                                    <tr>
                                        <td align='left' style='padding:20px;Margin:0'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td align='center' valign='top'
                                                        style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center' class='es-infoblock'
                                                                    style='padding:0;Margin:0;line-height:14px;font-size:12px;color:#CCCCCC'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:14px;color:#CCCCCC;font-size:12px'>
                                                                        <a target='_blank' href=''
                                                                            style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#CCCCCC;font-size:12px'>Voir en ligne</a></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table cellpadding='0' cellspacing='0' class='es-header' align='center'
                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top'>
                        <tr>
                            <td align='center' style='padding:0;Margin:0'>
                                <table bgcolor='#ffffff' class='es-header-body' align='center' cellpadding='0'
                                    cellspacing='0'
                                    style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:600px'>
                                    <tr>
                                        <td align='left' style='padding:20px;Margin:0'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td class='es-m-p0r' valign='top' align='center'
                                                        style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center'
                                                                    style='padding:0;Margin:0;padding-bottom:10px;font-size:0px'>
                                                                    <img src='https://uhnozf.stripocdn.email/content/guids/CABINET_93cd9874cb1f55af2357ac77c1a6622c/images/group_44_91E.png'
                                                                        alt='Logo'
                                                                        style='display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic;font-size:12px'
                                                                        width='200' title='Logo'></td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table cellpadding='0' cellspacing='0' class='es-content' align='center'
                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%'>
                        <tr>
                            <td align='center' style='padding:0;Margin:0'>
                                <table bgcolor='#ffffff' class='es-content-body' align='center' cellpadding='0'
                                    cellspacing='0'
                                    style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#FFFFFF;width:600px'>
                                    <tr>
                                        <td align='left'
                                            style='padding:0;Margin:0;padding-top:15px;padding-left:20px;padding-right:20px'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td align='center' valign='top'
                                                        style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center'
                                                                    style='padding:0;Margin:0;padding-top:10px;padding-bottom:10px;font-size:0px'>
                                                                    <img src='https://uhnozf.stripocdn.email/content/guids/CABINET_54100624d621728c49155116bef5e07d/images/84141618400759579.png'
                                                                        alt
                                                                        style='display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic'
                                                                        width='100'></td>
                                                            </tr>
                                                            <tr>
                                                                <td align='center' class='es-m-txt-c'
                                                                    style='padding:0;Margin:0;padding-bottom:10px'>
                                                                    <h1 style='Margin:0;line-height:46px;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;font-size:46px;font-style:normal;font-weight:bold;color:#333333'>
                                                                        Confirmation de commande</h1>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table cellpadding='0' cellspacing='0' class='es-content' align='center'
                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%'>
                        <tr>
                            <td align='center' style='padding:0;Margin:0'>
                                <table bgcolor='#ffffff' class='es-content-body' align='center' cellpadding='0'
                                    cellspacing='0'
                                    style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:#FFFFFF;width:600px'>
                                    <tr>
                                        <td align='left' style='padding:20px;Margin:0'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td align='center' valign='top'
                                                        style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center' class='es-m-txt-c'
                                                                    style='padding:0;Margin:0'>
                                                                    <h2 style='Margin:0;line-height:31px;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;font-size:26px;font-style:normal;font-weight:bold;color:#333333'>
                                                                        N°<a target='_blank' href=''
                                                                            style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#5C68E2;font-size:26px'>$numCommand</a>
                                                                    </h2>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align='center' class='es-m-p0r es-m-p0l'
                                                                    style='Margin:0;padding-top:5px;padding-bottom:5px;padding-left:40px;padding-right:40px'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        ${now.day} $month, ${now.year}</p>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align='center' class='es-m-p0r es-m-p0l'
                                                                    style='Margin:0;padding-top:5px;padding-bottom:15px;padding-left:40px;padding-right:40px'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Ceci est un email de confirmation, vous recevrez
                                                                        d'autres emails lorsque le statut de votre
                                                                        commande sera mis à jour.</p>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align='center' style='padding:0;Margin:0'><span
                                                                        class='es-button-border'
                                                                        style='border-style:solid;border-color:#5c68e2;background:#5c68e2;border-width:2px;display:inline-block;border-radius:6px;width:auto'><a
                                                                            href='' class='es-button' target='_blank'
                                                                            style='mso-style-priority:100 !important;text-decoration:none;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;color:#FFFFFF;font-size:20px;border-style:solid;border-color:#5C68E2;border-width:10px 30px 10px 30px;display:inline-block;background:#5C68E2;border-radius:6px;font-family:arial, '
                                                                            helvetica neue', helvetica,
                                                                            sans-serif;font-weight:normal;font-style:normal;line-height:24px;width:auto;text-align:center;border-left-width:30px;border-right-width:30px'>SUIVRE
                                                                            MA COMMANDE</a></span></td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    $productsList
                                    
                                    <tr>
                                        <td align='left'
                                            style='padding:0;Margin:0;padding-top:10px;padding-left:20px;padding-right:20px'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td class='es-m-p0r' align='center'
                                                        style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;border-top:2px solid #efefef;border-bottom:2px solid #efefef'
                                                            role='presentation'>
                                                            <tr>
                                                                <td align='right' class='es-m-txt-r'
                                                                    style='padding:0;Margin:0;padding-top:10px;padding-bottom:20px'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Sous-Total :&nbsp;<strong>€40.00</strong><br>Livraison :&nbsp;<strong>€0.00</strong><br>Taxe :&nbsp;<strong>€10.00</strong><br>Total :&nbsp;<strong>${widget.total.toString()} €</strong>
                                                                    </p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align='left'
                                            style='Margin:0;padding-bottom:10px;padding-top:20px;padding-left:20px;padding-right:20px'>
                                            <!--[if mso]><table style='width:560px' cellpadding='0' cellspacing='0'><tr><td style='width:280px' valign='top'><![endif]-->
                                            <table cellpadding='0' cellspacing='0' class='es-left' align='left'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:left'>
                                                <tr>
                                                    <td class='es-m-p0r es-m-p20b' align='center'
                                                        style='padding:0;Margin:0;width:280px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='left' style='padding:0;Margin:0'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Client : <strong>${widget.email}</strong>
                                                                    </p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Vendeur : <strong>$nomBoutique</strong>
                                                                    </p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Numéro&nbsp;de
                                                                        commande:&nbsp;<strong>$numCommand</strong></p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Date d'achat:&nbsp;<strong> ${now.day} $month, ${now.year}</strong>
                                                                    </p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Méthode de
                                                                        paiement:&nbsp;<strong>Par CB</strong></p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Devise:&nbsp;<strong>EUR</strong></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <!--[if mso]></td><td style='width:0px'></td><td style='width:280px' valign='top'><![endif]-->
                                            <table cellpadding='0' cellspacing='0' class='es-right' align='right'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;float:right'>
                                                <tr>
                                                    <td class='es-m-p0r' align='center'
                                                        style='padding:0;Margin:0;width:280px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='left' class='es-m-txt-l'
                                                                    style='padding:0;Margin:0'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Méthode d'envoi: <strong>$userchoose</strong>
                                                                    </p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Adresse de livraison:</p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        <strong>$userName,<br>$userAddressChoose</strong></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <!--[if mso]></td></tr></table><![endif]-->
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align='left'
                                            style='Margin:0;padding-bottom:10px;padding-top:15px;padding-left:20px;padding-right:20px'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td align='left' style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center'
                                                                    style='padding:0;Margin:0;padding-top:10px;padding-bottom:10px'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:21px;color:#333333;font-size:14px'>
                                                                        Vous avez une quesition ?&nbsp;Envoyez nous un
                                                                        email à&nbsp;<a target='_blank'
                                                                            href='mailto:support@buyandbye.fr'
                                                                            style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#5C68E2;font-size:14px'>support@buyandbye.fr</a>&nbsp;ou
                                                                        bien n'hésitez pas à consulter notre FAQ !</p>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align='center' style='padding:0;Margin:0'><span
                                                                        class='es-button-border'
                                                                        style='border-style:solid;border-color:#2CB543;background:#5C68E2;border-width:0px;display:inline-block;border-radius:5px;width:auto'><a
                                                                            href='https://buyandbye.fr'
                                                                            class='es-button' target='_blank'
                                                                            style='mso-style-priority:100 !important;text-decoration:none;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;color:#FFFFFF;font-size:20px;border-style:solid;border-color:#5C68E2;border-width:10px 30px 10px 30px;display:inline-block;background:#5C68E2;border-radius:5px;font-family:arial, '
                                                                            helvetica neue', helvetica,
                                                                            sans-serif;font-weight:normal;font-style:normal;line-height:24px;width:auto;text-align:center'>Accéder
                                                                            à la FAQ</a></span></td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table cellpadding='0' cellspacing='0' class='es-footer' align='center'
                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%;background-color:transparent;background-repeat:repeat;background-position:center top'>
                        <tr>
                            <td align='center' style='padding:0;Margin:0'>
                                <table class='es-footer-body' align='center' cellpadding='0' cellspacing='0'
                                    style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:640px'>
                                    <tr>
                                        <td align='left'
                                            style='Margin:0;padding-top:20px;padding-bottom:20px;padding-left:20px;padding-right:20px'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td align='left' style='padding:0;Margin:0;width:600px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center'
                                                                    style='padding:0;Margin:0;padding-top:15px;padding-bottom:15px;font-size:0'>
                                                                    <table cellpadding='0' cellspacing='0'
                                                                        class='es-table-not-adapt es-social'
                                                                        role='presentation'
                                                                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                                        <tr>
                                                                            <td align='center' valign='top'
                                                                                style='padding:0;Margin:0'><a
                                                                                    target='_blank'
                                                                                    href='https://www.instagram.com/buyandbyefr/'
                                                                                    style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#333333;font-size:12px'><img
                                                                                        title='Instagram'
                                                                                        src='https://uhnozf.stripocdn.email/content/assets/img/social-icons/logo-black/instagram-logo-black.png'
                                                                                        alt='Inst' width='32'
                                                                                        style='display:block;border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic'></a>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align='center'
                                                                    style='padding:0;Margin:0;padding-bottom:35px'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:18px;color:#333333;font-size:12px'>
                                                                        Buy&amp;Bye © 2021 DTHE. Tout Droit Réservé.</p>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:18px;color:#333333;font-size:12px'>
                                                                        <br></p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <table cellpadding='0' cellspacing='0' class='es-content' align='center'
                        style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;table-layout:fixed !important;width:100%'>
                        <tr>
                            <td class='es-info-area' align='center' style='padding:0;Margin:0'>
                                <table class='es-content-body' align='center' cellpadding='0' cellspacing='0'
                                    style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px;background-color:transparent;width:600px'
                                    bgcolor='#FFFFFF'>
                                    <tr>
                                        <td align='left' style='padding:20px;Margin:0'>
                                            <table cellpadding='0' cellspacing='0' width='100%'
                                                style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                <tr>
                                                    <td align='center' valign='top'
                                                        style='padding:0;Margin:0;width:560px'>
                                                        <table cellpadding='0' cellspacing='0' width='100%'
                                                            role='presentation'
                                                            style='mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse;border-spacing:0px'>
                                                            <tr>
                                                                <td align='center' class='es-infoblock'
                                                                    style='padding:0;Margin:0;line-height:14px;font-size:12px;color:#CCCCCC'>
                                                                    <p style='Margin:0;-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;font-family:arial, '
                                                                        helvetica neue', helvetica,
                                                                        sans-serif;line-height:14px;color:#CCCCCC;font-size:12px'>
                                                                        <a target='_blank' href=''
                                                                            style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#CCCCCC;font-size:12px'></a>Vous ne souhaitez plus recevoir d'email ?&nbsp;<a
                                                                            href='' target='_blank'
                                                                            style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#CCCCCC;font-size:12px'>Désinscrivez-vous</a>.<a
                                                                            target='_blank' href=''
                                                                            style='-webkit-text-size-adjust:none;-ms-text-size-adjust:none;mso-line-height-rule:exactly;text-decoration:underline;color:#CCCCCC;font-size:12px'></a>
                                                                    </p>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>

</html>""";


      final message = Message()
        ..from = const Address("no-reply@buyandbye.fr", 'Buy&Bye')
        ..recipients.add(widget.email)
        ..subject = 'Résumé de votre commande du ${now.day} $month, ${now.year}'
        ..html = corpsDuMail;

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
      DatabaseMethods().acceptPayment(widget.idCommercant, deliveryChoose,
          widget.total, userAddressChoose, idCommand);

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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: $e'),
          ),
        );
      }
    }
  }
}

//////////////////////////////////////////////////////////////////////
//////////////////////// FIN PAIEMENT ////////////////////////////////
//////////////////////////////////////////////////////////////////////

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
