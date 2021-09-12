import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/services/payment-service.dart';
import 'package:buyandbye/templates/Achat/pageResume.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:buyandbye/services/database.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../buyandbye_app_theme.dart';

class ExistingCardsPage extends StatefulWidget {
  final double total;
  final String idCommercant;
  final String userId;
  final String userAddress;
  final double deliveryChoose;
  ExistingCardsPage(
      {Key key,
      this.total,
      this.idCommercant,
      this.userAddress,
      this.deliveryChoose,
      this.userId})
      : super(key: key);

  @override
  ExistingCardsPageState createState() => ExistingCardsPageState();
}

class ExistingCardsPageState extends State<ExistingCardsPage> {
  String idCommand = Uuid().v4();
  List cards = [
    {
      'cardNumber': '4242424242424242',
      'expiryDate': '04/24',
      'cardHolderName': 'Test Visa',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '5555555555554444',
      'expiryDate': '04/23',
      'cardHolderName': 'Test Mastercard',
      'cvvCode': '123',
      'showBackView': false,
    }
  ];

  payViaExistingCard(BuildContext context, card) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Veuillez patienter...');
    await dialog.show();
    var expiryArr = card['expiryDate'].split('/');
    CreditCard stripeCard = CreditCard(
      number: card['cardNumber'],
      expMonth: int.parse(expiryArr[0]),
      expYear: int.parse(expiryArr[1]),
    );
    var response = await StripeService.payViaExistingCard(
        amount: (widget.total * 100).ceil().toString(),
        currency: 'EUR',
        card: stripeCard);

    if (response.success == true) {
      DatabaseMethods().acceptPayment(widget.idCommercant,
          widget.deliveryChoose, widget.total, widget.userAddress, idCommand);
    }
    await dialog.hide();
    Scaffold.of(context)
        .showSnackBar(SnackBar(
          content: Text(response.message),
          duration: new Duration(milliseconds: 1200),
        ))
        .closed
        .then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PageResume(
            idCommand: idCommand,
            sellerID: widget.idCommercant,
            userId: widget.userId,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veuillez choisir une carte'),
        backgroundColor: BuyandByeAppTheme.black_electrik,
        automaticallyImplyLeading: false,
        backwardsCompatibility: false, // 1
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (BuildContext context, int index) {
            var card = cards[index];
            return InkWell(
              onTap: () {
                payViaExistingCard(context, card);
              },
              child: CreditCardWidget(
                cardNumber: card['cardNumber'],
                expiryDate: card['expiryDate'],
                cardHolderName: card['cardHolderName'],
                cvvCode: card['cvvCode'],
                showBackView: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
