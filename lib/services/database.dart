import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:uuid/uuid.dart';

class DatabaseMethods {
  static DatabaseMethods get instanace => DatabaseMethods();

  Future userAuthData(String userId) async {
    return FirebaseFirestore.instance.collection("users").doc(userId).get();
  }

  Future<QuerySnapshot> getMyInfo(String userid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: userid)
        .get();
  }

  Stream getMyInfo2(userId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .snapshots();
  }

  Future deleteUser(String userID) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .delete();
  }

  Future deleteAddress(String idDoc) async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("Address")
        .doc(idDoc)
        .delete();
  }

  Future checkIfDocExists(String docId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(docId)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future addInfoToDB(
      String collection, userid, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(userid)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: username)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getMessagesByName(String nameMagasin) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: nameMagasin)
        .snapshots();
  }

  Future addMessage(
      String chatRoomId, String messageId, Map messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId, Map lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  createChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      //chatroom already exists
      return true;
    } else {
      //chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUserName = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .where("users", arrayContains: myUserName)
        .snapshots();
  }

  Future updateUserInfo(userId, lname, fname, email, phone) async {
    return FirebaseFirestore.instance.collection("users").doc(userId).update(
        {"lname": lname, "fname": fname, "email": email, "phone": phone});
  }

  Future updateSellerInfo(userId, name, email, phone) async {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(userId)
        .update({"name": name, "email": email, "phone": phone});
  }

  Future<QuerySnapshot> getMagasinInfo(String sellerId) async {
    return await FirebaseFirestore.instance
        .collection("magasins")
        .where("id", isEqualTo: sellerId)
        .get();
  }

  Future<QuerySnapshot> getMagasinInfoViaID(String id) async {
    return await FirebaseFirestore.instance
        .collection("magasins")
        .where("id", isEqualTo: id)
        .get();
  }

  Stream getSellerInfo(userId) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(userId)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getInfoConv(String myID) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .where("username", arrayContains: myID)
        .snapshots();
  }

  Future<QuerySnapshot> getStoreInfo() async {
    return await FirebaseFirestore.instance.collection("magasins").get();
  }

  Future<QuerySnapshot> getFAQ(type) async {
    return await FirebaseFirestore.instance
        .collection("FAQ")
        .where("client", isEqualTo: type)
        .get();
  }

  Future getMagasin() async {
    List magasinList = [];

    try {
      await FirebaseFirestore.instance
          .collection('magasins')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          magasinList.add(element.data());
        });
      });
      return magasinList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getUsers() async {
    //List usersList = [];
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    try {
      await FirebaseFirestore.instance.collection("users").doc(userid).get();
    } catch (e) {}
  }

  Stream getProducts(String sellerId) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .snapshots();
  }

  // On ne récupère que les produits que le commerçant a choisi comme étant visible par les clients
  Stream getVisibleProducts(String sellerId, String categorie, int actualPage) {
    Stream query = FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .where("visible", isEqualTo: true)
        .where("categorie", isEqualTo: categorie)
        .limit(6)
        .snapshots();
    return query;
  }

  Stream getOneProduct(sellerId, productId) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .snapshots();
  }

  Future getOneProductFuture(sellerId, productId) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .get();
  }

  Future createProduct(sellerId, name, reference, description, price, quantity,
      id, categorie, visibility) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(id)
        .set({
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

  Future updateProduct(sellerId, productId, name, reference, description, price,
      quantity, category) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .update({
      'nom': name,
      'reference': reference,
      'description': description,
      'prix': price,
      'quantite': quantity,
      'categorie': category
    });
  }

  Future hideOrShowProduct(sellerId, productId, visibility) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .update({"visible": !visibility});
  }

  Future deleteProduct(sellerId, productId) {
    return FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .delete();
  }

  Future<Stream<QuerySnapshot>> searchBarGetStoreInfo(String name) async {
    return FirebaseFirestore.instance
        .collection("magasins")
        .where("name", isEqualTo: name)
        .snapshots();
  }

  // Récupère toutes les commandes d'un client
  Future getPurchase(userType, userid) async {
    return FirebaseFirestore.instance
        .collection(userType)
        .doc(userid)
        .collection("commands")
        .orderBy("horodatage", descending: true)
        .get();
  }

  // Récupère les informations générales d'une commande
  Future getCommandDetails(userid, documentId) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("commands")
        .doc(documentId)
        .get();
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

  Future getPurchaseDetails(userid, commandId) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("commands")
        .doc(commandId)
        .collection("products")
        .get();
  }

  Future<QuerySnapshot> getCart() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("cart")
        .get();
  }

  Future updateCommand(sellerId, clientId, commandId, newStatut) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(clientId)
        .collection('commands')
        .doc(commandId)
        .update({"statut": newStatut});

    await FirebaseFirestore.instance
        .collection('magasins')
        .doc(sellerId)
        .collection('commands')
        .doc(commandId)
        .update({"statut": newStatut});
  }

