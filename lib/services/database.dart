import 'dart:async';
import 'package:buyandbye/services/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class DatabaseMethods {
  static DatabaseMethods get instance => DatabaseMethods();
  Map<String, dynamic>? paymentIntentData;

  // Future<QuerySnapshot> getMyInfo(String? userid) async {
  //   return await FirebaseFirestore.instance.collection("users").where("id", isEqualTo: userid).get();
  // }

  Future deleteUser(String userID, customerID) async {
    return await FirebaseFirestore.instance.collection("users").doc(userID).delete();
  }

  Future deleteAddress(String? idDoc) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    QuerySnapshot _myDoc = await FirebaseFirestore.instance.collection("users").doc(userid).collection("Address").get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    if (_myDocCount.length == 1) {
      return false;
    } else {
      await FirebaseFirestore.instance.collection("users").doc(userid).collection("Address").doc(idDoc).delete();

      // Vérifie si l'adresse supprimée est la première
      if (_myDocCount[0]["idDoc"] == idDoc) {
        // Nouvelle requête pour ne pas garder l'adresse qui a été supprimée dans _myDoc
        QuerySnapshot _myDoc2 = await FirebaseFirestore.instance.collection("users").doc(userid).collection("Address").get();
        List<DocumentSnapshot> _myDocCount2 = _myDoc2.docs;

        await FirebaseFirestore.instance.collection("users").doc(userid).collection("Address").doc(_myDocCount2[0]["idDoc"]).update({"chosen": true});
      } else {}

      return true;
    }
  }

  Future checkIfDocExists(String docId) async {
    return await FirebaseFirestore.instance.collection("users").doc(docId).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        return true;
      } else {
        return false;
      }
    });
  }

  // Future checkIfAddressExist(String docId) async {
  //   return await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(docId)
  //       .collection('Address')
  //       .get()
  //       .then((DocumentSnapshot ds) {
  //     if (ds.exists) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   });
  // }

  Future addInfoToDB(String collection, userid, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance.collection(collection).doc(userid).set(userInfoMap);
  }

  createChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance.collection("commonData").doc(chatRoomId).get();

    if (snapShot.exists) {
      //chatroom already exists
      return true;
    } else {
      //chatroom does not exists
      return FirebaseFirestore.instance.collection("commonData").doc(chatRoomId).set(chatRoomInfoMap as Map<String, dynamic>);
    }
  }

  Future updateUserInfo(userId, lname, fname, email, phone) async {
    return FirebaseFirestore.instance.collection("users").doc(userId).update({"lname": lname, "fname": fname, "email": email, "phone": phone});
  }

  Future updateSellerInfo(userId, fName, lName, email, phone) async {
    return FirebaseFirestore.instance.collection("magasins").doc(userId).update({"fname": fName, "lname": lName, "email": email, "phone": phone});
  }

  Future<QuerySnapshot> getMagasinInfo(String? sellerId) async {
    return await FirebaseFirestore.instance.collection("magasins").where("id", isEqualTo: sellerId).get();
  }

  Stream getSellerInfo(userId) {
    return FirebaseFirestore.instance.collection("magasins").doc(userId).snapshots();
  }

  Future<QuerySnapshot> getStoreInfo() async {
    return await FirebaseFirestore.instance.collection("magasins").get();
  }

  Future getMagasin() async {
    List magasinList = [];

    try {
      await FirebaseFirestore.instance.collection('magasins').get().then((querySnapshot) {
        for (var element in querySnapshot.docs) {
          magasinList.add(element.data());
        }
      });
      return magasinList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream getProducts(String? sellerId) {
    return FirebaseFirestore.instance.collection("magasins").doc(sellerId).collection("produits").snapshots();
  }

  // On ne récupère que les produits que le commerçant a choisi comme étant visible par les clients
  // Stream getVisibleProducts(String? sellerId, String? selectedCategorie) {
  //   Stream query = FirebaseFirestore.instance
  //       .collection("magasins")
  //       .doc(sellerId)
  //       .snapshots();
  //   return query;
  // }

  Stream getVisibleProducts(String? sellerId, String? selectedCategorie) {
    Stream query = FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .where("visible", isEqualTo: true)
        .where("categorie", isEqualTo: selectedCategorie)
        .limit(6)
        .snapshots();
    return query;
  }

  Stream getOneProduct(sellerId, productId) {
    return FirebaseFirestore.instance.collection("magasins").doc(sellerId).collection("produits").doc(productId).snapshots();
  }

  Future getOneProductFuture(sellerId, productId) {
    return FirebaseFirestore.instance.collection("magasins").doc(sellerId).collection("produits").doc(productId).get();
  }

  Future createProduct(sellerId, name, reference, description, price, quantity, id, categorie, visibility) {
    return FirebaseFirestore.instance.collection("magasins").doc(sellerId).collection("produits").doc(id).set({
      'nom': name,
      'reference': reference,
      'description': description,
      'prix': price,
      'quantite': quantity,
      'id': id,
      'categorie': categorie,
      'visible': visibility,
      'images': []
    });
  }

  Future updateProduct(sellerId, productId, name, reference, description, price, quantity, category) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .update({'nom': name, 'reference': reference, 'description': description, 'prix': price, 'quantite': quantity, 'categorie': category});
  }

  Future hideOrShowProduct(sellerId, productId, visibility) {
    return FirebaseFirestore.instance.collection("magasins").doc(sellerId).collection("produits").doc(productId).update({"visible": !visibility});
  }

  Future deleteProduct(sellerId, productId) {
    return FirebaseFirestore.instance.collection("magasins").doc(sellerId).collection("produits").doc(productId).delete();
  }

  // Récupère toutes les commandes d'un client
  Future getPurchase(userType, userid) async {
    return FirebaseFirestore.instance.collection(userType).doc(userid).collection("commands").orderBy("horodatage", descending: true).get();
  }

  // Récupère les informations générales d'une commande
  Future getCommandDetails(docId, commandId) async {
    return FirebaseFirestore.instance.collection("commonData").doc(docId).collection("commands").doc(commandId).get();
  }

  Stream getSellerCommandDetails(sellerId, statut) {
    // var documentList;
    var commandsQuery = FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("commands")
        .where("statut", isEqualTo: statut)
        // .limit(3)
        // .orderBy("reference")
        .snapshots();
    // documentList.addAll(newDocumentList);
    return commandsQuery;
    // Chargement infini avec orderBy
  }

  Future getPurchaseDetails(docId, commandId) async {
    return FirebaseFirestore.instance.collection('commonData').doc(docId).collection("commands").doc(commandId).collection("products").get();
  }

  Stream getPurchaseResumeDetails(userType, userid, commandId) {
    return FirebaseFirestore.instance.collection(userType).doc(userid).collection("commands").doc(commandId).collection("products").snapshots();
  }

  Future<QuerySnapshot> getCartProducts(String? sellerID) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userid).collection("cart").doc(sellerID).collection('products').get();

    return querySnapshot;
  }

  Future checkCartEmpty() async {
    QuerySnapshot querySnapshot = await ProviderGetCart().returnData();

    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future checkIfProductsExists(String userID, sellerID, productID) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection('cart')
        .doc(sellerID)
        .collection('products')
        .doc(productID)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future checkCartProductEmpty(sellerID) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userid).collection("cart").doc(sellerID).collection('products').get();

    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future updateCommand(sellerId, clientId, commandId, newStatut) async {
    await FirebaseFirestore.instance.collection('users').doc(clientId).collection('commands').doc(commandId).update({"statut": newStatut});

    await FirebaseFirestore.instance.collection('magasins').doc(sellerId).collection('commands').doc(commandId).update({"statut": newStatut});
  }

  /* Fonction permettant l'ajout de magasin en favoris
   * Elle récupère l'id de l'utilisateur, l'id du commerçant et si la variable est true ou false
   * Avec ses infos elle ajoute dans la collection de l'utilisateur les informations du magasins et les supprime s'il n'aime plus
   */

  Future addFavoriteShop(String? userID, sellerID, bool addFavorite, String? geohash, double latitude, double longitude) async {
    if (addFavorite == true) {
      await FirebaseFirestore.instance.collection('users').doc(userID).collection("loved").doc(sellerID).set({
        'id': sellerID,
        'position': {'geohash': geohash, 'geopoint': GeoPoint(latitude, longitude)}
      });
    } else {
      await FirebaseFirestore.instance.collection('users').doc(userID).collection("loved").doc(sellerID).delete();
    }
  }

  Future checkFavoriteShopSeller(String? sellerID) async {
    final User user = await ProviderUserId().returnUser();
    final userID = user.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").doc(userID).collection("loved").where("id", isEqualTo: sellerID).get();
    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

/* Fonction Ajout d'un produit au panier
 * Cette fonction récupère l'id du produit et des infos le concernant, l'ID de l'user et celui du commerçant
 * La fonction vérfie sur le panier est vide, s'il est vide ou non
 * S'il est vide il ajoute un produit du même magasin sinon il proposera à l'utilisateur le vider au profit d'un autre commerçant
 */

  Future addCart(String? nomProduit, num? prixProduit, String imgProduit, int amount, String? idCommercant, String? idProduit) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    bool checkEmpty = await DatabaseMethods().checkCartEmpty();

    if (checkEmpty == true) {
      await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(idCommercant).set({
        "idCommercant": idCommercant,
      });
      await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(idCommercant).collection('products').doc(idProduit).set({
        "id": idProduit,
        "nomProduit": nomProduit,
        "prixProduit": prixProduit,
        "imgProduit": imgProduit,
        "amount": amount,
        "idCommercant": idCommercant,
      });
      return true;
    } else {
      var docId = await ProviderGetCart().returnData();
      QueryDocumentSnapshot doc = docId.docs[0];
      DocumentReference docRef = doc.reference;

      if (docRef.id != idCommercant) {
        return false;
      } else {
        await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(idCommercant).collection('products').doc(idProduit).set({
          "id": idProduit,
          "nomProduit": nomProduit,
          "prixProduit": prixProduit,
          "imgProduit": imgProduit,
          "amount": amount,
          "idCommercant": idCommercant,
        });
      }
      return true;
    }
  }

  Future addAdresses(
      String? buildingDetails, String? buildingName, String? familyName, String? adressTitle, double? longitude, double? latitude, String? address) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    String iD = const Uuid().v4();

    QuerySnapshot chosenAdress = await FirebaseFirestore.instance.collection("users").doc(userid).collection("Address").where("chosen", isEqualTo: true).get();

    if (chosenAdress.docs.isEmpty) {
      await FirebaseFirestore.instance.collection("users").doc(userid).update({"firstConnection": false});
      return await FirebaseFirestore.instance.collection('users').doc(userid).collection('Address').doc(iD).set({
        'addressName': adressTitle,
        'buildingDetails': buildingDetails,
        'buildingName': buildingName,
        'familyName': familyName,
        'latitude': latitude,
        'chosen': true,
        'longitude': longitude,
        'address': address,
        'idDoc': iD,
      });
    } else {
      await FirebaseFirestore.instance.collection("users").doc(userid).collection("Address").doc(chosenAdress.docs[0]["idDoc"]).update({"chosen": false});

      return await FirebaseFirestore.instance.collection('users').doc(userid).collection('Address').doc(iD).set({
        'addressName': adressTitle,
        'buildingDetails': buildingDetails,
        'buildingName': buildingName,
        'familyName': familyName,
        'latitude': latitude,
        'chosen': true,
        'longitude': longitude,
        'address': address,
        'idDoc': iD,
      });
    }
  }

  Future editAdresses(
    String buildingDetails,
    String buildingName,
    String familyName,
    String adressTitle,
    double? longitude,
    double? latitude,
    String? address,
    String? id,
  ) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance.collection('users').doc(userid).collection('Address').doc(id).update({
      'addressName': adressTitle,
      'buildingDetails': buildingDetails,
      'buildingName': buildingName,
      'familyName': familyName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    });
  }

  Future getChosenAddress(userID) async {
    return FirebaseFirestore.instance.collection("users").doc(userID).collection("Address").where("chosen", isEqualTo: true).get();
  }

  Future changeChosenAddress(userID, addressID, previousID) async {
    await FirebaseFirestore.instance.collection("users").doc(userID).collection("Address").doc(previousID).update({"chosen": false});

    return FirebaseFirestore.instance.collection("users").doc(userID).collection("Address").doc(addressID).update({"chosen": true});
  }

  Future addFirstAddress(userID, addressID) async {
    await FirebaseFirestore.instance.collection("users").doc(userID).update({"firstConnection": false});
    return FirebaseFirestore.instance.collection("users").doc(userID).collection("Address").doc(addressID).update({"chosen": true});
  }

  Future getUnreadMSGCount(String documentID, String myUsername) async {
    try {
      int unReadMSGCount = 0;
      QuerySnapshot userChatList = await FirebaseFirestore.instance.collection('chatrooms').doc(documentID).collection('chatlist').get();
      List<QueryDocumentSnapshot> chatListDocuments = userChatList.docs;
      for (QueryDocumentSnapshot snapshot in chatListDocuments) {
        unReadMSGCount = unReadMSGCount + snapshot['badgeCount'] as int;
      }
      return unReadMSGCount;
    } catch (e) {
      print(e);
    }
  }

  Future addItem(String? userID, sellerID, productID, int? amount) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('cart')
        .doc(sellerID)
        .collection('products')
        .doc(productID)
        .update({"amount": amount});
  }

  Future deleteCartProduct(String nomProduit, sellerID) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(sellerID).collection('products').doc(nomProduit).delete();
    bool checkEmpty = await DatabaseMethods().checkCartProductEmpty(sellerID);

    if (checkEmpty == true) {
      await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(sellerID).delete();
    }
  }

  Future deleteCart(String? sellerID) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    var querySnapshots = await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(sellerID).collection('products').get();
    for (var doc in querySnapshots.docs) {
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(sellerID).delete();
  }

  Future allCartMoney(String? userid, idCommercant) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .doc(idCommercant)
        .collection('products')
        //.where("prixProduit")
        .get();
  }

  Future acceptPayment(String? idCommercant, double deliveryChoose, num? amount, String? userAdress, String idCommand) async {
    int totalProduct = 0;
    String idProduit = "";
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;

    //RECUPERE LA REFERENCE DANS LE DOCUMENT DU MAGASIN
    var ref = await FirebaseFirestore.instance.collection('magasins').doc(idCommercant).get();

//RECUPERE LA QUANTITE D'ARTICLE DANS LE PANIER ET LE MET DANS UNE VARIABLE AFIN D'AVOIR UN NOMBRE TOTAL
    var produits = await FirebaseFirestore.instance.collection('users').doc(userid).collection('cart').doc(idCommercant).collection('products').get();

    for (var i in produits.docs) {
      totalProduct = totalProduct + i["amount"] as int;
      idProduit = i['id'];
    }

    // await FirebaseFirestore.instance.collection('comonData').doc().collection('commands').doc(idCommand).set({
    //   "shop": idCommercant,
    //   "buyer": userid,
    //   "article": totalProduct.toInt(),
    //   "date": DateTime.now(),
    // });

    //MET LES NOUVELLES INFORMATIONS DANS LA BDD DE L'UTILISATEUR
    await FirebaseFirestore.instance.collection('commonData').doc(idCommercant! + userid).collection("commands").doc(idCommand).set({
      "articles": totalProduct.toInt(),
      "horodatage": DateTime.now(),
      "id": idCommand,
      "livraison": deliveryChoose.toInt(),
      "prix": amount,
      "statut": 0.toInt(),
      "reference": ref["commandNb"].toInt(),
      "adresse": userAdress,
      "shopID": idCommercant,
      "userID": userid,
    });

    // //MET LES NOUVELLES INFORMATIONS DANS LA BDD DU COMMERCANT
    // await FirebaseFirestore.instance.collection('magasins').doc(idCommercant).collection("commands").doc(idCommand).set({
    //   "articles": totalProduct.toInt(),
    //   "horodatage": DateTime.now(),
    //   "id": idCommand,
    //   "livraison": deliveryChoose.toInt(),
    //   "prix": amount,
    //   "statut": 0.toInt(),
    //   "reference": ref["commandNb"].toInt(),
    //   "adresse": userAdress,
    //   "clientID": userid
    // });

    //UPDATE LA TABLE MAGASIN, INCREMENTE LE NOMBRE DE COMMANDES
    await FirebaseFirestore.instance.collection('magasins').doc(idCommercant).update({"commandNb": ref["commandNb"] + 1});

    // Entre l'id de chaque produit et sa quantité pour le client puis pour le commercant
    for (var i in produits.docs) {
      await FirebaseFirestore.instance.collection('users').doc(userid).collection("commands").doc(idCommand).collection("products").doc().set({
        "produit": i["id"],
        "quantite": i["amount"],
      });
    }

    for (var i in produits.docs) {
      await FirebaseFirestore.instance.collection('magasins').doc(idCommercant).collection("commands").doc(idCommand).collection("products").doc().set({
        "produit": i["id"],
        "quantite": i["amount"],
      });
    }

    DatabaseMethods().deleteCartProduct(idProduit, idCommercant);
    DatabaseMethods().deleteCart(idCommercant);
  }

  Future accountpremium() async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance.collection('magasins').doc(userid).update({"premium": true});
  }

  Future accountfree() async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance.collection('magasins').doc(userid).update({"premium": false});
  }

  Future colorMyStore(String myColorChoice, String myColorChoiceName) async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance.collection('magasins').doc(userid).update({"colorStore": myColorChoice, "colorStoreName": myColorChoiceName});
  }
}
