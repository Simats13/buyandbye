import 'package:buyandbye/templates/pages/chatscreen.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:buyandbye/theme/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/pages/pageProduit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:status_alert/status_alert.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';

import '../Messagerie/Controllers/fb_messaging.dart';
import '../Messagerie/subWidgets/local_notification_view.dart';

class PageDetail extends StatefulWidget {
  const PageDetail({
    Key? key,
    this.img,
    this.name,
    this.description,
    this.adresse,
    this.clickAndCollect,
    this.livraison,
    this.sellerID,
    this.colorStore,
  }) : super(key: key);
  final String? img;
  final String? name;
  final String? description;
  final String? adresse;
  final String? sellerID;
  final String? colorStore;
  final bool? livraison;
  final bool? clickAndCollect;
  _PageDetail createState() => _PageDetail();
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = Uri.encodeFull(
        'https://www.google.com/maps/search/?api=1&query=43.6889085,4.2724933');
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class _PageDetail extends State<PageDetail> with LocalNotificationView {
  double cartTotal = 0.0;
  double cartDeliver = 0.0;
  String mainCategorie = "";
  String? myID,
      myName,
      myProfilePic,
      myUserName,
      myEmail,
      selectedUserToken,
      name1,
      message,
      dropdownValue;
  Stream? usersStream, chatRoomsStream;
  String? userid;
  String? adresseGoogleUrl;
  Stream<List<DocumentSnapshot>>? stream;
  List listOfCategories = [];

  bool listCategorie = false;
  bool loved = true;
  bool isRestaurant = false;
  bool checkFavoriteShop = false;
  final List<ImageProvider> _imageProviders = [
    Image.network(
            "http://le80.fr/wp-content/uploads/2017/03/menu-le_80-2019-HD2.jpg")
        .image,
    Image.network(
            "http://le80.fr/wp-content/uploads/2017/03/menu-le_80-2019-HD3.jpg")
        .image,
    Image.network(
            "http://le80.fr/wp-content/uploads/2017/03/menu-le_80-2019-HD4.jpg")
        .image,
  ];
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getMyInfo();
    getSellerInfo();
    categoriesInDb();
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
    loved = await DatabaseMethods().checkFavoriteShopSeller(widget.sellerID);
    setState(() {});
  }

  getSellerInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(widget.sellerID);
    selectedUserToken = "${querySnapshot.docs[0]["FCMToken"]}";
    mainCategorie = "${querySnapshot.docs[0]["type"]}";
    adresseGoogleUrl = "${querySnapshot.docs[0]["adresse"]}";
    // Retire les caractères en trop et split les catégories dans une liste
    if (mainCategorie == "Restaurant") {
      isRestaurant = true;
    }
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
      body: getBody(isRestaurant),
    );
  }

  categoriesInDb() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("magasins")
        .doc(widget.sellerID)
        .collection("produits")
        .get();

    if (querySnapshot.docs.length != 0) {
      // Pour chaque produit dans la bdd, ajoute le nom de la catégorie s'il n'est
      // pas déjà dans la liste
      for (var i = 0; i <= querySnapshot.docs.length - 1; i++) {
        String? categoryName = querySnapshot.docs[i]["categorie"];
        if (!listOfCategories.contains(categoryName)) {
          listOfCategories.add(querySnapshot.docs[i]["categorie"]);
        }
      }
      setState(() {
        dropdownValue = listOfCategories[0];
      });
      return listCategorie = true;
    } else {
      return listCategorie = false;
    }
  }

  Widget getFooter() {
    var pimpMyStore = widget.colorStore;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
            child: const Text("VOIR SUR LA CARTE"),
            style: ElevatedButton.styleFrom(
              primary: Color(int.parse("0x$pimpMyStore")).withOpacity(0.5),
              shadowColor: Color(int.parse("0x$pimpMyStore")).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            onPressed: () async {
              await launch(Uri.encodeFull(
                  "https://www.google.com/maps/search/?api=1&query=$adresseGoogleUrl"));
            }),
        SizedBox(
          width: 30,
        ),
        ElevatedButton(
            child: const Text("VOIR LE NUMÉRO"),
            style: ElevatedButton.styleFrom(
                primary: Color(int.parse("0x$pimpMyStore")).withOpacity(0.5),
                shadowColor:
                    Color(int.parse("0x$pimpMyStore")).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                )),
            onPressed: () {
              FlutterPhoneDirectCaller.callNumber("0695559127");
            }),
      ]),
    );
  }

  // La variable avant le Widget sinon elle n'est pas modifiée dynamiquement
  // String dropdownValue = 'Alimentation';
  int clickedNumber = 1;
  Widget getBody(isRestaurant) {
    var pimpMyStore = widget.colorStore;
    var size = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: CupertinoSliverNavigationBarDetail(
                automaticallyImplyTitle: false,
                leading: IconButton(
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
                  onPressed: () async {
                    checkFavoriteShop =
                        await DatabaseMethods().checkFavoriteShop();
                    Navigator.pop(context);
                  },
                ),
                middle: Text(
                  widget.name!,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                trailing: loved
                    ? IconButton(
                        icon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(int.parse("0x$pimpMyStore"))
                                .withOpacity(0.5),
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
                        onPressed: () async {
                          await DatabaseMethods()
                              .addFavoriteShop(myID!, widget.sellerID, true);
                          setState(() {
                            loved = !loved;
                          });
                          StatusAlert.show(
                            context,
                            duration: Duration(seconds: 2),
                            title: 'Favoris',
                            subtitle: 'Ajouté au favoris',
                            configuration:
                                IconConfiguration(icon: Icons.favorite),
                          );
                        },
                      )
                    : IconButton(
                        icon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(int.parse("0x$pimpMyStore"))
                                .withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await DatabaseMethods()
                              .addFavoriteShop(myID, widget.sellerID, false);
                          setState(() {
                            loved = !loved;
                          });
                          StatusAlert.show(
                            context,
                            duration: Duration(seconds: 2),
                            title: 'Favoris',
                            subtitle: 'Enlevé des favoris',
                            configuration:
                                IconConfiguration(icon: Icons.favorite_border),
                          );
                        },
                      ),
                largeTitle: Text(""),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
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
                          image: NetworkImage(widget.img!),
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
                                        widget.clickAndCollect!
                                            ? Icons.check_circle
                                            : Icons.highlight_off,
                                        color: widget.clickAndCollect!
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
                                        widget.livraison!
                                            ? Icons.check_circle
                                            : Icons.highlight_off,
                                        color: widget.livraison!
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
                                  widget.sellerID! + myID!, chatRoomInfoMap);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoom(
                                          myID, //ID DE L'UTILISATEUR
                                          myName, // NOM DE L'UTILISATEUR
                                          selectedUserToken,
                                          widget
                                              .sellerID, // TOKEN DU CORRESPONDANT
                                          widget.sellerID! +
                                              myID!, //ID DE LA CONV
                                          widget.name, // NOM DU CORRESPONDANT
                                          "", // LES COMMERCANTS N'ONT PAS DE LNAME
                                          widget.img, // IMAGE DU CORRESPONDANT
                                          myProfilePic, // IMAGE DE L'UTILISATEUR
                                          "client")));
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
                              widget.description!,
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
                                      .withOpacity(0.8),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  widget.adresse!,
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
                                Icons.watch_later_rounded,
                                color: Color(int.parse("0x$pimpMyStore"))
                                    .withOpacity(0.8),
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
                      isRestaurant
                          ? SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  listCategorie
                                      ? Text(
                                          "Catégories",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Container(),
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
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Center(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                    primary: Color(
                                                      int.parse(
                                                          "0x$pimpMyStore"),
                                                    ).withOpacity(0.2),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      dropdownValue = name;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            right: 15),
                                                    child: Text(
                                                      name,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: dropdownValue ==
                                                                name
                                                            ? Color(
                                                                int.parse(
                                                                    "0x$pimpMyStore"),
                                                              ).withOpacity(1)
                                                            : Color(
                                                                int.parse(
                                                                    "0x$pimpMyStore"),
                                                              ).withOpacity(
                                                                0.8),
                                                        fontWeight:
                                                            dropdownValue == name
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w500,
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
                                ]),
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
                          isRestaurant
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Menus",
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                        height: size.height / 20,
                                        width: size.width / 3,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color:
                                              Color(int.parse("0x$pimpMyStore"))
                                                  .withOpacity(0.5),
                                        ),
                                        child: MaterialButton(
                                            child: Center(
                                                child: Text("Voir le menu",
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                            onPressed: () {
                                              MultiImageProvider
                                                  multiImageProvider =
                                                  MultiImageProvider(
                                                      _imageProviders);
                                              showImageViewerPager(
                                                  context, multiImageProvider,
                                                  immersive: false);
                                            })),
                                    SizedBox(height: 30),
                                  ],
                                )
                              : SizedBox.shrink(),
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
                          SizedBox(height: 25),
                          Text(
                            "Meilleures ventes",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 30),
                          // StreamBuilder(
                          //   stream: DatabaseMethods()
                          //       .getBestSeller(widget.sellerID),
                          //   builder: (context, snapshot) {
                          //     print(snapshot.data);

                          //     if (!snapshot.hasData)
                          //       return CircularProgressIndicator();
                          //     return GridView.builder(
                          //       padding: EdgeInsets.zero,
                          //       shrinkWrap: true,
                          //       physics: NeverScrollableScrollPhysics(),
                          //       gridDelegate:
                          //           SliverGridDelegateWithMaxCrossAxisExtent(
                          //               maxCrossAxisExtent: 200,
                          //               childAspectRatio: 1,
                          //               mainAxisSpacing: 20,
                          //               crossAxisSpacing: 20),
                          //       itemCount: snapshot.data.docs.length,
                          //       itemBuilder: (context, index) {
                          //         // print(snapshot.data.docs[index]);
                          //         var money = snapshot.data.docs[index]['prix'];
                          //         return GestureDetector(
                          //           onTap: () {
                          //             Navigator.push(
                          //                 context,
                          //                 MaterialPageRoute(
                          //                     builder: (context) => PageProduit(
                          //                           userid: userid,
                          //                           imagesList: snapshot.data
                          //                               .docs[index]['images'],
                          //                           nomProduit: snapshot.data
                          //                               .docs[index]['nom'],
                          //                           descriptionProduit: snapshot
                          //                                   .data.docs[index]
                          //                               ['description'],
                          //                           prixProduit: snapshot.data
                          //                               .docs[index]['prix'],
                          //                           img: widget.img,
                          //                           name: widget.name,
                          //                           description:
                          //                               widget.description,
                          //                           adresse: widget.adresse,
                          //                           clickAndCollect:
                          //                               widget.clickAndCollect,
                          //                           livraison: widget.livraison,
                          //                           idCommercant:
                          //                               widget.sellerID,
                          //                           idProduit: snapshot
                          //                               .data.docs[index]['id'],
                          //                         )));
                          //           },
                          //           child: Container(
                          //             // margin: EdgeInsets.all(10),
                          //             decoration: BoxDecoration(
                          //                 color: BuyandByeAppTheme.white_grey,
                          //                 borderRadius:
                          //                     BorderRadius.circular(10)),
                          //             child: Column(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.center,
                          //               children: <Widget>[
                          //                 Image.network(
                          //                   snapshot.data.docs[index]["images"]
                          //                       [0],
                          //                   width: MediaQuery.of(context)
                          //                       .size
                          //                       .width,
                          //                   height: 100,
                          //                 ),
                          //                 SizedBox(height: 5),
                          //                 Text(snapshot.data.docs[index]['nom'],
                          //                     style: TextStyle(
                          //                         fontSize: 16,
                          //                         color:
                          //                             BuyandByeAppTheme.grey)),
                          //                 SizedBox(height: 5),
                          //                 Text(
                          //                   "$money€",
                          //                   style: TextStyle(
                          //                     fontSize: 16,
                          //                     fontWeight: FontWeight.w500,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     );
                          //   },
                          // ),
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
                          Text(
                            "Produits disponibles",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),

                          produits(dropdownValue),
                          SizedBox(height: 30),
                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       SizedBox(width: 5),
                          //       for (int i = 1; i < 6; i++)
                          //         Container(
                          //             height: 30,
                          //             width: 30,
                          //             margin:
                          //                 EdgeInsets.only(left: 10, right: 10),
                          //             child: TextButton(
                          //               style: TextButton.styleFrom(
                          //                 padding: EdgeInsets.zero,
                          //                 fixedSize: Size(10, 10),
                          //               ),
                          //               child: Text((i).toString(),
                          //                   style: TextStyle(
                          //                       fontSize: 18,
                          //                       fontWeight: FontWeight.w700,
                          //                       color: i == clickedNumber
                          //                           ? Colors.black
                          //                           : Colors.grey)),
                          //               onPressed: () {
                          //                 clickedNumber = i;
                          //                 setState(() {});
                          //               },
                          //             ))
                          //     ]),
                          // SizedBox(height: 30),
                          ////////// Design uniquement //////////

                          // SizedBox(height: 30),
                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       SizedBox(width: 5),
                          //       for (int i = 0; i < 3; i++)
                          //         Container(
                          //             margin:
                          //                 EdgeInsets.only(left: 5, right: 5),
                          //             child: Icon(Icons.circle_rounded,
                          //                 size: 12,
                          //                 color: i == 0
                          //                     ? Colors.black
                          //                     : Colors.grey))
                          //     ]),
                          ////////// Design uniquement //////////
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget produits(selectedCategorie) {
    return StreamBuilder<dynamic>(
        stream: DatabaseMethods().getVisibleProducts(
            widget.sellerID, selectedCategorie),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data.docs.length == 0)
            return Text("Aucun produit disponible");
          return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20),
              itemCount: (snapshot.data! as QuerySnapshot).docs.length,
              itemBuilder: (context, index) {
                var money = (snapshot.data! as QuerySnapshot)
                    .docs[index]['prix']
                    .toStringAsFixed(2);
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
                                    idProduit: (snapshot.data! as QuerySnapshot)
                                        .docs[index]['id'],
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
                              (snapshot.data! as QuerySnapshot).docs[index]
                                  ["images"][0],
                              width: MediaQuery.of(context).size.width,
                              height: 100,
                            ),
                            SizedBox(height: 5),
                            Text(
                                (snapshot.data! as QuerySnapshot).docs[index]
                                    ['nom'],
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

  // Widget bestSeller(categorie) {
  //   return StreamBuilder(
  //     stream: DatabaseMethods().getBestSeller(widget.sellerID, categorie),
  //     builder: (context, snapshot) {
  //       print(snapshot.data);

  //       if (!snapshot.hasData) return CircularProgressIndicator();
  //       return GridView.builder(
  //         padding: EdgeInsets.zero,
  //         shrinkWrap: true,
  //         physics: NeverScrollableScrollPhysics(),
  //         gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //             maxCrossAxisExtent: 200,
  //             childAspectRatio: 1,
  //             mainAxisSpacing: 20,
  //             crossAxisSpacing: 20),
  //         itemCount: snapshot.data.docs.length,
  //         itemBuilder: (context, index) {
  //           // print(snapshot.data.docs[index]);
  //           var money = snapshot.data.docs[index]['prix'];
  //           return GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => PageProduit(
  //                             userid: userid,
  //                             imagesList: snapshot.data.docs[index]['images'],
  //                             nomProduit: snapshot.data.docs[index]['nom'],
  //                             descriptionProduit: snapshot.data.docs[index]
  //                                 ['description'],
  //                             prixProduit: snapshot.data.docs[index]['prix'],
  //                             img: widget.img,
  //                             name: widget.name,
  //                             description: widget.description,
  //                             adresse: widget.adresse,
  //                             clickAndCollect: widget.clickAndCollect,
  //                             livraison: widget.livraison,
  //                             idCommercant: widget.sellerID,
  //                             idProduit: snapshot.data.docs[index]['id'],
  //                           )));
  //             },
  //             child: Container(
  //               // margin: EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                   color: BuyandByeAppTheme.white_grey,
  //                   borderRadius: BorderRadius.circular(10)),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: <Widget>[
  //                   Image.network(
  //                     snapshot.data.docs[index]["images"][0],
  //                     width: MediaQuery.of(context).size.width,
  //                     height: 100,
  //                   ),
  //                   SizedBox(height: 5),
  //                   Text(snapshot.data.docs[index]['nom'],
  //                       style: TextStyle(
  //                           fontSize: 16, color: BuyandByeAppTheme.grey)),
  //                   SizedBox(height: 5),
  //                   Text(
  //                     "$money€",
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
