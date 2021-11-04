import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/json/menu_json.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/pages/pageCategorie.dart';
import 'package:buyandbye/templates/pages/pageDetail.dart';
import 'package:buyandbye/theme/styles.dart';

import '../buyandbye_app_theme.dart';

class PageSearch extends StatefulWidget {
  @override
  _PageSearchState createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  final TextEditingController searchController = TextEditingController();
  QuerySnapshot snapshotData;
  Stream streamStore;
  bool isExecuted = false;
  int activeMenu = 0;

  Widget searchedData({
    String photoUrl,
    name,
    description,
    adresse,
    clickAndCollect,
    livraison,
    colorStore,
    sellerID,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PageDetail(
                    img: photoUrl,
                    name: name,
                    description: description,
                    adresse: adresse,
                    clickAndCollect: clickAndCollect,
                    livraison: livraison,
                    sellerID: sellerID,
                    colorStore: colorStore,
                  )),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(photoUrl),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
        ),
        subtitle: Text(
          adresse,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
    );
  }

  Widget searchStoreList() {
    return StreamBuilder(
      stream: streamStore,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: snapshot.data.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data[index];
                  return searchedData(
                      photoUrl: ds["imgUrl"],
                      name: ds["name"],
                      adresse: ds["adresse"],
                      description: ds["description"],
                      clickAndCollect: ds["ClickAndCollect"],
                      livraison: ds["livraison"],
                      colorStore: ds["colorStore"],
                      sellerID: ds["id"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  research() async {
    isExecuted = true;
    double latitude =
        await SharedPreferenceHelper().getUserLatitude() ?? 43.834647;
    double longitude =
        await SharedPreferenceHelper().getUserLongitude() ?? 4.359620;
    setState(() {});
    streamStore = await DatabaseMethods()
        .searchBarGetStoreInfo(searchController.text, latitude, longitude);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              title: Text('Rechercher'),
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: BuyandByeAppTheme.black_electrik,
              automaticallyImplyLeading: false,
            ),
          ),
          body: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Row(children: [
                  isExecuted
                      ? GestureDetector(
                          onTap: () {
                            isExecuted = false;
                            searchController.text = "";
                            setState(() {});
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_back)),
                        )
                      : Container(),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              if (value.length > 0) {
                                research();
                              }
                              if (value.length < 1) {
                                setState(() {
                                  isExecuted = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                                hintText: 'Rechercher un commerce'),
                            controller: searchController,
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              if (searchController.text != "") {
                                research();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ))
                ]),
                isExecuted ? searchStoreList() : CategoryStore()
              ]))),
    );
  }
}

class CategoryStore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            // color: Colors.white30,
            child: GridView.count(
      crossAxisCount: 3,
      children: List.generate(
        categories.length,
        (index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PageCategorie(
                            categorie: categories[index]['name'])));
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                  ),
                  Image.asset(
                    categories[index]['img'],
                    width: 40,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    categories[index]['name'],
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ));
        },
      ),
    )));
  }
}
