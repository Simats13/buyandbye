// ignore_for_file: deprecated_member_use

import 'package:buyandbye/templates/Paiement/add_credit_card.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
import 'package:buyandbye/templates/Achat/pageResume.dart';
import 'package:buyandbye/templates/Paiement/existing-cards.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccueilPaiement extends StatefulWidget {
  final double total;
  final String idCommercant;
  final String userId;
  final String userAddress;
  final double deliveryChoose;
  AccueilPaiement(
      {Key key,
      this.total,
      this.idCommercant,
      this.userAddress,
      this.deliveryChoose,
      this.userId})
      : super(key: key);

  @override
  AccueilPaiementState createState() => AccueilPaiementState();
}

class AccueilPaiementState extends State<AccueilPaiement> {
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  // ScrollController _controller = ScrollController();
  Map<String, dynamic> paymentIntentData;

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

  payViaNewCard(BuildContext context) async {
    print(widget.deliveryChoose);
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Veuillez patienter...');
    await dialog.show();
    print(widget.total.ceil() * 100);
    // var response = await StripeService.payWithNewCard(
    //   amount: (widget.total * 100).ceil().toString(),
    //   currency: 'EUR',
    // );

    // if (response.success == true) {
    //   DatabaseMethods().acceptPayment(widget.idCommercant,
    //       widget.deliveryChoose, widget.total, widget.userAddress, idCommand);
    // }

    var amount = (widget.total * 100).ceil().toString();
    final url = "https://api.stripe.com/v1/payment_intents";

    var secret =
        'sk_test_51Ida2rD6J4doB8CzdZn86VYvrau3UlTVmHIpp8rJlhRWMK34rehGQOxcrzIHwXfpSiHbCrZpzP8nNFLh2gybmb5S00RkMpngY8';

    Map<String, dynamic> body = {
      'amount': amount,
      'currency': "eur",
      'payment_method_types[]': 'card'
    };
    Map<String, String> headers = {
      'Authorization': 'Bearer $secret',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var response =
        await http.post(Uri.parse(url), body: body, headers: headers);
    paymentIntentData = json.decode(response.body);

    // print(response.request);

    // final response =
    //     await http.get(url, headers: {'Content-Type': 'application/json'});
    // print(response.headers);
    // paymentIntentData = json.decode(response.body.toString());

    // print(paymentIntentData);
    try {
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData['client_secret'],
              // applePay: true,
              // googlePay: true,
              customerId: paymentIntentData['customer'],
              customerEphemeralKeySecret: paymentIntentData['ephemeralKey'],
              style: ThemeMode.dark,
              merchantCountryCode: 'FR',
              testEnv: true,
              merchantDisplayName: 'Buy&Bye'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {});
    // displayPaymentSheet();
    print(paymentIntentData);
    await Stripe.instance.presentPaymentSheet();
    await dialog.hide();
    // Scaffold.of(context)
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
    //         userId: widget.userId,
    //       ),
    //     ),
    //   );
    // });
  }

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        "pk_test_51Ida2rD6J4doB8CzgG8J7yTDrm7TWqar81qa5Dqz2kG5NzK9rOTDLUTCNcTAc4BkMJHkGqdndvwqLgM2xvuLBTTy00B98cOCSL";
    Stripe.merchantIdentifier = 'merchant.buyandbye.fr';
    Stripe.instance.applySettings();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              Icon icon;
              Text text;

              switch (index) {
                case 0:
                  icon = Icon(Icons.add_circle, color: theme.primaryColor);
                  text = Text('Payer avec une nouvelle carte');
                  break;
                case 1:
                  icon = Icon(Icons.credit_card, color: theme.primaryColor);
                  text = Text('Payer avec une carte existante');
                  break;
                // case 2:
                //   icon = Icon(Icons.credit_card, color: theme.primaryColor);
                //   text = Text('Native Paiement');
              }

              return InkWell(
                onTap: () {
                  onItemPress(context, index);
                },
                child: ListTile(
                  title: text,
                  leading: icon,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
                  color: theme.primaryColor,
                ),
            itemCount: 2),
      ),
    );
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        paymentIntentData = null;
      });
    } catch (e) {
      print(e);
    }
  }
}
