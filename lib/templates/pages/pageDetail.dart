import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:buyandbye/json/menu_json.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Pages/chatscreen.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:buyandbye/templates/Pages/cart.dart';
import 'package:buyandbye/theme/styles.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/pages/pageProduit.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

import 'dart:async';

import '../Messagerie/Controllers/fb_messaging.dart';
import '../Messagerie/subWidgets/local_notification_view.dart';

class PageDetail extends StatefulWidget {
  const PageDetail(
      {Key key,
      this.img,
      this.name,
      this.description,
      this.adresse,
      this.clickAndCollect,
      this.livraison,
      this.sellerID,
      this.colorStore})
      : super(key: key);

  final String img;
  final String name;
  final String description;
  final String adresse;
  final String sellerID;
  final String colorStore;
  final bool livraison;
  final bool clickAndCollect;
  _PageDetail createState() => _PageDetail();
}

class _PageDetail extends State<PageDetail> with LocalNotificationView {
  double cartTotal = 0.0;
  double cartDeliver = 0.0;
  String myID,
      myName,
      myProfilePic,
      myUserName,
      myEmail,
      selectedUserToken,
      name1,
      message,
      dropdownValue;
  Stream usersStream, chatRoomsStream;
  String userid;
  Stream<List<DocumentSnapshot>> stream;
  List listOfCategories = [];
  List<DocumentSnapshot> _myDocCount = [];
  @override
  void initState() {
    super.initState();
    getMyInfo();
    getSellerInfo();
    categoriesInDb();
    countCart();
    NotificationController.instance.updateTokenToServer();
    if (mounted) {
      checkLocalNotification(localNotificationAnimation, "");
    }
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myName = "${querySnapshot.docs[0]["fname"]}" +
        "${querySnapshot.docs[0]["lname"]}";
    myProfilePic = "${querySnapshot.docs[0]["imgUrl"]}";
    myEmail = "${querySnapshot.docs[0]["email"]}";
    bool cartEmpty = await DatabaseMethods().checkCartEmpty();
    print(cartEmpty);
  }

  getSellerInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(widget.sellerID);
    selectedUserToken = "${querySnapshot.docs[0]["FCMToken"]}";
    setState(() {});
  }

  countCart() async {
    QuerySnapshot _myDoc = await DatabaseMethods().getCartProducts(widget.sellerID);
    _myDocCount = _myDoc.docs;
    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  void localNotificationAnimation(List<dynamic> data) {
    if (mounted) {
      setState(() {
        if (data[1] == 1.0) {
          localNotificationData = data[0];
        }
        localNotificationAnimationOpacity = data[1] as double;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: getFooter(),
      body: getBody(),
    );
  }

  categoriesInDb() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("magasins")
        .doc(widget.sellerID)
        .collection("produits")
        .get();
    // name1 = "${querySnapshot.docs[0]["nom"]}";
    // setState(() {});

    // Pour chaque produit dans la bdd, ajoute le nom de la catégorie s'il n'est
    // pas déjà dans la liste
    for (var i = 0; i <= querySnapshot.docs.length - 1; i++) {
      String categoryName = querySnapshot.docs[i]["categorie"];
      if (!listOfCategories.contains(categoryName)) {
        listOfCategories.add(querySnapshot.docs[i]["categorie"]);
      }
    }
    setState(() {
      dropdownValue = listOfCategories[0];
    });
  }

  Widget getFooter() {
    var pimpMyStore = widget.colorStore;
    var size = MediaQuery.of(context).size;
    bool isPressed = false;
    return Stack(children: [
      GestureDetector(
          onTap: () {
            affichageCart();
          },
          child: Container(
            height: 60,
            width: size.width,
            decoration: BoxDecoration(
              color: white,
              border: Border(top: BorderSide(color: black.withOpacity(0.1))),
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    _myDocCount.length == 0
                        ? "PANIER"
                        : "PANIER (${_myDocCount.length})",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(int.parse("0x$pimpMyStore"))
                            .withOpacity(0.8)),
                  )
                ],
              ),
            ),
          ))
    ]);
  }

  // La variable avant le Widget sinon elle n'est pas modifiée dynamiquement
  // String dropdownValue = 'Alimentation';
  int clickedNumber = 1;
  Widget getBody() {
    var pimpMyStore = widget.colorStore;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    bool isPressed = false;
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          Color(int.parse("0x$pimpMyStore")).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          Color(int.parse("0x$pimpMyStore")).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Navigator.pop(context);
                  },
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: size.width,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: Image(
                      image: NetworkImage(widget.img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text(
                      //   widget.name,
                      //   style: TextStyle(
                      //       fontSize: 21, fontWeight: FontWeight.bold),
                      // ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: textFieldColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text(
                                    "Click and Collect",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Icon(
                                    widget.clickAndCollect
                                        ? Icons.check_circle
                                        : Icons.highlight_off,
                                    color: widget.clickAndCollect
                                        ? Colors.green
                                        : Colors.red,
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: textFieldColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text(
                                    "Livraison",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Icon(
                                    widget.livraison
                                        ? Icons.check_circle
                                        : Icons.highlight_off,
                                    color: widget.livraison
                                        ? Colors.green
                                        : Colors.red,
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Map<String, dynamic> chatRoomInfoMap = {
                            "users": [myID, widget.sellerID],
                          };
                          DatabaseMethods().createChatRoom(
                              widget.sellerID + myID, chatRoomInfoMap);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatRoom(
                                      myID, //ID DE L'UTILISATEUR
                                      myName, // NOM DE L'UTILISATEUR
                                      selectedUserToken,
                                      widget.sellerID, // TOKEN DU CORRESPONDANT
                                      widget.sellerID + myID, //ID DE LA CONV
                                      widget.name, // NOM DU CORRESPONDANT
                                      "", // LES COMMERCANTS N'ONT PAS DE LNAME
                                      widget.img, // IMAGE DU CORRESPONDANT
                                      myProfilePic // IMAGE DE L'UTILISATEUR
                                      )));
                        },
                        child: Icon(
                          Icons.message,
                          color: Color(int.parse("0x$pimpMyStore"))
                              .withOpacity(0.8),
                          size: 25,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        width: size.width - 30,
                        child: Text(
                          widget.description,
                          style: TextStyle(fontSize: 14, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: textFieldColor,
                      //     borderRadius: BorderRadius.circular(3),
                      //   ),
                      //   child: Padding(
                      //     padding: EdgeInsets.all(5),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           widget.rate,
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: 3,
                      //         ),
                      //         Icon(
                      //           Icons.star,
                      //           color: yellowStar,
                      //           size: 17,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: 8,
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: textFieldColor,
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Padding(
                      //     padding: EdgeInsets.all(5),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           "Click and Collect",
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: 3,
                      //         ),
                      //         Icon(
                      //           widget.clickAndCollect
                      //               ? Icons.check_circle
                      //               : Icons.highlight_off,
                      //           color: widget.clickAndCollect
                      //               ? Colors.green
                      //               : Colors.red,
                      //           size: 17,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   width: 8,
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: textFieldColor,
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Padding(
                      //     padding: EdgeInsets.all(5),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           "Livraison",
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: 3,
                      //         ),
                      //         Icon(
                      //           widget.livraison
                      //               ? Icons.check_circle
                      //               : Icons.highlight_off,
                      //           color: widget.livraison
                      //               ? Colors.green
                      //               : Colors.red,
                      //           size: 17,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: black.withOpacity(0.3),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Informations de la boutique",
                    style: customContent,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        width: (size.width) * 0.8,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/pin_icon.svg",
                              width: 15,
                              color: Color(int.parse("0x$pimpMyStore"))
                                  .withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              widget.adresse,
                              style: TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: Text(
                      //     "Plus d'infos",
                      //     style: TextStyle(
                      //         fontSize: 13,
                      //         color: Color(int.parse("0x$pimpMyStore")).withOpacity(0.8),
                      //         fontWeight: FontWeight.bold),
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: (size.width) * 0.8,
                    child: Column(children: [
                      Row(
                        children: [
                          Icon(
                            Icons.watch_later_outlined,
                            color: Color(int.parse("0x$pimpMyStore"))
                                .withOpacity(0.5),
                            size: 17,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Horaires d'ouverture",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Row(
                      //   children: [
                      //     Column(children: [
                      //     Text("Lundi: 13h - 17h"),
                      //     Text("Mardi: 10h - 19h"),
                      //     Text("Mercredi: 9h - 14h"),
                      //     Text("Jeudi: 9h - 17h"),
                      //     Text("Vendredi: 8h30 - 18h"),
                      //     ],)
                      //   ],
                      // ),
                    ]),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Catégories",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (String name in listOfCategories)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15,
                            ),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse("0x$pimpMyStore"),
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      dropdownValue = name;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: dropdownValue == name
                                            ? Color(
                                                int.parse("0x$pimpMyStore"),
                                              ).withOpacity(1)
                                            : Color(
                                                int.parse("0x$pimpMyStore"),
                                              ).withOpacity(0.8),
                                        fontWeight: dropdownValue == name
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // Container(
                  //   width: size.width,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(5),
                  //     border: Border.all(
                  //       color: black.withOpacity(0.1),
                  //     ),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(15.0),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Avis clients",
                  //           style: TextStyle(
                  //             color: black.withOpacity(0.5),
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           height: 15,
                  //         ),
                  //         Text(
                  //           "Voir plus ...",
                  //           style: TextStyle(
                  //             color: Color(int.parse("0x$pimpMyStore")),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Produits disponibles",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      // listOfCategories == null || dropdownValue == null
                      //     ? CircularProgressIndicator()
                      //     : Platform.isIOS
                      //         ? TextButton(
                      //             child: Row(
                      //               children: [
                      //                 Text(dropdownValue,
                      //                     style: TextStyle(
                      //                         fontSize: 16,
                      //                         color: isDarkMode
                      //                             ? Colors.white
                      //                             : Colors.black)),
                      //                 SizedBox(width: 10),
                      //                 Icon(Icons.arrow_drop_down,
                      //                     size: 30,
                      //                     color: isDarkMode
                      //                         ? Colors.white
                      //                         : Colors.black)
                      //               ],
                      //             ),
                      //             onPressed: () {
                      //               showCupertinoModalPopup(
                      //                 context: context,
                      //                 builder: (context) => Container(
                      //                   width:
                      //                       MediaQuery.of(context).size.width,
                      //                   height: 200,
                      //                   child: CupertinoPicker(
                      //                       itemExtent: 50,
                      //                       backgroundColor: isDarkMode
                      //                           ? Color.fromRGBO(48, 48, 48, 1)
                      //                           : Colors.white,
                      //                       onSelectedItemChanged: (value) {
                      //                         setState(() {
                      //                           dropdownValue =
                      //                               listOfCategories[value];
                      //                         });
                      //                       },
                      //                       children: [
                      //                         for (String name
                      //                             in listOfCategories)
                      //                           Padding(
                      //                             padding:
                      //                                 const EdgeInsets.only(
                      //                                     top: 8.0),
                      //                             child: Text(name,
                      //                                 style: TextStyle(
                      //                                     color: isDarkMode
                      //                                         ? Colors.white
                      //                                         : Colors.black)),
                      //                           )
                      //                       ]),
                      //                 ),
                      //               );
                      //             },
                      //           )
                      //         : DropdownButton<String>(
                      //             value: dropdownValue,
                      //             icon: const Icon(
                      //                 Icons.keyboard_arrow_down_rounded),
                      //             iconSize: 24,
                      //             elevation: 16,
                      //             onChanged: (String newValue) {
                      //               setState(() {
                      //                 dropdownValue = newValue;
                      //               });
                      //             },
                      //             items: categorieNames
                      //                 .map<DropdownMenuItem<String>>(
                      //                     (String value) {
                      //               return DropdownMenuItem(
                      //                 value: value,
                      //                 child: Text(value),
                      //               );
                      //             }).toList(),
                      //           ),
                      // SizedBox(height: 20),
                      dropdownValue == null
                          ? CircularProgressIndicator()
                          : produits(dropdownValue),
                      SizedBox(height: 30),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 5),
                            for (int i = 1; i < 6; i++)
                              Container(
                                  height: 30,
                                  width: 30,
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      fixedSize: Size(10, 10),
                                    ),
                                    child: Text((i).toString(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: i == clickedNumber
                                                ? Colors.black
                                                : Colors.grey)),
                                    onPressed: () {
                                      clickedNumber = i;
                                      setState(() {});
                                    },
                                  ))
                          ]),
                      ////////// Design uniquement //////////
                      SizedBox(height: 20),
                      Text(
                        "Meilleures ventes",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 5),
                            for (int i = 0; i < 3; i++)
                              Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Icon(Icons.circle_rounded,
                                      size: 12,
                                      color:
                                          i == 0 ? Colors.black : Colors.grey))
                          ]),
                      SizedBox(height: 30),
                      Text(
                        "Recommandations du commerçant",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 5),
                            for (int i = 0; i < 3; i++)
                              Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Icon(Icons.circle_rounded,
                                      size: 12,
                                      color:
                                          i == 0 ? Colors.black : Colors.grey))
                          ]),
                      ////////// Design uniquement //////////
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget produits(selectedCategorie) {
    setState(() {
      countCart();
    });
    return StreamBuilder(
        stream: DatabaseMethods().getVisibleProducts(
            widget.sellerID, selectedCategorie, clickedNumber),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                var money = snapshot.data.docs[index]['prix'];
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PageProduit(
                                    userid: userid,
                                    imagesList: snapshot.data.docs[index]
                                        ['images'],
                                    nomProduit: snapshot.data.docs[index]
                                        ['nom'],
                                    descriptionProduit: snapshot
                                        .data.docs[index]['description'],
                                    prixProduit: snapshot.data.docs[index]
                                        ['prix'],
                                    img: widget.img,
                                    name: widget.name,
                                    description: widget.description,
                                    adresse: widget.adresse,
                                    clickAndCollect: widget.clickAndCollect,
                                    livraison: widget.livraison,
                                    idCommercant: widget.sellerID,
                                    idProduit: snapshot.data.docs[index]['id'],
                                  )));
                    },
                    child: Container(
                        // margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: BuyandByeAppTheme.white_grey,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.network(
                              snapshot.data.docs[index]["images"][0],
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(snapshot.data.docs[index]['nom'],
                                style: TextStyle(
                                    fontSize: 16,
                                    color: BuyandByeAppTheme.grey)),
                            SizedBox(height: 5),
                            Text("$money€",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        )));
              });
        });
  }

  void affichageCart() {
    slideDialog.showSlideDialog(
      context: context,
      child: CartPage(),
    );
  }
}
