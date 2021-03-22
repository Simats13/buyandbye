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
            Text("     Les Bons Plans du moment", style: customTitle),
            Container(
              padding: EdgeInsets.all(20),
              child: CustomSliderWidget(
                items: [SliderAccueil1()],
              ),
            ),

            //trait gris de séparation rajouté après avoir désactivé le code au dessus.
            Container(
              width: size.width,
              height: 10,
              decoration: BoxDecoration(color: textFieldColor),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "     Près de chez vous",
              style: customTitle,
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: CustomSliderWidget(
                items: [SliderAccueil2()],
              ),
            ),

            //trait gris de séparation rajouté après avoir désactivé le code au dessus.
            Container(
              width: size.width,
              height: 10,
              decoration: BoxDecoration(color: textFieldColor),
            ),
            SizedBox(
              height: 15,
            ),
            Text("     Plus à Découvrir", style: customTitle),
            Container(
              padding: EdgeInsets.all(20),
              child: CustomSliderWidget(
                items: [SliderAccueil3()],
              ),
            ),

            //trait gris de séparation rajouté après avoir désactivé le code au dessus.
            Container(
              width: size.width,
              height: 10,
              decoration: BoxDecoration(color: textFieldColor),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "    Vous avez acheté chez eux récemment",
              style: customTitle,
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: CustomSliderWidget(
                items: [SliderAccueil4()],
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

class SliderAccueil1 extends StatefulWidget {
  @override
  _SliderAccueil1State createState() => _SliderAccueil1State();
}

class _SliderAccueil1State extends State<SliderAccueil1> {
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
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data.docs[index]
                                            ['photoUrl'],
                                        name: snapshot.data.docs[index]['name'],
                                        description: snapshot.data.docs[index]
                                            ['description'],
                                        adresse: snapshot.data.docs[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data
                                            .docs[index]['ClickAndCollect'],
                                        livraison: snapshot.data.docs[index]
                                            ['livraison'],
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                  snapshot.data.docs[index]['photoUrl']),
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
                        )));
              });
        });
  }
}

class SliderAccueil2 extends StatefulWidget {
  @override
  _SliderAccueil2State createState() => _SliderAccueil2State();
}

class _SliderAccueil2State extends State<SliderAccueil2> {
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
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data.docs[index]
                                            ['photoUrl'],
                                        name: snapshot.data.docs[index]['name'],
                                        description: snapshot.data.docs[index]
                                            ['description'],
                                        adresse: snapshot.data.docs[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data
                                            .docs[index]['ClickAndCollect'],
                                        livraison: snapshot.data.docs[index]
                                            ['livraison'],
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                  snapshot.data.docs[index]['photoUrl']),
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
                        )));
              });
        });
  }
}

class SliderAccueil3 extends StatefulWidget {
  @override
  _SliderAccueil3State createState() => _SliderAccueil3State();
}

class _SliderAccueil3State extends State<SliderAccueil3> {
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
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data.docs[index]
                                            ['photoUrl'],
                                        name: snapshot.data.docs[index]['name'],
                                        description: snapshot.data.docs[index]
                                            ['description'],
                                        adresse: snapshot.data.docs[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data
                                            .docs[index]['ClickAndCollect'],
                                        livraison: snapshot.data.docs[index]
                                            ['livraison'],
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                  snapshot.data.docs[index]['photoUrl']),
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
                        )));
              });
        });
  }
}

class SliderAccueil4 extends StatefulWidget {
  @override
  _SliderAccueil4State createState() => _SliderAccueil4State();
}

class _SliderAccueil4State extends State<SliderAccueil4> {
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
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageDetail(
                                        img: snapshot.data.docs[index]
                                            ['photoUrl'],
                                        name: snapshot.data.docs[index]['name'],
                                        description: snapshot.data.docs[index]
                                            ['description'],
                                        adresse: snapshot.data.docs[index]
                                            ['adresse'],
                                        clickAndCollect: snapshot.data
                                            .docs[index]['ClickAndCollect'],
                                        livraison: snapshot.data.docs[index]
                                            ['livraison'],
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(
                                  snapshot.data.docs[index]['photoUrl']),
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
                        )));
              });
        });
  }
}