// Récupérer l'ID d'un document
// Possible d'utiliser cette valeur au lieu de la rentrer dans le document ?
  testDb() {
    DocumentReference ref = FirebaseFirestore.instance
        .collection("magasins")
        .doc("Fnac")
        .collection("categories")
        .doc("abcde12345");
    String myId = ref.id;
    print(myId);
  }

  Future addCart(String nomProduit, num prixProduit, String imgProduit,
      int amount, String idCommercant, String idProduit) async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .doc(idProduit)
        .set({
      "id": idProduit,
      "nomProduit": nomProduit,
      "prixProduit": prixProduit,
      "imgProduit": imgProduit,
      "amount": amount,
      "idCommercant": idCommercant,
    });
  }

  Future addAdresses(
      String buildingDetails,
      String buildingName,
      String familyName,
      String adressTitle,
      double longitude,
      double latitude,
      String address) async {
    final User user = await AuthMethods().getCurrentUser();
    String iD = Uuid().v4();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('Address')
        .doc(iD)
        .set({
      'addressName': adressTitle,
      'buildingDetails': buildingDetails,
      'buildingName': buildingName,
      'familyName': familyName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'idDoc': iD,
    });
  }

  Future editAdresses(
    String buildingDetails,
    String buildingName,
    String familyName,
    String adressTitle,
    double longitude,
    double latitude,
    String address,
    String id,
  ) async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('Address')
        .doc(id)
        .update({
      'addressName': adressTitle,
      'buildingDetails': buildingDetails,
      'buildingName': buildingName,
      'familyName': familyName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    });
  }

  Future<Stream<QuerySnapshot>> getAllAddress() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .collection("Address")
        .snapshots();
  }

  Future getUnreadMSGCount(String documentID, String myUsername) async {
    try {
      int unReadMSGCount = 0;
      QuerySnapshot userChatList = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(documentID)
          .collection('chatlist')
          .get();
      List<QueryDocumentSnapshot> chatListDocuments = userChatList.docs;
      for (QueryDocumentSnapshot snapshot in chatListDocuments) {
        unReadMSGCount = unReadMSGCount + snapshot['badgeCount'];
      }
      print('unread MSG count is $unReadMSGCount');
      return unReadMSGCount;
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> updateMyChatListValues(
      String documentID, String myUsername, bool isInRoom) async {
    var updateData =
        isInRoom ? {'inRoom': isInRoom, 'badgeCount': 0} : {'inRoom': isInRoom};
    final DocumentReference result = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(documentID)
        .collection('chatlist')
        .doc(myUsername);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(result);
      if (!snapshot.exists) {
        transaction.set(result, updateData);
      } else {
        transaction.update(result, updateData);
      }
    });

    int unReadMSGCount = await DatabaseMethods.instanace
        .getUnreadMSGCount(documentID, myUsername);
    FlutterAppBadger.updateBadgeCount(unReadMSGCount);
  }

  Future updateUserChatListField(String documentID, selectedUserID) async {
    var userBadgeCount = 0;
    var isRoom = false;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(documentID)
        .collection('chatlist')
        .doc(selectedUserID)
        .get();

    if (userDoc.data() != null) {
      isRoom = userDoc.get('inRoom') ?? false;
      if (userDoc != null && !userDoc['inRoom']) {
        userBadgeCount = userDoc['badgeCount'];
        userBadgeCount++;
      }
    } else {
      userBadgeCount++;
    }

    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(documentID)
        .collection('chatlist')
        .doc(selectedUserID)
        .set({
      'badgeCount': isRoom ? 0 : userBadgeCount,
      'inRoom': isRoom,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future addItem(String idProduit, int amount) async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .doc(idProduit)
        .update({"amount": amount});
  }

  Future deleteCart(String nomProduit) async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .doc(nomProduit)
        .delete();
  }

  Future moneyCart(num prixProduit) async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .where("prixProduit", isEqualTo: prixProduit)
        .get();
  }

  Future allCartMoney() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .where("prixProduit")
        .get();
  }

  Future acceptPayment(String idCommercant, double deliveryChoose,
      double amount, String userAdress, String idCommand) async {
    int totalProduct = 0;
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;

    //RECUPERE LA REFERENCE DANS LE DOCUMENT DU MAGASIN
    var ref = await FirebaseFirestore.instance
        .collection('magasins')
        .doc(idCommercant)
        .get();

//RECUPERE LA QUANTITE D'ARTICLE DANS LE PANIER ET LE MET DANS UNE VARIABLE AFIN D'AVOIR UN NOMBRE TOTAL
    var produits = await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .get();

    for (var i in produits.docs) {
      totalProduct = totalProduct + i["amount"];
    }

    //MET LES NOUVELLES INFORMATIONS DANS LA BDD DE L'UTILISATEUR
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection("commands")
        .doc(idCommand)
        .set({
      "articles": totalProduct.toInt(),
      "horodatage": DateTime.now(),
      "id": idCommand,
      "livraison": deliveryChoose.toInt(),
      "prix": amount,
      "statut": 0.toInt(),
      "reference": ref["commandNb"].toInt(),
      "adresse": userAdress,
      "shopID": idCommercant
    });

    //MET LES NOUVELLES INFORMATIONS DANS LA BDD DU COMMERCANT
    await FirebaseFirestore.instance
        .collection('magasins')
        .doc(idCommercant)
        .collection("commands")
        .doc(idCommand)
        .set({
      "articles": totalProduct.toInt(),
      "horodatage": DateTime.now(),
      "id": idCommand,
      "livraison": deliveryChoose.toInt(),
      "prix": amount,
      "statut": 0.toInt(),
      "reference": ref["commandNb"].toInt(),
      "adresse": userAdress,
      "clientID": userid
    });

    //UPDATE LA TABLE MAGASIN, INCREMENTE LE NOMBRE DE COMMANDES
    await FirebaseFirestore.instance
        .collection('magasins')
        .doc(idCommercant)
        .update({"commandNb": ref["commandNb"] + 1});

    // Entre l'id de chaque produit et sa quantité pour le client puis pour le commercant
    for (var i in produits.docs) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .collection("commands")
          .doc(idCommand)
          .collection("products")
          .doc()
          .set({
        "produit": i["id"],
        "quantite": i["amount"],
      });
    }

    for (var i in produits.docs) {
      await FirebaseFirestore.instance
          .collection('magasins')
          .doc(idCommercant)
          .collection("commands")
          .doc(idCommand)
          .collection("products")
          .doc()
          .set({
        "produit": i["id"],
        "quantite": i["amount"],
      });
    }

    var snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('cart')
        .get();
    for (var i in snapshots.docs) {
      await i.reference.delete();
    }
  }
}
