import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/fb_storage.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/image_controller.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';

// Fonction qui affiche une boîte de dialogue lorsqu'un mauvais type de valeur est entré
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

class DetailProduit extends StatefulWidget {
  const DetailProduit(this.uid, this.productId, {Key? key}) : super(key: key);
  final String? uid, productId;
  @override
  _DetailProduitState createState() => _DetailProduitState();
}

// Affiche toutes les informations sur un produit
class _DetailProduitState extends State<DetailProduit> {
  bool isVisible = false;
  int carouselItem = 0;
  String messageType = 'text';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: BuyandByeAppTheme.blackElectrik,
            title: const Text("Produit"),
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // Bouton pour modifier les informations d'un produit
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                    child: const Icon(Icons.edit_rounded),
                  )),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Bouton de suppression d'un produit
                  // Affiche un message pour demander confirmation avant suppression
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Supprimer le produit ?"),
                          content: const Text(
                              "Souhaitez-vous vraiment supprimer ce produit ?"),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Annuler")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      DatabaseMethods().deleteProduct(
                                          widget.uid, widget.productId);
                                    },
                                    child: const Text("Supprimer")),
                              ],
                            )
                          ],
                        );
                      });
                },
              ),
            ]),
        body: SingleChildScrollView(
            child: StreamBuilder<dynamic>(
                stream: DatabaseMethods()
                    .getOneProduct(widget.uid, widget.productId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    String? dropdownValue = snapshot.data["categorie"];
                    var carouselList =
                        Iterable<int>.generate(snapshot.data["images"].length)
                            .toList();
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        // Affiche toutes les images du produit dans un caroussel
                        CarouselSlider(
                            options: CarouselOptions(
                                height: 200,
                                // Les images tournent en boucle sauf s'il n'y en a qu'une
                                enableInfiniteScroll:
                                    snapshot.data["images"].length > 1
                                        ? true
                                        : false,
                                // Variable pour savoir l'image affichée
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    carouselItem = index;
                                  });
                                }),
                            // Affichage de chacune des images
                            items: carouselList.map((i) {
                              return Builder(builder: (context) {
                                return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Image.network(
                                        snapshot.data["images"][i]));
                              });
                            }).toList()),
                        const SizedBox(height: 10),
                        // Boutons d'ajout et de suppression d'image
                        isVisible
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 30),
                                    onPressed: () {
                                      ImageController.instance
                                          .cropImageFromFile()
                                          .then((croppedFile) {
                                        setState(() {
                                          messageType = 'image';
                                        });
                                        _saveUserImageToFirebaseStorage(
                                            croppedFile,
                                            context,
                                            widget.uid,
                                            widget.productId);
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      if (snapshot.data["images"].length > 1) {
                                        FBStorage.instance.deleteProductImage(
                                            widget.uid,
                                            widget.productId,
                                            snapshot.data["images"]
                                                [carouselItem]);
                                        FBStorage.instance
                                            .deleteProductImageFromStorage(
                                                snapshot.data["images"]
                                                    [carouselItem]);
                                      } else {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    "Impossible de supprimer l'image"),
                                                content: const Text(
                                                    "Un produit doit avoir au moins une image"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Confirmer"))
                                                ],
                                              );
                                            });
                                      }
                                    },
                                  )
                                ],
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 10),
                        // Indicateur du nombre d'images et de celle affichée
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 5),
                              for (int i = 0;
                                  i < snapshot.data["images"].length;
                                  i++)
                                Container(
                                    margin: const EdgeInsets.only(left: 5, right: 5),
                                    child: Icon(Icons.circle_rounded,
                                        size: 12,
                                        color: carouselItem == i
                                            ? Colors.black
                                            : Colors.grey))
                            ]),
                        const SizedBox(height: 10),
                        const Divider(thickness: 0.5, color: Colors.black),
                        // De base, affiche les informations du produit
                        Visibility(
                          visible: !isVisible,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                // Affiche en colonne toutes les autres informations
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Crée un container invisible qui prend toute la
                                    // largeur afin que les informations s'affichent
                                    // à gauche
                                    SizedBox(
                                      height: 0,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                    Text(snapshot.data["nom"],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 20),
                                    Text("Référence : " +
                                        snapshot.data["reference"].toString()),
                                    const SizedBox(height: 20),
                                    Text("Description : " +
                                        snapshot.data["description"]),
                                    const SizedBox(height: 20),
                                    Text("Prix : " +
                                    snapshot.data["prix"].toString() +
                                        "€"),
                                    const SizedBox(height: 20),
                                    Text("Restant : " +
                                        snapshot.data["quantite"].toString()),
                                    const SizedBox(height: 20),
                                    Text("Catégorie : " +
                                        snapshot.data["categorie"]),
                                    const SizedBox(height: 10),
                                    // Permet au commerçant de masquer un produit aux utilisateurs
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          snapshot.data["visible"]
                                              ? const Text("Masquer le produit : ")
                                              : const Text("Montrer le produit : "),
                                          TextButton(
                                              style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero),
                                              onPressed: () {
                                                // Boîte de dialogue pour confirmer que le produit a été masqué
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: snapshot
                                                                .data["visible"]
                                                            ? const Text(
                                                                "Produit masqué")
                                                            : const Text(
                                                                "Produit visible"),
                                                        content: snapshot
                                                                .data["visible"]
                                                            ? const Text(
                                                                "Le produit a bien été masqué et n'est plus visible par les clients")
                                                            : const Text(
                                                                "Le produit est désormais visible par tous les clients"),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                DatabaseMethods().hideOrShowProduct(
                                                                    widget.uid,
                                                                    widget
                                                                        .productId,
                                                                    snapshot.data[
                                                                        "visible"]);
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  "Confirmer"))
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: const Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.black,
                                                  size: 24))
                                        ]),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 0.5, color: Colors.black),
                            ],
                          ),
                        ),
                        // Si le bouton de modification est appuyé, remplace les
                        // informations par des champ de texte pour les modifier
                        Visibility(
                          visible: isVisible,
                          child: ModifyDetailProduit(
                              snapshot.data["nom"],
                              snapshot.data["prix"].toDouble(),
                              snapshot.data["description"],
                              snapshot.data["reference"],
                              snapshot.data["quantite"],
                              widget.uid,
                              widget.productId,
                              snapshot.data["categorie"],
                              dropdownValue),
                        )
                      ],
                    );
                  }
                })));
  }
}

