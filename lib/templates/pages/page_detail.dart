import 'package:buyandbye/templates/pages/cart.dart';
import 'package:buyandbye/templates/pages/chatscreen.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:buyandbye/theme/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/theme/colors.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/pages/page_produit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:number_ticker/number_ticker.dart';
import 'package:status_alert/status_alert.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';

import '../Messagerie/Controllers/fb_messaging.dart';
import '../Messagerie/subWidgets/local_notification_view.dart';

class PageDetail extends StatefulWidget {
  const PageDetail(
      {Key? key,
      this.img,
      this.name,
      this.description,
      this.adresse,
      this.clickAndCollect,
      this.livraison,
      this.sellerID,
      this.colorStore,
      this.horairesOuverture})
      : super(key: key);
  final String? img;
  final String? name;
  final String? description;
  final String? adresse;
  final String? sellerID;
  final String? colorStore;
  final bool? livraison;
  final bool? clickAndCollect;
  final Map? horairesOuverture;
  @override
  _PageDetail createState() => _PageDetail();
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    /*String googleUrl = Uri.encodeFull(
        'https://www.google.com/maps/search/?api=1&query=43.6889085,4.2724933');*/
    var googleUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: 'maps/search/?api=1&query=43.6889085,4.2724933'
    );
    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri);
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
      menuDropDownValue,
      dropdownValue;
  Stream? usersStream, chatRoomsStream;
  String? userid;
  String? adresseGoogleUrl;
  Stream<List<DocumentSnapshot>>? stream;
  List listOfCategories = [];
  List listOfMenu = [
    "Produits",
    "Recommandations",
    "Meilleures Ventes",
  ];

  bool listCategorie = false;
  bool loved = true;
  bool isRestaurant = false;
  bool checkFavoriteShop = false;
  bool horairesIsVisible = false;
  bool disableListCategories = true;
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
    menuDropDownValue = listOfMenu[0];
  }

  getMyInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(userid);
    myID = "${querySnapshot.docs[0]["id"]}";
    myName = "${querySnapshot.docs[0]["fname"]} ${querySnapshot.docs[0]["lname"]}";
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
      return "$b $a";
    } else {
      return "$a $b";
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

    if (querySnapshot.docs.isNotEmpty) {
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

  void reservationFunction() {
    showGeneralDialog(
      barrierLabel: "Réseration",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(minHeight: 100, maxHeight: 600),
            margin: const EdgeInsets.only(top: 100, left: 12, right: 12),
            child: const ReservationPage(),
          ),
        );
      },
    );
  }

  void affichageCart() {
    showGeneralDialog(
      barrierLabel: "Panier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(minHeight: 325, maxHeight: 900),
            margin: const EdgeInsets.only(top: 100, left: 12, right: 12),
            child: const CartPage(),
          ),
        );
      },
    );
  }

  Widget getFooter() {
    var pimpMyStore = widget.colorStore;
    var googleUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: 'maps/search/?api=1&query=$adresseGoogleUrl"'
    );
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
              await launchUrl(googleUri);
            }),
        const SizedBox(
          width: 15,
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
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                trailing: Wrap(
                  children: [
                    loved
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
                              await DatabaseMethods().addFavoriteShop(
                                  myID!, widget.sellerID, true);
                              setState(() {
                                loved = !loved;
                              });
                              StatusAlert.show(
                                context,
                                duration: const Duration(seconds: 2),
                                title: 'Favoris',
                                subtitle: 'Ajouté au favoris',
                                configuration:
                                    const IconConfiguration(icon: Icons.favorite),
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
                              child: const Center(
                                child: Icon(Icons.favorite,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                            onPressed: () async {
                              await DatabaseMethods().addFavoriteShop(
                                  myID, widget.sellerID, false);
                              setState(() {
                                loved = !loved;
                              });
                              StatusAlert.show(
                                context,
                                duration: const Duration(seconds: 2),
                                title: 'Favoris',
                                subtitle: 'Enlevé des favoris',
                                configuration: const IconConfiguration(
                                    icon: Icons.favorite_border),
                              );
                            },
                          ),
                    IconButton(
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse("0x$pimpMyStore"))
                              .withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 20,
                            // size: 22,
                          ),
                        ),
                      ),
                      onPressed: () {
                        affichageCart();
                      },
                    )
                  ],
                ),
                largeTitle: const Text(""),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: size.width,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
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
                const SizedBox(
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
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Click and Collect",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
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
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: textFieldColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Livraison",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
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
                                "users": [widget.sellerID, myID],
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
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: size.width - 30,
                            child: Text(
                              widget.description!,
                              style: const TextStyle(fontSize: 14, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: const [
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
                      const SizedBox(
                        height: 5,
                      ),
                      Divider(
                        color: black.withOpacity(0.3),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Informations de la boutique",
                        style: customContent,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: (size.width) * 0.8,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/pin_icon.svg",
                                  width: 15,
                                  color: Color(int.parse("0x$pimpMyStore"))
                                      .withOpacity(0.8),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  widget.adresse!,
                                  style: const TextStyle(fontSize: 14),
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
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: (size.width) * 0.6,
                        child: Column(children: [
                          Row(
                            children: [
                              Icon(
                                Icons.watch_later_rounded,
                                color: Color(int.parse("0x$pimpMyStore"))
                                    .withOpacity(0.8),
                                size: 17,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Column(
                                children: [
                                  InkWell(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Horaires d'ouverture",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        Icon(
                                          //Si la suite est affichée, la flèche pointe vers le bas
                                          //Sinon elle pointe vers la gauche
                                          horairesIsVisible
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_left,
                                          size: 25,
                                          color: Color(
                                                  int.parse("0x$pimpMyStore"))
                                              .withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        horairesIsVisible =
                                            !horairesIsVisible;
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          Visibility(
                            visible: horairesIsVisible,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                              const SizedBox(height: 10),
                              Text("Lundi:       ${widget.horairesOuverture!['Lundi']['Matin'][0]}h à ${widget.horairesOuverture!['Lundi']['Matin'][1]}h - ${widget.horairesOuverture!['Lundi']['Après-midi'][0]}h à ${widget.horairesOuverture!['Lundi']['Après-midi'][1]}h"),
                              const SizedBox(height: 5),
                              Text("Mardi:       ${widget.horairesOuverture!['Mardi']['Matin'][0]}h à ${widget.horairesOuverture!['Mardi']['Matin'][1]}h - ${widget.horairesOuverture!['Mardi']['Après-midi'][0]}h à ${widget.horairesOuverture!['Mardi']['Après-midi'][1]}h"),
                              const SizedBox(height: 5),
                              Text("Mercredi:  ${widget.horairesOuverture!['Mercredi']['Matin'][0]}h à ${widget.horairesOuverture!['Mercredi']['Matin'][1]}h - ${widget.horairesOuverture!['Mercredi']['Après-midi'][0]}h à ${widget.horairesOuverture!['Mercredi']['Après-midi'][1]}h"),
                              const SizedBox(height: 5),
                              Text("Jeudi:        ${widget.horairesOuverture!['Jeudi']['Matin'][0]}h à ${widget.horairesOuverture!['Jeudi']['Matin'][1]}h - ${widget.horairesOuverture!['Jeudi']['Après-midi'][0]}h à ${widget.horairesOuverture!['Jeudi']['Après-midi'][1]}h"),
                              const SizedBox(height: 5),                              
                              Text("Vendredi:   ${widget.horairesOuverture!['Vendredi']['Matin'][0]}h à ${widget.horairesOuverture!['Vendredi']['Matin'][1]}h - ${widget.horairesOuverture!['Vendredi']['Après-midi'][0]}h à ${widget.horairesOuverture!['Vendredi']['Après-midi'][1]}h"),
                              const SizedBox(height: 5),                              
                              const Text("Samedi:          Fermé                  "),
                              const SizedBox(height: 5),                              
                              const Text("Dimanche:      Fermé                  "),
                              const SizedBox(height: 5),
                            ]),
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
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          primary: Color(
                            int.parse("0x$pimpMyStore"),
                          ).withOpacity(0.5),
                          shadowColor: Color(
                            int.parse("0x$pimpMyStore"),
                          ).withOpacity(0.5),
                        ),
                        onPressed: () {
                          reservationFunction();
                        },
                        child: const Text(
                          "Réserver",
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),

                      //menu affichage des produits (Meilleures Ventes / Recommandations / Produits)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (String name in listOfMenu)
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
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        primary: Color(
                                          int.parse("0x$pimpMyStore"),
                                        ).withOpacity(0.2),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          menuDropDownValue = name;
                                        });
                                        if (menuDropDownValue ==
                                                listOfMenu[1] ||
                                            menuDropDownValue ==
                                                listOfMenu[2]) {
                                          setState(() {
                                            disableListCategories = false;
                                          });
                                        }
                                        if (menuDropDownValue ==
                                            listOfMenu[0]) {
                                          setState(() {
                                            disableListCategories = true;
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: menuDropDownValue == name
                                                ? Color(
                                                    int.parse("0x$pimpMyStore"),
                                                  ).withOpacity(1)
                                                : Color(
                                                    int.parse("0x$pimpMyStore"),
                                                  ).withOpacity(0.8),
                                            fontWeight:
                                                menuDropDownValue == name
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

                      isRestaurant
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Visibility(
                                      visible: disableListCategories,
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          listCategorie
                                              ? const Text(
                                                  "Catégories",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Container(),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  //menu affichage des produits à partir d'une catégorie
                                  Visibility(
                                      visible: disableListCategories,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (String name
                                                in listOfCategories)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 15,
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Color(
                                                      int.parse(
                                                          "0x$pimpMyStore"),
                                                    ).withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Center(
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
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
                                                            const EdgeInsets
                                                                    .only(
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
                                                                  ).withOpacity(
                                                                    1)
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
                                      )),

                                  Visibility(
                                      visible: disableListCategories,
                                      child: const SizedBox(
                                        height: 15,
                                      )),
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
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isRestaurant
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Menus",
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
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
                                            child: const Center(
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
                                    const SizedBox(height: 30),
                                  ],
                                )
                              : const SizedBox.shrink(),

                          menuDropDownValue == listOfMenu[0]
                              ? affichageMenuProduits()
                              : Container(),
                          menuDropDownValue == listOfMenu[1]
                              ? affichageMenuRecommandation()
                              : Container(),
                          menuDropDownValue == listOfMenu[2]
                              ? affichageMenuMeilleuresVentes()
                              : Container(),

                          const SizedBox(height: 30),
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

  Widget produits(String? selectedCategorie) {
    return StreamBuilder<dynamic>(
        stream: DatabaseMethods()
            .getVisibleProducts(widget.sellerID, selectedCategorie),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          if (snapshot.data.docs.length == 0) {
            return const Text("Aucun produit disponible");
          }
          return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                            color: BuyandByeAppTheme.whiteGrey,
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
                            const SizedBox(height: 5),
                            Text(
                                (snapshot.data! as QuerySnapshot).docs[index]
                                    ['nom'],
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: BuyandByeAppTheme.grey)),
                            const SizedBox(height: 5),
                            Text("$money€",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        )));
              });
        });
  }

  Widget affichageMenuRecommandation() {
    return Column(children: [
      const Text(
        "Recommandations du commerçant",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
          const SizedBox(width: 15),
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
        ],
      ),
      const SizedBox(height: 25),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
          const SizedBox(width: 15),
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
        ],
      ),
    ]);
  }

  Widget affichageMenuMeilleuresVentes() {
    return Column(children: [
      const Text(
        "Meilleures ventes",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
          const SizedBox(width: 15),
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
        ],
      ),
      const SizedBox(height: 25),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
          const SizedBox(width: 15),
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
                color: BuyandByeAppTheme.whiteGrey,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text("Design uniquement")),
          ),
        ],
      ),
    ]);
  }

  Widget affichageMenuProduits() {
    return Column(
      children: [
        const Text(
          "Produits disponibles",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        produits(dropdownValue),
      ],
    );
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
  //                   color: BuyandByeAppTheme.whiteGrey,
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

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late String horairesDropDownValue;
  List listOfHoraires = ["11h30", "12h00", "12h30", "13h00", "13h30"];
  final controller1 = NumberTickerController();

  @override
  void initState() {
    super.initState();
    horairesDropDownValue = listOfHoraires[0];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Ma réservation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    for (String name in listOfHoraires)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15,
                            ),
                            child: Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 108, 112, 109)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    primary: const Color.fromARGB(255, 108, 112, 109)
                                        .withOpacity(0.2),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      horairesDropDownValue = name;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: horairesDropDownValue == name
                                            ? const Color.fromARGB(255, 45, 46, 45)
                                                .withOpacity(1)
                                            : const Color.fromARGB(255, 89, 92, 90)
                                                .withOpacity(0.9),
                                        fontWeight:
                                            horairesDropDownValue == name
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      )
                  ],
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: [
                  const Center(
                      child: Text("Pour combien ?",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18))),
                  const SizedBox(height: 15),
                  NumberTicker(
                    controller: controller1,
                    initialNumber: 1,
                    textStyle: const TextStyle(fontSize: 17),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 108, 112, 109))),
                        onPressed: () {
                          controller1.number = controller1.number - 1;
                        },
                        child: const Text('-'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 108, 112, 109))),
                        onPressed: () {
                          controller1.number = controller1.number + 1;
                        },
                        child: const Text('+'),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 244, 67, 54)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 25, 144, 55)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ))),
                    onPressed: () {},
                    child: const Text('Réserver'),
                  ),
                ],
              ),
            ])));
  }
}
