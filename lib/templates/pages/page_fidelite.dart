import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PageFidelite extends StatefulWidget {
  @override
  const PageFidelite({Key? key, this.firstName, this.lastName, this.eMail})
      : super(key: key);

  final String? firstName;
  final String? lastName;
  final String? eMail;
  @override
  _PageFideliteState createState() => _PageFideliteState();
}

class _PageFideliteState extends State<PageFidelite> {
  String? userid;

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyandByeAppTheme.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text: 'Compte Fidélité',
                    style: TextStyle(
                      fontSize: 20,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.card_giftcard_outlined,
                      color: BuyandByeAppTheme.orangeMiFonce,
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
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20),
            child: Text(
              "Fidéliser vos achats",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // membershipCard(),

          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                width: 250,
                child: Text(
                  "Grâce à notre carte de fidélité, profitez de vos magasins et produits préférés à petits prix ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Comment gagner des points de fidélité ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                width: 250,
                child: Text(
                  "C'est simple !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                width: 250,
                child: Text(
                  "1€ = 5 point",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text.rich(TextSpan(text: "Dès "),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            )),
                        Text.rich(
                          TextSpan(text: "200 points "),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Text.rich(
                      TextSpan(
                          text:
                              "tu peux les utiliser afin de réduire le prix de tes produits préférés !"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // membershipCard() {
  //   return Container(
  //     child: FlipCard(
  //       direction: FlipDirection.HORIZONTAL,
  //       front: Padding(
  //         padding: const EdgeInsets.all(20.0),
  //         child: Container(
  //           height: 200,
  //           width: 200,
  //           padding: EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             image: DecorationImage(
  //               image: AssetImage("assets/images/cardBuy&Bye.png"),
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //           child: Column(
  //             children: [
  //               Container(
  //                 margin: EdgeInsets.fromLTRB(20, 125, 0, 0),
  //                 child: Row(children: [
  //                   Text(widget.firstName! + " " + widget.lastName!,
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w500,
  //                       )),
  //                   SizedBox(
  //                     width: 50,
  //                   ),
  //                   Container(
  //                     child: Text("180 pts",
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.w600,
  //                         )),
  //                   ),
  //                 ]),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       back: Padding(
  //         padding: const EdgeInsets.all(20.0),
  //         child: Container(
  //           height: 200,
  //           width: 200,
  //           padding: EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             image: DecorationImage(
  //               image: AssetImage("assets/images/cardBuy&ByeReverse.png"),
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //           child: Column(
  //             children: [
  //               Container(
  //                 child: QrImage(
  //                   foregroundColor: Colors.white,
  //                   data: "buyandbye.fr",
  //                   version: QrVersions.auto,
  //                   size: 150,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
