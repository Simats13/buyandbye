import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messasing;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:buyandbye/main.dart';
import 'package:buyandbye/services/database.dart';

class AuthMethods {
  bool isconnected = false;

  static AuthMethods get instanace => AuthMethods();
  static Function toogleNavBar;

  final FirebaseAuth auth = FirebaseAuth.instance;

  //get current user
  getCurrentUser() async {
    return auth.currentUser;
  }

  Future<String> signInwithGoogle(BuildContext context,
      [bool link = false, AuthCredential authCredential]) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User userDetails = userCredential.user;

      bool docExists =
          await DatabaseMethods().checkIfDocExists(userDetails.uid);

      if (link == false) {
        if (userCredential == null) {
        } else {
          if (docExists == false) {
            Map<String, dynamic> userInfoMap = {
              "id": userDetails.uid,
              "email": userDetails.email,
              "fname": userDetails.displayName.split(" ")[0],
              "lname": userDetails.displayName.split(" ")[1],
              "imgUrl": userDetails.photoURL,
              "providers": [
                {'google': true}, //GOOGLE
                {'facebook': false}, //FACEBOOK
                {'apple': false}, //APPLE
                {'mail': false}, // MAIL
              ],
              "admin": false,
              "emailVerified": true,
              "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
                  vapidKey:
                      "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
              "phone": ""
            };
            DatabaseMethods()
                .addUserInfoToDB(userDetails.uid, userInfoMap)
                .then((value) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            });
          } else {
            //Verifie si l'adresse mail a été vérifiée
            bool checkEmail =
                await AuthMethods.instanace.checkEmailVerification();

            if (checkEmail) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userDetails.uid)
                  .update({
                "providers": [
                  {'google': true}, //GOOGLE
                ],
              });

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            }
          }
        }
      }

      return userCredential.user.displayName;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

//Lie un compte identifé avec facebook avec un compte google
  Future linkFbToGoogle() async {
    // //get currently logged in user
    final User existingUser = await AuthMethods().getCurrentUser();

    //get the credentials of the new linking account
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential gcredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //now link these credentials with the existing user
    UserCredential linkauthresult =
        await existingUser.linkWithCredential(gcredential);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers": [
        {
          'google': true,
          'facebook': true,
          'apple': false,
          'email': false
        }, //Facebook
      ],
    });

    return linkauthresult.user.displayName;
  }

//Envoie un email à l'adresse email enregistrée
  Future<void> sendEmailVerification() async {
    final User user = await AuthMethods().getCurrentUser();
    user.sendEmailVerification();
  }

//Vérifie si l'adresse email a été vérifié, si oui alors il modifie dans la base de donnée le champe emailVerified en true,
//Sinon il renvoie false
  Future checkEmailVerification() async {
    User user = await AuthMethods().getCurrentUser();
    await user.reload();

    if (user.emailVerified) {
      FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "emailVerified": true,
      });
      return true;
    } else {
      return false;
    }
  }

