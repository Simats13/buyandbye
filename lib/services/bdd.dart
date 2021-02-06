import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oficihome/model/utilisateur.dart';

class ServiceBDD {
  String idUtil;
  ServiceBDD({this.idUtil});
  final CollectionReference collectionUtilisateurs = FirebaseFirestore.instance.collection('utilisateurs');

  //METHODE POUR ENREGISTRER UN UTILISATEUR
  Future saveUserData(nomUtil, emailUtil, photoUrl) async {
    return await collectionUtilisateurs.doc('idUtil').set({
      'idUtil': idUtil,
      'nomUtil': nomUtil,
      'email': emailUtil,
      'photoUrl': photoUrl,
      'nbrePost': 0,
      'lastImgPost': '',
      'dateInscription': FieldValue.serverTimestamp()
    });
  }

  DonneesUtil _donneesUtilFromSnapshot(DocumentSnapshot snapshot) {
    return DonneesUtil(
        idUtil:snapshot.data()['idUtil'],
        nomUtil:snapshot.data()['nomUtil'],
        emailUtil:snapshot.data()['emailUtil'],
        photoUrl:snapshot.data()['photoUrl'],
        nbrePost:snapshot.data()['nbrePost'],
        lastImgPost:snapshot.data()['lastImgPost'], 
        dateInscription:snapshot.data()['dateInscription'],
    );
  }

  Stream<DonneesUtil> get donneesUtil {
    return collectionUtilisateurs
        .doc(idUtil)
        .snapshots()
        .map(_donneesUtilFromSnapshot);
  }
}
