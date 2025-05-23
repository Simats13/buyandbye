import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/json/menu_json.dart';
import 'package:buyandbye/templates/pages/page_categorie.dart';
import 'package:buyandbye/templates/pages/page_detail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:algolia/algolia.dart';
import 'package:buyandbye/services/algolia_application.dart';
import '../buyandbye_app_theme.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({Key? key}) : super(key: key);

  @override
  _PageSearchState createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  // String _searchTerm = "";
  final TextEditingController _searchTerm = TextEditingController();

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("magasins").query(input);
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

  Widget searchedData(
      {required String photoUrl,
      required name,
      description,
      required adresse,
      clickAndCollect,
      livraison,
      colorStore,
      sellerID,
      horairesOuverture}) {
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
                    horairesOuverture: horairesOuverture,
                  )),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(photoUrl),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
        ),
        subtitle: Text(
          adresse,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
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
            child: Stack(
              children: const [
                Center(
                  child: ListTile(
                    leading: SizedBox(
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
                  horairesOuverture: ds["horairesOuverture"],
                  colorStore: ds["colorStore"],
                  sellerID: ds["id"]);
            },
          );
        } else {
          return Center(
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
                child: const Text(
                  "Aucun commerce n'est disponible dans cette catégorie pour le moment. Vérifiez de nouveau un peu plus tard, lorsque les établisements auront ouvert leurs portes.",
                  style: TextStyle(
                    fontSize: 18,
                    // color: Colors.grey[700]
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: BuyandByeAppTheme.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            title: RichText(
              text: const TextSpan(
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
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
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
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey, width: 1, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(20)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _searchTerm.text.isNotEmpty ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchTerm.text = "";
                      });
                    },
                    child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(right: 12),
                        child: const Icon(Icons.close)),
                  ) : Container(),
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: TextField(
                        controller: _searchTerm,
                        textInputAction: TextInputAction.search,
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (val) {
                          setState(() {
                            _searchTerm.text = val;
                          });
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 14),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: InputBorder.none,
                          hintText: 'Trouver un commerçant ...',
                        )),
                  ),
                  Container(
                    child: const Icon(Icons.search),
                    alignment: Alignment.centerRight,
                  )
                ],
              ),
            ),
            StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm.text)),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    "",
                    style: TextStyle(color: Colors.black),
                  );
                } else {
                  List<AlgoliaObjectSnapshot>? currSearchStuff = snapshot.data;

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return CustomScrollView(
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _searchTerm.text.isNotEmpty
                                      ? DisplaySearchResult(
                                          imgMagasin: currSearchStuff![index]
                                              .data["imgUrl"],
                                          nameMagasin: currSearchStuff[index]
                                              .data["name"],
                                          adresseMagasin: currSearchStuff[index]
                                              .data["adresse"],
                                          descriptionMagasin:
                                              currSearchStuff[index]
                                                  .data["description"],
                                          clickAndCollectMagasin:
                                              currSearchStuff[index]
                                                  .data["ClickAndCollect"],
                                          livraisonMagasin:
                                              currSearchStuff[index]
                                                  .data["livraison"],
                                          horairesOuverture:
                                              currSearchStuff[index]
                                                  .data["horairesOuverture"],
                                          colorStoreMagasin:
                                              currSearchStuff[index]
                                                  .data["colorStore"],
                                          sellerIDMagasin:
                                              currSearchStuff[index].data["id"])
                                      : Container();
                                },
                                childCount: currSearchStuff!.length,
                              ),
                            ),
                          ],
                        );
                      }
                  }
                }
              },
            ),
            _searchTerm.text.isNotEmpty ? Container() : const CategoryStore(),
          ],
        ),
      ),
    );
  }
}

class CategoryStore extends StatelessWidget {
  const CategoryStore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                  categorie: categories[index]['name'],
                  img: categories[index]['img'],
                ),
              ),
            );
          },
          child: Column(
            children: [
              const SizedBox(
                height: 20,
                width: 20,
              ),
              Image.asset(
                categories[index]['img'],
                width: 40,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                categories[index]['name'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ));
        },
      ),
    ));
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}

class DisplaySearchResult extends StatelessWidget {
  final String nameMagasin, adresseMagasin, imgMagasin;
  String? descriptionMagasin, colorStoreMagasin, sellerIDMagasin;
  bool? clickAndCollectMagasin, livraisonMagasin;
  Map? horairesOuverture;

  DisplaySearchResult(
      {Key? key,
      required this.nameMagasin,
      required this.imgMagasin,
      required this.adresseMagasin,
      this.clickAndCollectMagasin,
      this.colorStoreMagasin,
      this.descriptionMagasin,
      this.livraisonMagasin,
      this.sellerIDMagasin,
      this.horairesOuverture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PageDetail(
                      img: imgMagasin,
                      name: nameMagasin,
                      description: descriptionMagasin,
                      adresse: adresseMagasin,
                      clickAndCollect: clickAndCollectMagasin,
                      livraison: livraisonMagasin,
                      sellerID: sellerIDMagasin,
                      horairesOuverture: horairesOuverture,
                      colorStore: colorStoreMagasin,
                    )),
          );
        },
        leading: SizedBox(
          child: Center(child: Image.network(imgMagasin)),
          height: 100,
          width: 100,
        ),
        title: Text(
          nameMagasin,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        subtitle: Text(
          adresseMagasin,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
      ),
      const Divider(
        color: Colors.black,
      ),
      const SizedBox(height: 20)
    ]);
  }
}
