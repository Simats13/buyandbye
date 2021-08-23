import 'package:flutter/material.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';
import 'package:oficihome/templates_commercant/NewProductNext.dart';
import 'package:uuid/uuid.dart';

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

class NewProduct extends StatefulWidget {
  const NewProduct(this.myID);
  final String myID;
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  String dropdownValue = 'Électroménager';
  final nameField = TextEditingController();
  final referenceField = TextEditingController();
  final descriptionField = TextEditingController();
  final priceField = TextEditingController();
  final quantityField = TextEditingController();
  bool isEnabled = false,
      isNameFilled = false,
      isReferenceFilled = false,
      isDescriptionFilled = false,
      isPriceFilled = false,
      isQuantityFilled = false;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            Text("Nom du produit", style: TextStyle(fontSize: 16)),
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
            Text("Référence produit", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: referenceField,
              onChanged: (value) {
                setState(() {
                  if (value.length > 0) {
                    isReferenceFilled = true;
                  } else {
                    isReferenceFilled = false;
                  }
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text("Description du produit", style: TextStyle(fontSize: 16)),
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
            Text("Prix du produit", style: TextStyle(fontSize: 16)),
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
            Text("Quantité restante", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: quantityField,
              onChanged: (value) {
                setState(() {
                  if (value.length > 0) {
                    isQuantityFilled = true;
                  } else {
                    isQuantityFilled = false;
                  }
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Text("Catégorie", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconSize: 24,
              elevation: 16,
              // style: const TextStyle(color: Colors.deepPurple),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items:
                  categorieNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Nom de la catégorie sélectionnée
            SizedBox(height: 20),
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
                      color: OficihomeAppTheme.orangeClair,
                    ),
                    child: MaterialButton(
                      onPressed: 
                          //     isNameFilled == true &&
                          //     isReferenceFilled == true &&
                          //     isDescriptionFilled == true &&
                          //     isPriceFilled == true &&
                          //     isQuantityFilled == true
                          // ? 
                          () {
                              // var reference = int.tryParse(referenceField.text);
                              // var quantity = int.tryParse(quantityField.text);
                              // var price = double.tryParse(priceField.text);
                              // // Vérification du type de données
                              // if (reference == null) {
                              //   testDataType(context, "La référence");
                              // } else if (price == null) {
                              //   testDataType(context, "Le prix");
                              // } else if (quantity == null) {
                              //   testDataType(context, "La quantité");
                              // } else {
                                String productId = Uuid().v4();
                              //   DatabaseMethods().createProduct(
                              //       widget.myID,
                              //       nameField.text,
                              //       reference,
                              //       descriptionField.text,
                              //       price,
                              //       quantity,
                              //       productId,
                              //       dropdownValue);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewProductNext(
                                            widget.myID, productId)));
                              },
                            // }
                          // : null,
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
