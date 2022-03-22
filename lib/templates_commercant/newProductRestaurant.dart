import 'package:buyandbye/templates/Connexion/Tools/or_divider.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

void testDataType(context, wrongField) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text("Erreur"),
            content: Text(wrongField + " doit être un nombre"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ],
          ));
}

bool areFieldsFilled() {
  return true;
}

class NewProductRestaurant extends StatefulWidget {
  const NewProductRestaurant(this.myID);
  final String? myID;
  _NewProductRestaurantState createState() => _NewProductRestaurantState();
}

class _NewProductRestaurantState extends State<NewProductRestaurant> {
  String? dropdownValue = 'Électroménager';
  final nameField = TextEditingController();
  final descriptionField = TextEditingController();
  final priceField = TextEditingController();
  bool isEnabled = false,
      isNameFilled = false,
      isDescriptionFilled = false,
      isPriceFilled = false,
      checkbox = true;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BuyandByeAppTheme.black_electrik,
        title: Text("Ajouter un produit"),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Importer un menu (.jpg, .png, .pdf)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            IconButton(
                icon: new Icon(
                  Icons.photo,
                  size: 30,
                ),
                onPressed: () {
                  print("Importer un menu");
                  // ImageController.instance
                  //     .cropImageFromFile()
                  //     .then((croppedFile) {
                  //   setState(() {
                  //     messageType = 'image';
                  //   });
                  //   _saveUserImageToFirebaseStorage(
                  //       croppedFile, context, widget.myID, widget.productId);
                  // });
                }),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                ),
                OrDivider(),
              ],
            ),
            SizedBox(height: 20),
            Text("Nom du produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            TextField(
              controller: nameField,
              onChanged: (value) {
                setState(() {
                  if (value.length > 0) {
                    isNameFilled = true;
                  } else {
                    isNameFilled = false;
                  }
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text("Description du produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            TextField(
              controller: descriptionField,
              onChanged: (value) {
                setState(() {
                  if (value.length > 0) {
                    isDescriptionFilled = true;
                  } else {
                    isDescriptionFilled = false;
                  }
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text("Prix du produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            TextField(
              controller: priceField,
              onChanged: (value) {
                setState(() {
                  if (value.length > 0) {
                    isPriceFilled = true;
                  } else {
                    isPriceFilled = false;
                  }
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text("Catégorie",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: checkbox,
                    onChanged: (value) {
                      setState(() {
                        checkbox = !checkbox;
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                Text("Visibilité du produit",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: BuyandByeAppTheme.orangeClair,
                    ),
                    child: MaterialButton(
                      onPressed: isNameFilled == true &&
                              isDescriptionFilled == true &&
                              isPriceFilled == true
                          ? () {
                              var price = double.tryParse(priceField.text);
                              // Vérification du type de données
                              if (price == null) {
                                testDataType(context, "Le prix");
                              } else {
                                print("Données envoyées");
                                // Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => NewProductNext(
                                //             widget.myID, productId)));
                              }
                            }
                          : null,
                      child: Text("Continuer"),
                    )),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
