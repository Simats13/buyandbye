import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Récupère l'identifiant du commerçant connecté et le renvoie
class ProviderSellerId with ChangeNotifier, DiagnosticableTreeMixin {
  final User? _user = FirebaseAuth.instance.currentUser;
  User? get userId => _user;

  returnData() {
    return _user?.uid;
  }
}

// Récupère les infos du commerçant et les affiche
class ProviderSellerInfo with ChangeNotifier, DiagnosticableTreeMixin {
  final Stream _userInfo = FirebaseFirestore.instance.collection('magasins').doc(ProviderSellerId().returnData()).snapshots();
  Stream get userInfo => _userInfo;

  dynamic returnData() {
    return _userInfo;
  }
}