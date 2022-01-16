import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/fb_storage.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/image_controller.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

class NewProductNext extends StatefulWidget {
  const NewProductNext(this.myID, this.productId);
  final String? myID, productId;
  _NewProductNextState createState() => _NewProductNextState();
}

class _NewProductNextState extends State<NewProductNext> {
  String messageType = 'text';
  Widget build(BuildContext context) {
    String brightness = MediaQuery.of(context).platformBrightness.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BuyandByeAppTheme.black_electrik,
        title: Text("Ajouter un produit"),
        elevation: 1,
        leading: Container(),
      ),
      body: StreamBuilder<dynamic>(
          stream:
              DatabaseMethods().getOneProduct(widget.myID, widget.productId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Ajoutez des images",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 20),
                        IconButton(
                            icon: new Icon(
                              Icons.photo,
                              size: 30,
                            ),
                            onPressed: () {
                              ImageController.instance
                                  .cropImageFromFile()
                                  .then((croppedFile) {
                                setState(() {
                                  messageType = 'image';
                                });
                                _saveUserImageToFirebaseStorage(croppedFile,
                                    context, widget.myID, widget.productId);
                              });
                            }),
                        SizedBox(height: 30),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  height: 35,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: BuyandByeAppTheme.orange,
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      if (snapshot.data["images"].length == 0) {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Aucune image enregistrée"),
                                                content: Text(
                                                    "Vous n'avez enregistré aucune image pour ce produit.\nSi vous continuez, une image par défaut sera enregistrée"),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              Text("Annuler")),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "magasins")
                                                                .doc(
                                                                    widget.myID)
                                                                .collection(
                                                                    "produits")
                                                                .doc(widget
                                                                    .productId)
                                                                .update({
                                                              "images": [
                                                                "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Pas_d%27image_disponible.svg/1024px-Pas_d%27image_disponible.svg.png"
                                                              ]
                                                            });
                                                          },
                                                          child:
                                                              Text("Continuer"))
                                                    ],
                                                  )
                                                ],
                                              );
                                            });
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text("Terminer"),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                        Text("Images enregistrées :",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 30),
                        Stack(children: [
                          Center(
                              child: Text(
                                  "Aucune image enregistrée pour ce produit",
                                  style: TextStyle(fontSize: 16))),
                          snapshot.data["images"].length != 0
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: brightness == "Brightness.light"
                                          ? Color.fromRGBO(250, 250, 250, 1)
                                          : Color.fromRGBO(48, 48, 48, 1)),
                                  height: MediaQuery.of(context).size.height,
                                  child: GridView.builder(
                                      physics: ScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 150,
                                              childAspectRatio: 1,
                                              mainAxisSpacing: 20,
                                              crossAxisSpacing: 20),
                                      itemCount: snapshot.data["images"].length,
                                      itemBuilder: (context, index) {
                                        return Stack(children: [
                                          Container(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              padding: const EdgeInsets.all(8),
                                              child: Image.network(snapshot
                                                  .data["images"][index])),
                                          Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      width: 3,
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor,
                                                    ),
                                                    color: BuyandByeAppTheme
                                                        .orange,
                                                  ),
                                                  child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.white,
                                                          size: 20),
                                                      onPressed: () {
                                                        FBStorage.instance
                                                            .deleteProductImage(
                                                                widget.myID,
                                                                widget
                                                                    .productId,
                                                                snapshot.data[
                                                                        "images"]
                                                                    [index]);
                                                      })))
                                        ]);
                                      }),
                                )
                              : Container(height: 0, width: 0),
                        ])
                      ],
                    )),
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

Future<void> _saveUserImageToFirebaseStorage(
    croppedFile, context, sellerID, productID) async {
  try {
    await FBStorage.instance
        .uploadProductPhotosToFb(croppedFile, sellerID, productID);
  } catch (e) {
    showAlertDialog(context, 'Error add user image to storage');
  }
}
