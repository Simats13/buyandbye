import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:buyandbye/templates_commercant/new_product_next.dart';
import 'package:uuid/uuid.dart';

void testDataType(context, wrongField) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Text("Erreur"),
            content: Text(wrongField + " doit être un nombre"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"))
            ],
          ));
}

bool areFieldsFilled() {
  return true;
}

class NewProduct extends StatefulWidget {
  const NewProduct(this.myID, {Key? key}) : super(key: key);
  final String? myID;
  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  String? dropdownValue = 'Électroménager';
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
      isQuantityFilled = false,
      checkbox = true;
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BuyandByeAppTheme.blackElectrik,
        title: const Text("Ajouter un produit"),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nom du produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: nameField,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    isNameFilled = true;
                  } else {
                    isNameFilled = false;
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Référence produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: referenceField,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    isReferenceFilled = true;
                  } else {
                    isReferenceFilled = false;
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Description du produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionField,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    isDescriptionFilled = true;
                  } else {
                    isDescriptionFilled = false;
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Prix du produit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: priceField,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    isPriceFilled = true;
                  } else {
                    isPriceFilled = false;
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Quantité restante",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextField(
              controller: quantityField,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    isQuantityFilled = true;
                  } else {
                    isQuantityFilled = false;
                  }
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
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
                const SizedBox(width: 20),
                const Text("Visibilité du produit",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Catégorie",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Platform.isIOS
                ? TextButton(
                    child: Row(
                      children: [
                        Text(dropdownValue!,
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                        const SizedBox(width: 10),
                        Icon(Icons.arrow_drop_down,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black)
                      ],
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: CupertinoPicker(
                              itemExtent: 50,
                              backgroundColor: isDarkMode
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  dropdownValue = categorieNames[value];
                                });
                              },
                              children: [
                                for (String name in categorieNames)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(name,
                                        style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black)),
                                  )
                              ]),
                        ),
                      );
                    },
                  )
                : DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: categorieNames
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: BuyandByeAppTheme.orangeClair,
                    ),
                    child: MaterialButton(
                      onPressed: isNameFilled == true &&
                              isReferenceFilled == true &&
                              isDescriptionFilled == true &&
                              isPriceFilled == true &&
                              isQuantityFilled == true
                          ? () {
                              var reference = int.tryParse(referenceField.text);
                              var quantity = int.tryParse(quantityField.text);
                              var price = double.tryParse(priceField.text);
                              // Vérification du type de données
                              if (reference == null) {
                                testDataType(context, "La référence");
                              } else if (price == null) {
                                testDataType(context, "Le prix");
                              } else if (quantity == null) {
                                testDataType(context, "La quantité");
                              } else {
                                String productId = const Uuid().v4();
                                DatabaseMethods().createProduct(
                                    widget.myID,
                                    nameField.text,
                                    reference,
                                    descriptionField.text,
                                    price,
                                    quantity,
                                    productId,
                                    dropdownValue,
                                    checkbox);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewProductNext(
                                            widget.myID, productId)));
                              }
                            }
                          : null,
                      child: const Text("Continuer"),
                    )),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
