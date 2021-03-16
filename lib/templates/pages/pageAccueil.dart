import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oficihome/json/menu_json.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/templates/pages/pageDetail.dart';
import 'package:oficihome/theme/colors.dart';
import 'package:oficihome/theme/styles.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/widgets/custom_slider.dart';

import '../../json/menu_json.dart';
import '../../theme/colors.dart';

// import 'package:oficihome/templates/widgets/custom_slider.dart';
// import 'package:oficihome/templates/compte/constants.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageAccueil extends StatefulWidget {
  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  int activeMenu = 0;

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
            ),
            //Livraison / Click&Collect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(menu.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        activeMenu = index;
                      });
                    },
                    child: activeMenu == index
                        ? ElasticIn(
                            child: Container(
                              decoration: BoxDecoration(
                                color: OficihomeAppTheme.orange,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  bottom: 8,
                                  top: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      menu[index],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 15,
                                bottom: 8,
                                top: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    menu[index],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              }),
            ),
            SizedBox(
              height: 15,
            ),
            //Localisation
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15),
                  height: 45,
                  width: size.width - 70,
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/pin_icon.svg",
                              width: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Localisation",
                              style: customContent,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: SvgPicture.asset("assets/icons/filter_icon.svg"),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: CustomSliderWidget(
                items: [Item4()],
              ),
            ),
            // Container(
            //   width: size.width,
            //   decoration: BoxDecoration(
            //     color: textFieldColor,
            //   ),
            //   child: Padding(
            //     padding: EdgeInsets.only(bottom: 10, top: 10),
            //     child: Container(
            //       decoration: BoxDecoration(color: white),
            //       child: Padding(
            //         padding: EdgeInsets.only(
            //           top: 15,
            //           bottom: 15,
            //         ),
            //         child: SingleChildScrollView(
            //           scrollDirection: Axis.horizontal,
            //           child: Container(
            //             margin: EdgeInsets.only(
            //               left: 30,
            //             ),
            //             child: Row(
            //               children: List.generate(categories.length, (index) {
            //                 return Padding(
            //                   padding: const EdgeInsets.only(right: 30),
            //                   child: Column(
            //                     children: [
            //                       SvgPicture.asset(
            //                         categories[index]['img'],
            //                         width: 40,
            //                       ),
            //                       SizedBox(
            //                         height: 15,
            //                       ),
            //                       Text(
            //                         categories[index]['name'],
            //                         style: customContent,
            //                       ),
            //                     ],
            //                   ),
            //                 );
            //               }),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            //trait gris de séparation rajouté après avoir désactivé le code au dessus.
            Container(
              width: size.width,
              height: 10,
              decoration: BoxDecoration(color: textFieldColor),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(top: 12, left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ce qui pourrait vous plaire",
                    style: customTitle,
                  ),
                ],
              ),
            ),
            Container(
              width: size.width,
              margin: EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PageDetail(
                              img: firstMenu[0]['img'],
                              name: firstMenu[0]['name'],
                              description: firstMenu[0]['description'],
                              clickAndCollect: firstMenu[0]['clickAndCollect'],
                              location: firstMenu[0]['location'],
                              rate: firstMenu[0]['rate'],
                              //comments: firstMenu[0]['comments'],
                            )),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //Liste des magasins
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: size.width,
                            height: 160,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(firstMenu[0]['img'])),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                          ),
                          Positioned(
                            bottom: 15.0,
                            right: 15.0,
                            child: SvgPicture.asset(
                              firstMenu[0]['is_liked']
                                  ? "assets/icons/loved_icon.svg"
                                  : "assets/icons/love_icon.svg",
                              width: 20,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        firstMenu[0]['name'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            "Sponsorisé",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.info,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        firstMenu[0]['description'],
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: textFieldColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text(
                                    firstMenu[0]['rate'],
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: yellowStar,
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
                              borderRadius: BorderRadius.circular(3),
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
                                    firstMenu[0]['clickAndCollect']
                                        ? Icons.check_circle
                                        : Icons.add_circle,
                                    color: firstMenu[0]['clickAndCollect']
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
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      //Fin du premier magasin
                      Container(
                        width: size.width,
                        height: 10,
                        decoration: BoxDecoration(color: textFieldColor),
                      ),
                      //Plus à découvrir
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(left: 15, right: 15, bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Plus à découvrir",
                              style: customTitle,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    List.generate(exploreMenu.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PageDetail(
                                                  img: exploreMenu[index]
                                                      ['img'],
                                                  name: exploreMenu[index]
                                                      ['name'],
                                                  description:
                                                      exploreMenu[index]
                                                          ["description"],
                                                  clickAndCollect:
                                                      exploreMenu[index]
                                                          ['clickAndCollect'],
                                                  location: exploreMenu[index]
                                                      ['location'],
                                                  rate: exploreMenu[index]
                                                      ['rate'],
                                                  //comments: exploreMenu[index]
                                                  //['comments'],
                                                )),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: size.width,
                                                height: 160,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        exploreMenu[index]
                                                            ['img']),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              16.0)),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 15.0,
                                                right: 15.0,
                                                child: SvgPicture.asset(
                                                  exploreMenu[index]['is_liked']
                                                      ? "assets/icons/loved_icon.svg"
                                                      : "assets/icons/love_icon.svg",
                                                  width: 20,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            exploreMenu[index]['name'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Sponsorisé",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.info,
                                                size: 15,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            exploreMenu[index]['description'],
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: textFieldColor,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        exploreMenu[index]
                                                            ['rate'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Icon(
                                                        Icons.star,
                                                        color: yellowStar,
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
                                                  borderRadius:
                                                      BorderRadius.circular(3),
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
                                                        exploreMenu[index][
                                                                'clickAndCollect']
                                                            ? Icons.check_circle
                                                            : Icons.add_circle,
                                                        color: exploreMenu[
                                                                    index][
                                                                'clickAndCollect']
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
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      //Fin Plus à découvrir
                      Container(
                        width: size.width,
                        height: 10,
                        decoration: BoxDecoration(color: textFieldColor),
                      ),
                      //Près de chez vous
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(left: 15, right: 15, bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Près de chez vous",
                              style: customTitle,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(popluarNearYou.length,
                                    (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PageDetail(
                                                  img: popluarNearYou[index]
                                                      ['img'],
                                                  name: popluarNearYou[index]
                                                      ['name'],
                                                  description:
                                                      popluarNearYou[index]
                                                          ['description'],
                                                  clickAndCollect:
                                                      popluarNearYou[index]
                                                          ['clickAndCollect'],
                                                  location:
                                                      popluarNearYou[index]
                                                          ['location'],
                                                  rate: popluarNearYou[index]
                                                      ['rate'],
                                                  //comments: popluarNearYou[index]
                                                  //['comments'],
                                                )),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: size.width,
                                                height: 160,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          popluarNearYou[index]
                                                              ['img'])),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              16.0)),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 15.0,
                                                right: 15.0,
                                                child: SvgPicture.asset(
                                                  popluarNearYou[index]
                                                          ['is_liked']
                                                      ? "assets/icons/loved_icon.svg"
                                                      : "assets/icons/love_icon.svg",
                                                  width: 20,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            popluarNearYou[index]['name'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Sponsorisé",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.info,
                                                size: 15,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            popluarNearYou[index]
                                                ['description'],
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: textFieldColor,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        popluarNearYou[index]
                                                            ['rate'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Icon(
                                                        Icons.star,
                                                        color: yellowStar,
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
                                                  borderRadius:
                                                      BorderRadius.circular(3),
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
                                                        popluarNearYou[index][
                                                                'clickAndCollect']
                                                            ? Icons.check_circle
                                                            : Icons.add_circle,
                                                        color: popluarNearYou[
                                                                    index][
                                                                'clickAndCollect']
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
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        "assets/icons/pin_icon.svg",
                                                        width: 15,
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Text(
                                                        "A 500m",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Fin Près de chez vous
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }
}

class Item4 extends StatefulWidget {
  @override
  _Item4State createState() => _Item4State();
}

class _Item4State extends State<Item4> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseMethods().getStoreInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('chargement en cours...');
          return PageView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image:
                          NetworkImage(snapshot.data.docs[index]['photoUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(snapshot.data.docs[index]['name'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold)),
                      Text(snapshot.data.docs[index]['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              });
        });
  }
}
