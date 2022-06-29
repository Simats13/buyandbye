import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FBAuth {
  static FBAuth get instanace => FBAuth();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future addUserUsingEmail(
      BuildContext context, String emailAddress) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: "SuperSecretPassword!");
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
      } else if (e.code == 'email-already-in-use') {
      }
      showAlertDialog(context, e.code);
    } catch (e) {
      print(e);
    }
  }
}
