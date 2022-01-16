import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  String? idUtil;
  Utilisateur({this.idUtil});
}

class DonneesUtil {
  String? idUtil, nomUtil, emailUtil, photoUrl, lastImgPost;
  int? nbrePost;
  Timestamp? dateInscription;

  DonneesUtil(
      {this.idUtil,
      this.nomUtil,
      this.emailUtil,
      this.nbrePost,
      this.photoUrl,
      this.lastImgPost,
      this.dateInscription});
}
