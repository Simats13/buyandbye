import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2 classes de démonstration avec un compteur
// Initialisation des variables et des fonctions du compteur
class TestProvider with ChangeNotifier, DiagnosticableTreeMixin {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// Renvoie la valeur du compteur
class Count extends StatelessWidget {
  const Count({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TestProvider>(context);
    return Text(
      provider.count.toString(),
      style: const TextStyle(fontSize: 20),
    );
  }
}

// Récupère l'identifiant de l'utiisateur connecté et le renvoie
class ProviderUserId with ChangeNotifier, DiagnosticableTreeMixin {
  final User? _user = FirebaseAuth.instance.currentUser;
  User? get userId => _user;

  returnData() {
    return _user?.uid;
  }

  returnUser() async {
    return _user;
  }
}

// Récupère les infos de l'utilisateur et les affiche
class ProviderUserInfo with ChangeNotifier, DiagnosticableTreeMixin {
  final Stream _userInfo = FirebaseFirestore.instance.collection('users').doc(ProviderUserId().returnData()).snapshots();
  Stream get userInfo => _userInfo;

  dynamic returnData() {
    return _userInfo;
  }
}

// Récupère les questions selon le type d'utilisateur et les affiche
class ProviderGetFAQ with ChangeNotifier, DiagnosticableTreeMixin {
  final Future _clientsFaq = FirebaseFirestore.instance.collection('FAQ').where('client', isEqualTo: true).get();
  Future get clientsFaq => _clientsFaq;

  final Future _professionalsFaq = FirebaseFirestore.instance.collection('FAQ').where('client', isEqualTo: false).get();
  Future get professionalsFaq => _professionalsFaq;

  dynamic returnData(bool type) {
    if (type) {
      return _clientsFaq;
    } else {
      return _professionalsFaq;
    }
  }
}

// Récupère les commandes de l'utilisateur et les affiche
class ProviderGetOrders with ChangeNotifier, DiagnosticableTreeMixin {
  final Future _orders = FirebaseFirestore.instance.collection('commonData').where('users', arrayContains: ProviderUserId().returnData()).get();
  Future get orders => _orders;

  Future returnData() {
    return _orders;
  }
}

// Récupère les adresses de l'utilisateur et les affiche
class ProviderGetAddresses with ChangeNotifier, DiagnosticableTreeMixin {
  final Stream _addresses = FirebaseFirestore.instance.collection('users').doc(ProviderUserId().returnData()).collection('Address').snapshots();
  Stream get addresses => _addresses;

  Stream returnData() {
    return _addresses;
  }

  // Chosen address
  final Stream _chosenAddress = FirebaseFirestore.instance.collection("users").doc(ProviderUserId().returnData()).collection("Address").where("chosen", isEqualTo: true).snapshots();
  Stream get chosenAddress => _chosenAddress;

  Stream returnChosenAddress() {
    return _chosenAddress;
  }
} // ProviderGetAddresses().returnChosenAddress()

class ProviderGetCart with ChangeNotifier, DiagnosticableTreeMixin {
  final Future _cart = FirebaseFirestore.instance.collection('users').doc(ProviderUserId().returnData()).collection('cart').get();
  Future get cart => _cart;

  Future returnData() {
    return _cart;
  }
}

class GetShops with ChangeNotifier, DiagnosticableTreeMixin {
  // All shops
  final CollectionReference _shops = FirebaseFirestore.instance.collection('magasins');
  CollectionReference get shops => _shops;

  CollectionReference returnData() {
    return _shops;
  }

  // Sponsored shops
  final Query<Map<String, dynamic>> _sponsoredShops = FirebaseFirestore.instance.collection('magasins').where("sponsored", isEqualTo: true);
  Query<Map<String, dynamic>> get sponsoredShops => _sponsoredShops;

  Query<Map<String, dynamic>> returnDataSponsored() {
    return _sponsoredShops;
  }

  // Sponsored shops
  final Query _lovedShops = FirebaseFirestore.instance.collection('users').doc(ProviderUserId().returnData()).collection('loved');
  Query get lovedShops => _lovedShops;

  Query returnDataLoved() {
    return _lovedShops;
  }
}