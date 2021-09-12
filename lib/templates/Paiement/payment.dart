// import 'package:buyandbye/services/payment-service.dart';
// import 'package:uuid/uuid.dart';
// import 'package:flutter/material.dart';
// import 'package:buyandbye/services/database.dart';
// import 'package:buyandbye/templates/Achat/pageResume.dart';
// import 'package:buyandbye/templates/Paiement/existing-cards.dart';
// import 'package:progress_dialog/progress_dialog.dart';

// class AccueilPaiement extends StatefulWidget {
//   final double total;
//   final String idCommercant;
//   final String userId;
//   final String userAddress;
//   final double deliveryChoose;
//   AccueilPaiement(
//       {Key key,
//       this.total,
//       this.idCommercant,
//       this.userAddress,
//       this.deliveryChoose,
//       this.userId})
//       : super(key: key);

//   @override
//   AccueilPaiementState createState() => AccueilPaiementState();
// }

// class AccueilPaiementState extends State<AccueilPaiement> {
//   // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   // ScrollController _controller = ScrollController();
//   String idCommand = Uuid().v4();

//   onItemPress(BuildContext context, int index) async {
//     switch (index) {
//       case 0:
//         payViaNewCard(context);
//         break;
//       case 1:
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => ExistingCardsPage(
//                       userId: widget.userId,
//                       total: widget.total,
//                       idCommercant: widget.idCommercant,
//                       userAddress: widget.userAddress,
//                       deliveryChoose: widget.deliveryChoose,
//                     )));
//         break;
//       case 2:
//         RaisedButton(
//           child: Text("Native payment"),
//           onPressed: () {},
//         );
//     }
//   }

//   payViaNewCard(BuildContext context) async {
//     print(widget.deliveryChoose);
//     ProgressDialog dialog = new ProgressDialog(context);
//     dialog.style(message: 'Veuillez patienter...');
//     await dialog.show();
//     print(widget.total.ceil() * 100);
//     var response = await StripeService.payWithNewCard(
//       amount: (widget.total * 100).ceil().toString(),
//       currency: 'EUR',
//     );

//     if (response.success == true) {
//       DatabaseMethods().acceptPayment(widget.idCommercant,
//           widget.deliveryChoose, widget.total, widget.userAddress, idCommand);
//     }

//     await dialog.hide();
//     Scaffold.of(context)
//         .showSnackBar(SnackBar(
//           content: Text(response.message),
//           duration: new Duration(milliseconds: 1200),
//         ))
//         .closed
//         .then((_) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PageResume(
//             idCommand: idCommand,
//             sellerID: widget.idCommercant,
//             userId: widget.userId,
//           ),
//         ),
//       );
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     StripeService.init();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Paiement'),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(20),
//         child: ListView.separated(
//             itemBuilder: (context, index) {
//               Icon icon;
//               Text text;

//               switch (index) {
//                 case 0:
//                   icon = Icon(Icons.add_circle, color: theme.primaryColor);
//                   text = Text('Payer avec une nouvelle carte');
//                   break;
//                 case 1:
//                   icon = Icon(Icons.credit_card, color: theme.primaryColor);
//                   text = Text('Payer avec une carte existante');
//                   break;
//                 case 2:
//                   icon = Icon(Icons.credit_card, color: theme.primaryColor);
//                   text = Text('Native Paiement');
//               }

//               return InkWell(
//                 onTap: () {
//                   onItemPress(context, index);
//                 },
//                 child: ListTile(
//                   title: text,
//                   leading: icon,
//                 ),
//               );
//             },
//             separatorBuilder: (context, index) => Divider(
//                   color: theme.primaryColor,
//                 ),
//             itemCount: 3),
//       ),
//     );
//   }
// }
