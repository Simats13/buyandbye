import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../buyandbye_app_theme.dart';

class CreditCardAdd extends StatefulWidget {
  CreditCardAdd({Key key}) : super(key: key);

  @override
  _CreditCardAddState createState() => _CreditCardAddState();
}

class _CreditCardAddState extends State<CreditCardAdd> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyandByeAppTheme.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: RichText(
            text: TextSpan(
              // style: Theme.of(context).textTheme.bodyText2,
              children: [
                TextSpan(
                  text: 'Nouvelle Carte Bancaire',
                  style: TextStyle(
                    fontSize: 20,
                    color: BuyandByeAppTheme.orangeMiFonce,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                WidgetSpan(
                  child: Icon(
                    Icons.credit_card,
                    color: BuyandByeAppTheme.orangeFonce,
                    size: 25,
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
            icon: Icon(
              Icons.arrow_back,
              color: BuyandByeAppTheme.orange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              CreditCardWidget(
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CreditCardForm(
                        formKey: formKey,
                        obscureCvv: false,
                        obscureNumber: false,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        themeColor: Colors.black,
                        cardNumberDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'NUMERO DE LA CARTE',
                          hintText: 'XXXX XXXX XXXX XXXX',
                        ),
                        expiryDateDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "DATE",
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        cardHolderDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'NOM PRENOM',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          primary: Colors.black,
                        ),
                        child: Container(
                          margin: EdgeInsets.all(8),
                          child: Text(
                            'Enregistrer',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              package: 'flutter_credit_card',
                            ),
                          ),
                        ),
                        onPressed: () {
                          try {
                            if (formKey.currentState.validate()) {
                              print('valid!');
                              print(cardNumber);
                            } else {
                              print('invalid!');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