class ModifyDetailProduit extends StatefulWidget {
  ModifyDetailProduit(
      this.nom,
      this.prix,
      this.desc,
      this.reference,
      this.quantite,
      this.uid,
      this.productId,
      this.categorie,
      this.dropdownValue, {Key? key}) : super(key: key);
  final String? nom, desc, uid, productId, categorie;
  String? dropdownValue;
  final double? prix;
  final int? reference, quantite;
  @override
  _ModifyDetailProduitState createState() => _ModifyDetailProduitState();
}

// Déclaration des variables pour les champs de modification
final nameField = TextEditingController();
final referenceField = TextEditingController();
final descriptionField = TextEditingController();
final priceField = TextEditingController();
final quantityField = TextEditingController();

// 2e classe qui affiche les champ de texte pour modifier les informations
class _ModifyDetailProduitState extends State<ModifyDetailProduit> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Nom du produit", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
          controller: nameField,
          decoration: InputDecoration(
              border: const OutlineInputBorder(), hintText: widget.nom),
              ),
              const SizedBox(height: 20),
              const Text("Référence produit", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
          controller: referenceField,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: widget.reference.toString()),
              ),
              const SizedBox(height: 20),
              const Text("Description du produit", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
          controller: descriptionField,
          decoration: InputDecoration(
              border: const OutlineInputBorder(), hintText: widget.desc),
              ),
              const SizedBox(height: 20),
              const Text("Prix du produit", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
          controller: priceField,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: widget.prix!.toStringAsFixed(2) + "€"),
              ),
              const SizedBox(height: 20),
              const Text("Quantité restante", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
          controller: quantityField,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: widget.quantite.toString()),
              ),
              const SizedBox(height: 20),
              const Text("Catégorie : ", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              // Liste des catégories disponibles
              Platform.isIOS
            ? TextButton(
                child: Row(
                  children: [
                    Text(widget.dropdownValue!,
                        style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black)),
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
                              widget.dropdownValue =
                                  categorieNames[value];
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
                value: widget.dropdownValue,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                iconSize: 24,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    widget.dropdownValue = newValue;
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
            ]),
        ),
        // Boutons pour annuler ou confirmer les modifications
        // Retourne à la page précédente
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: BuyandByeAppTheme.orange,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Annuler"),
                  )),
              Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: BuyandByeAppTheme.orangeFonce,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Si un champ est vide, on envoi la valeur déjà présente
                      var name =
                          nameField.text == "" ? widget.nom : nameField.text;
                      var reference = referenceField.text == ""
                          ? widget.reference
                          : int.tryParse(referenceField.text);
                      var description = descriptionField.text == ""
                          ? widget.desc
                          : descriptionField.text;
                      var price = priceField.text == ""
                          ? widget.prix
                          : double.tryParse(priceField.text);
                      var quantity = quantityField.text == ""
                          ? widget.quantite
                          : int.tryParse(quantityField.text);
                      // Vérification du type de données
                      // Si un type n'est pas bon, on le signale à l'utilisateur
                      if (reference == null) {
                        testDataType(context, "La référence");
                      } else if (price == null) {
                        testDataType(context, "Le prix");
                      } else if (quantity == null) {
                        testDataType(context, "La quantité");
                      } else {
                        // Envoi des données lorsque tous les champs ont le bon type
                        Navigator.pop(context);
                        DatabaseMethods().updateProduct(
                            widget.uid,
                            widget.productId,
                            name,
                            reference,
                            description,
                            price,
                            quantity,
                            widget.dropdownValue);
                      }
                    },
                    child: const Text("Confirmer"),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 50)
      ],
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
