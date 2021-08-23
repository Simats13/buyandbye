import 'package:flutter/material.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/Messagerie/Controllers/fb_storage.dart';
import 'package:oficihome/templates/Messagerie/Controllers/image_controller.dart';
import 'package:oficihome/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

class NewProductNext extends StatefulWidget {
  const NewProductNext(this.myID, this.productId);
  final String myID, productId;
  _NewProductNextState createState() => _NewProductNextState();
}

class _NewProductNextState extends State<NewProductNext> {
  String messageType = 'text';
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un produit"),
        elevation: 1,
        leading: Container(),
      ),
      body: StreamBuilder(
          stream: DatabaseMethods()
              .getOneProduct("Cv9qOrGZdeP43A9HaThftEyPEp22", "test"),
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
                                fontSize: 16, fontWeight: FontWeight.w700)),
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
                                if (croppedFile != null) {
                                  setState(() {
                                    messageType = 'image';
                                  });
                                  _saveUserImageToFirebaseStorage(croppedFile,
                                      context, widget.myID, widget.productId);
                                } else {
                                  showAlertDialog(context, 'Pick Image error');
                                }
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
                                    color: OficihomeAppTheme.orange,
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Terminer"),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                        Text("Images enregistrées :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(height: 30),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          child: GridView.builder(
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
                                      height:
                                          MediaQuery.of(context).size.height,
                                      padding: const EdgeInsets.all(8),
                                      child: Image.network(
                                          snapshot.data["images"][index])),
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 3,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                            color: OficihomeAppTheme.orange,
                                          ),
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.delete,
                                                  color: Colors.white,
                                                  size: 14),
                                              onPressed: () {})))
                                ]);
                              }),
                        )
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
    String takeImageURL = await FBStorage.instanace
        .uploadProductPhotosToFb(croppedFile, sellerID, productID);
    return takeImageURL;
  } catch (e) {
    showAlertDialog(context, 'Error add user image to storage');
  }
}