//Connexion via Facebook
  Future signInWithFacebook(BuildContext context,
      [bool link = false, AuthCredential authCredential]) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      switch (result.status) {
        case LoginStatus.success:
          final AuthCredential facebookCredential =
              FacebookAuthProvider.credential(result.accessToken.token);
          final userCredential =
              await auth.signInWithCredential(facebookCredential);

          User userDetails = userCredential.user;

          bool docExists =
              await DatabaseMethods().checkIfDocExists(userDetails.uid);

          if (result == null) {
          } else {
            if (docExists == false) {
              Map<String, dynamic> userInfoMap = {
                "id": userDetails.uid,
                "email": userDetails.email,
                "fname": userDetails.displayName.split(" ")[0],
                "lname": userDetails.displayName.split(" ")[1],
                "imgUrl": userDetails.photoURL,
                "providers": [
                  {
                    'google': false,
                    'facebook': true,
                    'apple': false,
                    'email': false
                  }, //Facebook
                ],
                "admin": false,
                "emailVerified": false,
                "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
                    vapidKey:
                        "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
                "phone": ""
              };
              DatabaseMethods().addUserInfoToDB(userDetails.uid, userInfoMap);

              //Envoie un mail de confirmation d'adresse mail
              sendEmailVerification();
            } else {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userDetails.uid)
                  .update({
                "providers": [
                  {'facebook': true}, //Facebook
                ],
              });
              //Verifie si l'adresse mail a été vérifiée
              bool checkEmail =
                  await AuthMethods.instanace.checkEmailVerification();

              if (checkEmail) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              }
            }
          }

          return userCredential.user.displayName;

        case LoginStatus.cancelled:

        case LoginStatus.failed:

        default:
          return null;
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<User> signInWithApple({List<apple.Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final resulte = await apple.AppleSignIn.performRequests(
        [apple.AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (resulte.status) {
      case apple.AuthorizationStatus.authorized:
        final appleIdCredential = resulte.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await auth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        if (scopes.contains(apple.Scope.fullName)) {
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(displayName: displayName);
        }

        return firebaseUser;

      case apple.AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: resulte.error.toString(),
        );

      case apple.AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<void> signUpWithMail(
      String _email, String _password, String _fname, String _lname) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password);
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    Map<String, dynamic> userInfoMap = {
      "id": user.uid,
      "email": _email,
      "fname": _fname,
      "lname": _lname,
      "imgUrl": "https://buyandbye.fr/avatar.png",
      "admin": false,
      "phone": "",
      'FCMToken': await messasing.FirebaseMessaging.instance.getToken(
          vapidKey:
              "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
    };
    DatabaseMethods().addUserInfoToDB(userid, userInfoMap).then((value) {});
    user.updateProfile(
        displayName: _email, photoURL: "https://buyandbye.fr/avatar.png");
  }

  Future<User> signInWithMail(String _email, String _password) async {
    final User user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password))
        .user;
    assert(user != null);
    assert(await user.getIdToken() != null);
    print(user.displayName);
    print('Connexion réussie : $user');
    return user;
  }

  Future<void> signUpWithMailSeller(String _email, String _password,
      String _nomSeller, String _adresseSeller) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password);
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    Map<String, dynamic> userInfoMap = {
      "ClickAndCollect": true,
      "email": _email,
      "name": _nomSeller,
      "livraison": false,
      "description": "description",
      "adresse": _adresseSeller,
      "imgUrl": "https://buyandbye.fr/avatar.png",
      "admin": true,
      "phone": "01 02 03 04 05",
      'FCMToken': await messasing.FirebaseMessaging.instance.getToken(
          vapidKey:
              "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
    };
    DatabaseMethods().addSellerInfoToDB(userid, userInfoMap).then((value) {});
    user.updateProfile(
        displayName: _nomSeller, photoURL: "https://buyandbye.fr/avatar.png");

    Map<String, dynamic> userInfoMap2 = {
      "id": userid,
      "email": _email,
      "name": _nomSeller,
      "adresse": _adresseSeller,
      "imgUrl":
          "https://upload.wikimedia.org/wikipedia/commons/f/f4/User_Avatar_2.png",
      "admin": true,
      "phone": "",
      'FCMToken': await messasing.FirebaseMessaging.instance.getToken(
          vapidKey:
              "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
    };
    DatabaseMethods().addSellerInfoToDB2(userid, userInfoMap2).then((value) {});
  }

  Future<User> signInWithMailSeller(String _email, String _password) async {
    final User user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password))
        .user;
    assert(user != null);
    assert(await user.getIdToken() != null);
    print('Connexion réussi : $user');
    return user;
  }

  Future signOut() async {
    await auth.signOut();
  }

  Future<void> updateUserToken(userID, token) async {
    await FirebaseFirestore.instance.collection('users').doc(userID).update({
      'FCMToken': token,
    });
  }
}
