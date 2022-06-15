import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Pages/page_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class PageCategorie extends StatefulWidget {
  const PageCategorie(
      {Key? key,
      this.img,
      this.name,
      this.description,
      this.adresse,
      this.categorie,
      this.horairesOuverture
      })
      : super(key: key);

  final String? img, name, description, adresse, categorie;
  final Map? horairesOuverture;

  @override
  _PageCategorieState createState() => _PageCategorieState();
}

class _PageCategorieState extends State<PageCategorie> {
  double latitude = 0.0, longitude = 0.0;

  final radius = BehaviorSubject<double>.seeded(1.0);
  Stream<List<DocumentSnapshot>>? stream;
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    var userid = user.uid;
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getChosenAddress(userid);
    latitude = double.parse("${querySnapshot.docs[0]['latitude']}");
    longitude = double.parse("${querySnapshot.docs[0]['longitude']}");
    setState(() {
      Geoflutterfire geo = Geoflutterfire();
      GeoFirePoint center = geo.point(latitude: latitude, longitude: longitude);

      stream = radius.switchMap((rad) {
        var collectionReference = FirebaseFirestore.instance
            .collection('magasins')
            .where("mainCategorie", arrayContains: widget.categorie);
        return geo.collection(collectionRef: collectionReference).within(
            center: center, radius: 10, field: 'position', strictMode: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyandByeAppTheme.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: RichText(
            text: TextSpan(
              // style: Theme.of(context).textTheme.bodyText2,
              children: [
                TextSpan(
                    text: widget.categorie,
                    style: const TextStyle(
                      fontSize: 20,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.asset(
                        widget.img!,
                        width: 30,
                        height: 30,
                      )),
                ),
              ],
            ),
          ),
          backgroundColor: BuyandByeAppTheme.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: BuyandByeAppTheme.orange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
          bottomOpacity: 0.0,
        ),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return StreamBuilder<dynamic>(
        stream: stream,
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
          if (snapshot.data.length > 0) {
            return Column(
              children: [
                ListView.builder(
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
                        sellerID: ds["id"],
                        horairesOuverture: ds["horairesOuverture"]);
                  },
                ),
              ],
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
        });
  }

  Widget searchedData(
      {String? photoUrl,
      name,
      description,
      adresse,
      clickAndCollect,
      livraison,
      colorStore,
      sellerID, horairesOuverture}) {
    return ListTile(
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
                    horairesOuverture: horairesOuverture
                  )),
        );
      },
      leading: SizedBox(
        child: Center(
          child: Image.network(
            photoUrl!,
          ),
        ),
        height: 100,
        width: 100,
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      subtitle: Text(
        adresse,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
      ),
    );
  }
}
