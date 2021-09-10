import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messasing;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:buyandbye/main.dart';
import 'package:buyandbye/services/database.dart';
import 'package:location/location.dart';

class AuthMethods {
  bool isconnected = false;

  static AuthMethods get instanace => AuthMethods();
  static Function toogleNavBar;

  final FirebaseAuth auth = FirebaseAuth.instance;

  //get current user
  getCurrentUser() async {
    return auth.currentUser;
  }

  Future<String> signInwithGoogle(BuildContext context) async {
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

      if (userCredential == null) {
      } else {
        if (docExists == false) {
          Map<String, dynamic> userInfoMap = {
            "id": userDetails.uid,
            "email": userDetails.email,
            "fname": userDetails.displayName.split(" ")[0],
            "lname": userDetails.displayName.split(" ")[1],
            "imgUrl": userDetails.photoURL,
            "providers": {
              'Google': true, //GOOGLE
              'Facebook': false, //FACEBOOK
              'Apple': false, //APPLE
              'Mail': false, // MAIL
            },
            "admin": false,
            "emailVerified": true,
            "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
                vapidKey:
                    "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
            "phone": ""
          };
          DatabaseMethods().addInfoToDB("users", userDetails.uid, userInfoMap);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        } else {
          //Verifie si l'adresse mail a été vérifiée
          bool checkEmail =
              await AuthMethods.instanace.checkEmailVerification();

          if (checkEmail) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(userDetails.uid)
                .update({
              "providers.Google": true, //Facebook
            });

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyApp()));
          }
        }
      }

      return userCredential.user.displayName;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

//Connexion via Facebook
  Future signInWithFacebook(
    BuildContext context,
  ) async {
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
                "providers": {
                  'Google': false, //GOOGLE
                  'Facebook': true, //FACEBOOK
                  'Apple': false, //APPLE
                  'Mail': false, // MAIL
                },
                "admin": false,
                "emailVerified": false,
                "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
                    vapidKey:
                        "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
                "phone": ""
              };
              DatabaseMethods()
                  .addInfoToDB("users", userDetails.uid, userInfoMap);

              //Envoie un mail de confirmation d'adresse mail
              sendEmailVerification();
            } else {
              //Verifie si l'adresse mail a été vérifiée
              bool checkEmail =
                  await AuthMethods.instanace.checkEmailVerification();

              if (checkEmail) {
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(userDetails.uid)
                    .update({
                  "providers.Facebook": true, //Facebook
                });
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

  Future<User> signInWithApple({
    List<apple.Scope> scopes = const [],
    BuildContext context,
  }) async {
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
        final userDetails = authResult.user;

        bool docExists =
            await DatabaseMethods().checkIfDocExists(userDetails.uid);

        if (resulte == null) {
        } else {
          if (docExists == false) {
            Map<String, dynamic> userInfoMap = {
              "id": userDetails.uid,
              "email": userDetails.email,
              "fname": userDetails.displayName,
              "lname": userDetails.displayName,
              "imgUrl": userDetails.photoURL,
              "providers": {
                'Google': false, //GOOGLE
                'Facebook': false, //FACEBOOK
                'Apple': true, //APPLE
                'Mail': false, // MAIL
              },
              "admin": false,
              "emailVerified": false,
              "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
                  vapidKey:
                      "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
              "phone": ""
            };
            DatabaseMethods()
                .addInfoToDB("users", userDetails.uid, userInfoMap);

            //Envoie un mail de confirmation d'adresse mail
            sendEmailVerification();
          } else {
            //Verifie si l'adresse mail a été vérifiée
            bool checkEmail =
                await AuthMethods.instanace.checkEmailVerification();

            if (checkEmail) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userDetails.uid)
                  .update({
                "providers.Apple": true, //Facebook
              });
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            }
          }
        }

        if (scopes.contains(apple.Scope.fullName)) {
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await userDetails.updateDisplayName(displayName);
        }

        return userDetails;

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

//Envoie un email à l'adresse email enregistrée
  Future<void> sendEmailVerification() async {
    final User user = await AuthMethods().getCurrentUser();
    user.sendEmailVerification();
  }

//Vérifie si l'adresse email a été vérifié, si oui alors il modifie dans la base de donnée le champe emailVerified en true,
//Sinon il renvoie false
  Future checkEmailVerification() async {
    User user = await AuthMethods().getCurrentUser();

    if (user.emailVerified) {
      FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "emailVerified": true,
      });
      return true;
    } else {
      return false;
    }
  }

//Lie un compte identifé avec facebook avec un compte google
  Future linkExistingToGoogle() async {
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

    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Google": true, //Facebook
    });

    return linkauthresult.user.displayName;
  }

  Future linkExistingToFacebook() async {
    // //get currently logged in user
    final User existingUser = await AuthMethods().getCurrentUser();
    final LoginResult result = await FacebookAuth.instance.login();

    final AuthCredential facebookCredential =
        FacebookAuthProvider.credential(result.accessToken.token);

    //now link these credentials with the existing user
    UserCredential linkauthresult =
        await existingUser.linkWithCredential(facebookCredential);

    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Facebook": true, //Facebook
    });

    return linkauthresult.user.displayName;
  }

  Future linkExistingToApple({
    List<apple.Scope> scopes = const [],
  }) async {
    // //get currently logged in user
    final User existingUser = await AuthMethods().getCurrentUser();

    final resulte = await apple.AppleSignIn.performRequests(
        [apple.AppleIdRequest(requestedScopes: scopes)]);

    final appleIdCredential = resulte.credential;
    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: String.fromCharCodes(appleIdCredential.identityToken),
      accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
    );

    //now link these credentials with the existing user
    UserCredential linkauthresult =
        await existingUser.linkWithCredential(credential);

    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Apple": true, //Facebook
    });

    return linkauthresult.user.displayName;
  }

  Future unlinkGoogle() async {
    final User existingUser = await AuthMethods().getCurrentUser();

    User linkauthresult = await existingUser.unlink("google.com");
    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Google": false, //Facebook
    });
    return linkauthresult.displayName;
  }

  Future unlinkApple() async {
    final User existingUser = await AuthMethods().getCurrentUser();

    User linkauthresult = await existingUser.unlink("apple.com");
    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Apple": false, //Facebook
    });
    return linkauthresult.displayName;
  }

  Future unlinkFacebook() async {
    final User existingUser = await AuthMethods().getCurrentUser();
    User linkauthresult = await existingUser.unlink("facebook.com");
    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Facebook": false, //Facebook
    });

    return linkauthresult.displayName;
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
    DatabaseMethods().addInfoToDB("users", userid, userInfoMap);
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
      "phone": "",
      'FCMToken': await messasing.FirebaseMessaging.instance.getToken(
          vapidKey:
              "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
    };
    DatabaseMethods().addInfoToDB("users", userid, userInfoMap);

    Map<String, dynamic> userInfoMap2 = {
      "id": userid,
      "email": _email,
      "name": _nomSeller,
      "adresse": _adresseSeller,
      "emailVerified": false,
      "imgUrl":
          "https://upload.wikimedia.org/wikipedia/commons/f/f4/User_Avatar_2.png",
      "admin": true,
      "phone": "",
    };
    DatabaseMethods().addInfoToDB("magasins", userid, userInfoMap2);
    sendEmailVerification();
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
