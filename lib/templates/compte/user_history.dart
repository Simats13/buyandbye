import 'package:flutter/material.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:intl/intl.dart';

class UserHistory extends StatefulWidget {
  @override
  _UserHistoryState createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  //Initialisation de la DropDownList
  List<DropdownMenuItem<String>> duration = [];
  String def;

  //Initialisation de la liste des achats de l'utilisateur
  List purchase = [];
  fetchDatabaseList() async {
    dynamic result = await DatabaseMethods().getPurchase();
    if (result == null) {
      print('Impossible de retrouver les données');
    } else {
      setState(() {
        purchase = result;
      });
    }
  }

  void listDuration() {
    duration.clear();
    duration.add(DropdownMenuItem(
        value: "7 jours",
        child: Text("7 jours", style: TextStyle(fontSize: 18))));
    duration.add(DropdownMenuItem(
        value: "14 jours",
        child: Text("14 jours", style: TextStyle(fontSize: 18))));
    duration.add(DropdownMenuItem(
        value: "30 jours",
        child: Text("30 jours", style: TextStyle(fontSize: 18))));
  }

  @override
  void initState() {
    super.initState();
    fetchDatabaseList();
  }

  String formatTimestamp(var timestamp) {
    var format = new DateFormat('d/MM/y');
    return format.format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    listDuration();
    return FutureBuilder(
        future: DatabaseMethods().getPurchase(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: OficihomeAppTheme.black_electrik,
                title: Text("Historique d'achat"),
                elevation: 1,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: OficihomeAppTheme.orange,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
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
                        hint: Text("Durée", style: TextStyle(fontSize: 18)),
                        onChanged: (value) {
                          def = value;
                          setState(() {});
                        }),
                    SizedBox(
                      height: 30,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: purchase.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formatTimestamp(purchase[index]['Date']),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          purchase[index]["shopName"],
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
                                                  purchase[index]
                                                      ["productImage"]),
                                              height: 50,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              purchase[index]["productName"],
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
                                          purchase[index]["productPrice"]
                                                  .toString() +
                                              "€",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 30)
                          ],
                        );
                      },
                    ),
                    //Historique des achats
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
