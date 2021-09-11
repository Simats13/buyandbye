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
      this.sellerID})
      : super(key: key);

  final String img;
  final String name;
  final String description;
  final String adresse;
  final String sellerID;
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
  List listOfCategories = [];

  @override
  void initState() {
    super.initState();
    onScreenLoaded();
    getSellerInfo();
    categoriesInDb();
    NotificationController.instance.updateTokenToServer();
    if (mounted) {
      checkLocalNotification(localNotificationAnimation, "");
    }
  }

  getMyInfoFromSharedPreference() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    myID = userid;
    myName = user.displayName;
    myProfilePic = user.photoURL;
    myUserName = user.displayName;
    myEmail = user.email;

    setState(() {});
  }

  getSellerInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getMagasinInfo(widget.sellerID);
    selectedUserToken = "${querySnapshot.docs[0]["FCMToken"]}";
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

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
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
    var size = MediaQuery.of(context).size;
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
                    "PANIER",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: BuyandByeAppTheme.orange),
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
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: size.width,
                  height: 150,
                  child: Image(
                    image: NetworkImage(widget.img),
                  ),
                ),
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: BuyandByeAppTheme.orange.withOpacity(0.5),
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
                      IconButton(
                        icon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: BuyandByeAppTheme.orange.withOpacity(0.5),
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
                )
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
                      Text(
                        widget.name,
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
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
                                        widget
                                            .sellerID, // TOKEN DU CORRESPONDANT
                                        widget.sellerID + myID, //ID DE LA CONV
                                        widget.name, // NOM DU CORRESPONDANT
                                        "", // LES COMMERCANTS N'ONT PAS DE LNAME
                                        widget.img, // IMAGE DU CORRESPONDANT
                                      )));
                        },
                        child: Icon(
                          Icons.message,
                          color: BuyandByeAppTheme.orange,
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
                  SizedBox(
                    height: 15,
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
                              color: black.withOpacity(0.5),
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
                      Expanded(
                        child: Text(
                          "Plus d'infos",
                          style: TextStyle(
                              fontSize: 13,
                              color: BuyandByeAppTheme.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: (size.width) * 0.8,
                    child: Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: black.withOpacity(0.5),
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
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(peopleFeedback.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 15,
                          ),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color:
                                    BuyandByeAppTheme.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Text(
                                  peopleFeedback[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: BuyandByeAppTheme.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: black.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Avis clients",
                            style: TextStyle(
                              color: black.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Voir plus ...",
                            style: TextStyle(
                              color: BuyandByeAppTheme.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      listOfCategories == null || dropdownValue == null
                          ? CircularProgressIndicator()
                          : Platform.isIOS
                              ? TextButton(
                                  child: Row(
                                    children: [
                                      Text(dropdownValue,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)),
                                      SizedBox(width: 10),
                                      Icon(Icons.arrow_drop_down,
                                          size: 30,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black)
                                    ],
                                  ),
                                  onPressed: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) => Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 200,
                                        child: CupertinoPicker(
                                            itemExtent: 50,
                                            backgroundColor: isDarkMode
                                                ? Color.fromRGBO(48, 48, 48, 1)
                                                : Colors.white,
                                            onSelectedItemChanged: (value) {
                                              setState(() {
                                                dropdownValue =
                                                    listOfCategories[value];
                                              });
                                            },
                                            children: [
                                              for (String name
                                                  in listOfCategories)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(name,
                                                      style: TextStyle(
                                                          color: isDarkMode
                                                              ? Colors.white
                                                              : Colors.black)),
                                                )
                                            ]),
                                      ),
                                    );
                                  },
                                )
                              : DropdownButton<String>(
                                  value: dropdownValue,
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  iconSize: 24,
                                  elevation: 16,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                    });
                                  },
                                  items: categorieNames
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                      SizedBox(height: 20),
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
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 180,
                            width: 180,
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
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 180,
                            width: 180,
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
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 180,
                            width: 180,
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
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                                color: BuyandByeAppTheme.white_grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("Design uniquement")),
                          ),
                          SizedBox(width: 15),
                          Container(
                            height: 180,
                            width: 180,
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
    slideDialog.showSlideDialog(context: context, child: CartPage());
  }
}
