import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oficihome/model/utilisateur.dart';
import 'package:oficihome/services/bdd.dart';

class ServiceAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Utilisateur _utilFromFirebaseUser(User utilisateur) {
    return utilisateur != null ? Utilisateur(idUtil:utilisateur.uid) : null;
  }

  Stream<Utilisateur> get utilisateur {
    return _auth.authStateChanges().map(_utilFromFirebaseUser);
  }
  //Connexion avec Google

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      await ServiceBDD(idUtil: user.uid).saveUserData(user.displayName, user.email, user.photoURL);
    } catch (error) {
      print(error);
    }
  }

  //DECONNEXION

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      return null;
    }
  }
}
