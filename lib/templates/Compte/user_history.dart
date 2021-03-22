import 'package:flutter/material.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/templates/pages/pageCompte.dart';
import 'package:oficihome/theme/colors.dart';

void main() => runApp(UserHistory());

class UserHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Historique d'achat",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DropdownMenuItem<String>> duration = [];
  String def;
  void listDuration() {
    duration.clear();
    duration.add(DropdownMenuItem(
        value: "7 jours",
        child: Text("7 jours",
            style: TextStyle(fontSize: 18, color: Colors.black))));
    duration.add(DropdownMenuItem(
        value: "14 jours",
        child: Text("14 jours",
            style: TextStyle(fontSize: 18, color: Colors.black))));
    duration.add(DropdownMenuItem(
        value: "30 jours",
        child: Text("30 jours",
            style: TextStyle(fontSize: 18, color: Colors.black))));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    listDuration();
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Historique d'achat", style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: OficihomeAppTheme.orange,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => PageCompte()));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //Menu déroulant
            DropdownButton(
                value: def,
                elevation: 2,
                items: duration,
                hint: Text("Durée",
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                onChanged: (value) {
                  def = value;
                  setState(() {});
                }),
            SizedBox(
              height: 30,
            ),
            //Historique des achats
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("18 février",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                SizedBox(
                  height: 10,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Fnac Nîmes",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Image(
                                  image: NetworkImage(
                                      "https://static.fnac-static.com/multimedia/Images/FR/MDM/14/55/5d/6116628/1505-1/tsp20201130170913/Apple-AirPods-2-avec-boitier-de-charge-Ecouteurs-sans-fil-True-Wirele.jpg"),
                                  height: 50,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "AirPods",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "179.99€",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            //Achat 2
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("22 janvier",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: black.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Boulanger Nîmes",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Image(
                                      image: NetworkImage(
                                          "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/mbp16touch-space-select-201911_GEO_EMEA_LANG_FR?wid=892&hei=820&&qlt=80&.v=1573151654798"),
                                      height: 50,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "MacBook Pro 16\"",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "1999.99€",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      //Article 2
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image(
                                  image: NetworkImage(
                                      "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/MLA22LL?wid=1144&hei=1144&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1496944005839"),
                                  height: 50,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Magic Keyboard",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "99.99€",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      //Article 3
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image(
                                  image: NetworkImage(
                                      "https://image.darty.com/accessoires/peripherique-souris/souris/apple_magic_mouse_2_s1512114180470B_210010913.jpg"),
                                  height: 50,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Magic Mouse",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "84.99€",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: black.withOpacity(0.3),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "2184.99€",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
