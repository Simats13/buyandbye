import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fb_firestore.dart';

class FBStorage {
  static FBStorage get instanace => FBStorage();

  // Save Image to Storage
  Future<List<String?>?> saveUserImageToFirebaseStorage(
      userEmail, userId, userName, userIntro, userImageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('userEmail', userEmail);
      await prefs.setString('userId', userId);
      await prefs.setString('name', userName);
      await prefs.setString('intro', userIntro);
      String filePath = 'userImages/$userId';

      try {
        await firebase_storage.FirebaseStorage.instance
            .ref(filePath)
            .putFile(userImageFile);
      } on firebase_core.FirebaseException catch (e) {
        print('upload image exception, code is ${e.code}');
        // e.g, e.code == 'canceled'
      }
      String imageURL = await firebase_storage.FirebaseStorage.instance
          .ref(filePath)
          .getDownloadURL();
      await prefs.setString('imageUrl', imageURL);
      List<String?>? result = await FBCloudStore.instanace
          .saveUserDataToFirebaseDatabase(
              userEmail, userId, userName, userIntro, imageURL);

      return result;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // ignore: missing_return
  Future sendImageToUserInChatRoom(croppedFile, chatID) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'chatrooms/$chatID/$imageTimeStamp';

      try {
        await firebase_storage.FirebaseStorage.instance
            .ref(filePath)
            .putFile(croppedFile);
      } on firebase_core.FirebaseException catch (e) {
        print('upload image exception, code is ${e.code}');
        // e.g, e.code == 'canceled'
      }

      return await firebase_storage.FirebaseStorage.instance
          .ref(filePath)
          .getDownloadURL();
    } catch (e) {
      print(e);
    }
  }

  // ignore: missing_return
  Future uploadProductPhotosToFb(
      croppedFile, sellerID, productID) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'products/$sellerID/$imageTimeStamp';
      String? url;

      try {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child(filePath);
        UploadTask uploadTask = ref.putFile(croppedFile);
        url = await (await uploadTask).ref.getDownloadURL();
      } on firebase_core.FirebaseException catch (e) {
        print('upload image exception, code is ${e.code}');
      }
      // Ajoute l'url de l'image upload aux données du produit
      addProductImage(sellerID, productID, url);
    } catch (e) {
      print(e);
    }
  }

  Future addProductImage(sellerId, productId, imageUrl) async {
    return await FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .update({
      "images": FieldValue.arrayUnion([imageUrl])
    });
  }

  Future deleteProductImage(sellerId, productId, imageUrl) async {
    return await FirebaseFirestore.instance
        .collection("magasins")
        .doc(sellerId)
        .collection("produits")
        .doc(productId)
        .update({
      "images": FieldValue.arrayRemove([imageUrl])
    });
  }
  
  Future deleteProductImageFromStorage(url) {
    return FirebaseStorage.instance.refFromURL(url).delete();
  }
}

