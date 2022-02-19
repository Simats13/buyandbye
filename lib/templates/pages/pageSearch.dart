import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/json/menu_json.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/pages/pageCategorie.dart';
import 'package:buyandbye/templates/pages/pageDetail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:algolia/algolia.dart';
import 'package:buyandbye/services/AlgoliaApplication.dart';
import '../buyandbye_app_theme.dart';

class PageSearch extends StatefulWidget {
  @override
  _PageSearchState createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm = "";

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("magasins").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  final TextEditingController searchController = TextEditingController();
  QuerySnapshot? snapshotData;
  Stream? streamStore;
  bool affichageCategories = true;
  bool isExecuted = false;
  int activeMenu = 0;

  Widget searchedData({
    required String photoUrl,
    required name,
    description,
    required adresse,
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
    return StreamBuilder<dynamic>(
      stream: streamStore,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Shimmer.fromColors(
            child: Container(
              child: Stack(
                children: [
                  Center(
                    child: ListTile(
                      leading: Container(
                        height: 100,
                        width: 100,
                      ),
                      title: Text(
                        "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      subtitle: Text(
                        "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
          );
        }
        if (snapshot.data.docs.length > 0) {
          return ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
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
          );
        } else {
          return Container(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(
                  'assets/images/splash_2.png',
                  width: 300,
                  height: 300,
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Aucun commerce n'est disponible dans cette catégorie pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                    style: TextStyle(
                      fontSize: 18,
                      // color: Colors.grey[700]
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            )),
          );
        }
      },
    );
  }

  research() async {
    isExecuted = true;
    setState(() {});
    streamStore =
        await DatabaseMethods().searchBarGetStoreInfo(searchController.text);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: BuyandByeAppTheme.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            title: RichText(
              text: TextSpan(
                // style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(
                      text: 'Recherche',
                      style: TextStyle(
                        fontSize: 20,
                        color: BuyandByeAppTheme.orangeMiFonce,
                        fontWeight: FontWeight.bold,
                      )),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Icon(
                        Icons.search,
                        color: BuyandByeAppTheme.orangeFonce,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: BuyandByeAppTheme.white,
            automaticallyImplyLeading: false,
            elevation: 0.0,
            bottomOpacity: 0.0,
          ),
        ),
        body: Column(
          children: [
            Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey, width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (val) {
                      setState(() {
                        affichageCategories = !affichageCategories;
                        _searchTerm = val;
                      });
                    },
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Trouver un commerçant ...',
                        hintStyle: TextStyle(color: Colors.black),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black))),
              ),
            StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm)),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Text(
                    "Start Typing",
                    style: TextStyle(color: Colors.black),
                  );
                else {
                  List<AlgoliaObjectSnapshot>? currSearchStuff = snapshot.data;

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      else
                        return CustomScrollView(
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _searchTerm.length > 0
                                      ? DisplaySearchResult(
                                          nameMagasin: currSearchStuff![index]
                                              .data["name"])
                                      : Container();
                                },
                                childCount: currSearchStuff!.length,
                              ),
                            ),
                          ],
                        );
                  }
                }
              },
            ),
            affichageCategories ? CategoryStore() : Container()
          ],
        ),
      ),
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
                print(categories[index]['name']);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageCategorie(
                      categorie: categories[index]['name'],
                      img: categories[index]['img'],
                    ),
                  ),
                );
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

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}

class DisplaySearchResult extends StatelessWidget {
  final String nameMagasin;

  DisplaySearchResult({Key? key, required this.nameMagasin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(
        nameMagasin,
        style: TextStyle(color: Colors.black),
      ),
      Divider(
        color: Colors.black,
      ),
      SizedBox(height: 20)
    ]);
  }
}
