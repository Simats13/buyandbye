// // import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:stripe_payment/stripe_payment.dart';
// // import 'package:http/http.dart' as http;

// // class PaimentStripe extends StatefulWidget {
// //   final double total;
// //   const PaimentStripe({key, this.total}) : super(key: key);

// //   @override
// //   _PaimentStripeState createState() => _PaimentStripeState();
// // }

// // class _PaimentStripeState extends State<PaimentStripe> {
// //   bool isLoading = false;
// //   int amount = 0;
// //   @override
// //   void initState() {
// //     // TODO: implement initState
// //     super.initState();
// //     StripePayment.setOptions(StripeOptions(
// //         publishableKey:
// //             "pk_test_51Ida2rD6J4doB8CzgG8J7yTDrm7TWqar81qa5Dqz2kG5NzK9rOTDLUTCNcTAc4BkMJHkGqdndvwqLgM2xvuLBTTy00B98cOCSL",
// //         merchantId: "merchant.buyandbye.fr",
// //         androidPayMode: 'test'));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Paiement"),
// //       ),
// //       body: Center(
// //         child: ElevatedButton(
// //           onPressed: () {
// //             startPayment();
// //           },
// //           child: Text("Paiement"),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> startPayment() async {
// //     StripePayment.setStripeAccount(null);
// //     amount = (widget.total * 100).toInt();

// //     PaymentMethod paymentMethod = PaymentMethod();
// //     paymentMethod = await StripePayment.paymentRequestWithCardForm(
// //       CardFormPaymentRequest(),
// //     ).then((PaymentMethod paymentMethod) {
// //       return paymentMethod;
// //     }).catchError((e) {
// //       print(e);
// //     });
// //     startDirectCharge(paymentMethod);
// //   }

// //   Future<void> startDirectCharge(PaymentMethod paymentMethod) async {
// //     print('Payment charge started');

// //     final http.Response response = await http.post(Uri.parse());

// //     if (response.body != null) {
// //       final paymentIntent = jsonDecode(response.body);
// //       final status = paymentIntent['paymentIntent']['status'];
// //       final acct = paymentIntent['stripeAccount'];

// //       if (status == 'succeeded') {
// //         print("payment done");
// //       } else {
// //         StripePayment.setStripeAccount(acct);
// //         await StripePayment.confirmPaymentIntent(PaymentIntent(
// //           paymentMethodId: paymentIntent['paymentIntent']['payment_method'],
// //           clientSecret: paymentIntent['paymentIntent']['client_secret'],
// //         )).then((PaymentIntentResult paymentIntentResult) async {
// //           final paymentStatus = paymentIntentResult.status;
// //           if (paymentStatus == 'succeeded') {
// //             print('payment done');
// //           }
// //         });
// //       }
// //     }
// //   }
// // }

// // main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // set the publishable key for Stripe - this is mandatory
//   Stripe.publishableKey =
//       "pk_test_51Ida2rD6J4doB8CzgG8J7yTDrm7TWqar81qa5Dqz2kG5NzK9rOTDLUTCNcTAc4BkMJHkGqdndvwqLgM2xvuLBTTy00B98cOCSL";
//   runApp(PaymentScreen());
// }

// // payment_screen.dart
// class PaymentScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           CardField(
//             onCardChanged: (card) {
//               print(card);
//             },
//           ),
//           TextButton(
//             onPressed: () async {
//               // create payment method
//               final paymentMethod = await Stripe.instance
//                   .createPaymentMethod(PaymentMethodParams.card());
//             },
//             child: Text('pay'),
//           )
//         ],
//       ),
//     );
//   }
// }
