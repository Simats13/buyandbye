import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oficihome/json/menu_json.dart';
import 'package:oficihome/theme/colors.dart';
import 'package:oficihome/theme/styles.dart';
import 'package:oficihome/templates/widgets/custom_slider.dart';

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
                                color: Colors.black,
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
                                        color: Colors.white,
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
                                      color: Colors.black,
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
                              "assets/pin_icon.svg",
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
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/time_icon.svg",
                                    width: 20,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Quand ?",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: SvgPicture.asset("assets/filter_icon.svg"),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            CustomSliderWidget(
              items: [
                "assets/logo.jpg",
                "assets/logo.jpg",
                "assets/logo.jpg",
              ],
            ),
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: textFieldColor,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Container(
                  decoration: BoxDecoration(color: white),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 30,
                        ),
                        child: Row(
                          children: List.generate(categories.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    categories[index]['img'],
                                    width: 40,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    categories[index]['name'],
                                    style: customContent,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: size.width,
              child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: size.width,
                          height: 160,
                          child: Image(
                            image: NetworkImage(firstMenu[0]['img']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 15.0,
                          right: 15.0,
                          child: SvgPicture.asset(
                            firstMenu[0]['is_liked']
                                ? "assets/loved_icon.svg"
                                : "assets/love_icon.svg",
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.hourglass_bottom,
                              color: primary,
                              size: 16,
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
                            child: Text(
                              firstMenu[0]['time'],
                              style: TextStyle(
                                fontSize: 14,
                              ),
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
                            child: Text(
                              firstMenu[0]['delivery_fee'],
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: size.width,
                      height: 10,
                      decoration: BoxDecoration(color: textFieldColor),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
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
                              children: List.generate(exploreMenu.length, (index) {
                                return Padding(
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
                                            child: Image(
                                              image: NetworkImage(
                                                  exploreMenu[index]['img']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 15.0,
                                            right: 15.0,
                                            child: SvgPicture.asset(
                                              exploreMenu[index]['is_liked']
                                                  ? "assets/loved_icon.svg"
                                                  : "assets/love_icon.svg",
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
                                              padding: EdgeInsets.all(3),
                                              child: Icon(
                                                Icons.hourglass_bottom,
                                                color: primary,
                                                size: 16,
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
                                              child: Text(
                                                exploreMenu[index]['time'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
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
                                                    exploreMenu[index]['rate_number'],
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
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(
                                                    exploreMenu[index]['time'],
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
                    Container(
                      width: size.width,
                      height: 10,
                      decoration: BoxDecoration(color: textFieldColor),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
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
                              children: List.generate(popluarNearYou.length, (index) {
                                return Padding(
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
                                            child: Image(
                                              image: NetworkImage(
                                                  popluarNearYou[index]['img']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 15.0,
                                            right: 15.0,
                                            child: SvgPicture.asset(
                                              popluarNearYou[index]['is_liked']
                                                  ? "assets/loved_icon.svg"
                                                  : "assets/love_icon.svg",
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
                                        popluarNearYou[index]['description'],
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
                                              padding: EdgeInsets.all(3),
                                              child: Icon(
                                                Icons.hourglass_bottom,
                                                color: primary,
                                                size: 16,
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
                                              child: Text(
                                                popluarNearYou[index]['time'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
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
                                                    popluarNearYou[index]['rate_number'],
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
                                                  SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(
                                                    popluarNearYou[index]['time'],
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
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
