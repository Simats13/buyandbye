// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messasing;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:buyandbye/main.dart';
import 'package:buyandbye/services/database.dart';
import 'package:crypto/crypto.dart';

class AuthMethods {
  bool isconnected = false;
  Map<String, dynamic>? paymentIntentData;

  static AuthMethods get instance => AuthMethods();
  static late Function toogleNavBar;

  final FirebaseAuth auth = FirebaseAuth.instance;

  //get current user
  getCurrentUser() async {
    return auth.currentUser;
  }

  Future loginGoogle({Function? success, ValueChanged<String>? fail}) async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final result = await auth.signInWithCredential(credential);

      if (!result.user!.emailVerified) {
        print('Login Cancelled');
      } else if (result.additionalUserInfo!.isNewUser) {
        // CRAETE USER
        print('SUCCESSFULYY CREATED USER');
      } else {
        print('ALL READY EXISTS THE USER');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Connexion via Google
  Future signInwithGoogle(
      {Function? success, ValueChanged<String>? fail}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential userCredential =
          await auth.signInWithCredential(authCredential);
      User? userDetails = userCredential.user;

      bool docExists =
          await DatabaseMethods().checkIfDocExists(userDetails!.uid);

      if (!userCredential.user!.emailVerified) {
        print('Login Cancelled');
        return false;
      } else if (userCredential.additionalUserInfo!.isNewUser) {
        if (docExists == false) {
          const url = "https://api.stripe.com/v1/customers";

          var secret =
              'sk_test_51Ida2rD6J4doB8CzdZn86VYvrau3UlTVmHIpp8rJlhRWMK34rehGQOxcrzIHwXfpSiHbCrZpzP8nNFLh2gybmb5S00RkMpngY8';

          Map<String, String> headers = {
            'Authorization': 'Bearer $secret',
            'Content-Type': 'application/x-www-form-urlencoded'
          };
          var response = await http.post(Uri.parse(url), headers: headers);
          paymentIntentData = json.decode(response.body);
          Map<String, dynamic> userInfoMap = {
            "id": userDetails.uid,
            "email": userDetails.email,
            "fname": userDetails.displayName!.split(" ")[0],
            "lname": userDetails.displayName!.split(" ")[1],
            "imgUrl": userDetails.photoURL,
            "customerId": paymentIntentData!["id"],
            "firstConnection": true,
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

          updateStripeInfo(paymentIntentData!["id"], userDetails.email,
              userDetails.displayName);
          print('Login ');
          return true;
        }
      } else {
        //Verifie si l'adresse mail a été vérifiée
        bool checkEmail = await AuthMethods.instance.checkEmailVerification();
        print("checkEmail : " + checkEmail.toString());

        if (checkEmail) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(userDetails.uid)
              .update(
            {
              "providers.Google": true, //Facebook
            },
          );
        }
        return true;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateStripeInfo(String? customerID, email, name) async {
    final url = "https://api.stripe.com/v1/customers/$customerID";

    var secret =
        'sk_test_51Ida2rD6J4doB8CzdZn86VYvrau3UlTVmHIpp8rJlhRWMK34rehGQOxcrzIHwXfpSiHbCrZpzP8nNFLh2gybmb5S00RkMpngY8';

    Map<String, String> headers = {
      'Authorization': 'Bearer $secret',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    Map body = {"email": email, "name": name};
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    paymentIntentData = json.decode(response.body);
  }

  // Connexion via Facebook
  Future signInWithFacebook({Function? success, ValueChanged<String>? fail}) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      switch (result.status) {
        case LoginStatus.success:
          final AuthCredential facebookCredential =
              FacebookAuthProvider.credential(result.accessToken!.token);
          final userCredential =
              await auth.signInWithCredential(facebookCredential);

          User userDetails = userCredential.user!;

          bool docExists = await (DatabaseMethods()
              .checkIfDocExists(userDetails.uid) as FutureOr<bool>);

          if (docExists == false) {
            const url = "https://api.stripe.com/v1/customers";

            var secret =
                'sk_test_51Ida2rD6J4doB8CzdZn86VYvrau3UlTVmHIpp8rJlhRWMK34frehGQOxcrzIHwXfpSiHbCrZpzP8nNFLh2gybmb5S00RkMpngY8';

            Map<String, String> headers = {
              'Authorization': 'Bearer $secret',
              'Content-Type': 'application/x-www-form-urlencoded'
            };
            var response = await http.post(Uri.parse(url), headers: headers);
            paymentIntentData = json.decode(response.body);
            Map<String, dynamic> userInfoMap = {
              "id": userDetails.uid,
              "email": userDetails.email,
              "fname": userDetails.displayName!.split(" ")[0],
              "lname": userDetails.displayName!.split(" ")[1],
              "imgUrl": userDetails.photoURL,
              "customerId": paymentIntentData!["id"],
              "firstConnection": true,
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
            updateStripeInfo(paymentIntentData!["id"], userDetails.email,
                userDetails.displayName);
            //Envoie un mail de confirmation d'adresse mail
            sendEmailVerification();
          } else {
            //Verifie si l'adresse mail a été vérifiée
            bool checkEmail = await (AuthMethods.instance
                .checkEmailVerification() as FutureOr<bool>);

            if (checkEmail) {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userDetails.uid)
                  .update({
                "providers.Facebook": true, //Facebook
              });
            }
            return true;
          }

          return userCredential.user!.displayName;

        case LoginStatus.cancelled:

        case LoginStatus.failed:

        default:
          return null;
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Génère un nonce sécurié cryptographiquement et inclus dans la requête d'authentification
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Connexion via Apple
  // ignore: missing_return
  Future signInWithApple(context) async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      print(appleCredential.authorizationCode);

      // Create an OAuthCredential from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase
      final authResult = await auth.signInWithCredential(oauthCredential);

      final displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      final userEmail = '${appleCredential.email}';

      final firebaseUser = authResult.user!;
      print(displayName);
      await firebaseUser.updateDisplayName(displayName);
      await firebaseUser.updateEmail(userEmail);

      bool docExists = await (DatabaseMethods()
          .checkIfDocExists(firebaseUser.uid) as FutureOr<bool>);

      if (docExists == false) {
        Map<String, dynamic> userInfoMap = {
          "id": firebaseUser.uid,
          "email": firebaseUser.email,
          "fname": firebaseUser.displayName,
          "lname": firebaseUser.displayName,
          "imgUrl": firebaseUser.photoURL,
          "customerId": paymentIntentData!["id"],
          "firstConnection": true,
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
        DatabaseMethods().addInfoToDB("users", firebaseUser.uid, userInfoMap);
        updateStripeInfo(paymentIntentData!["id"], firebaseUser.email,
            firebaseUser.displayName);
        //Envoie un mail de confirmation d'adresse mail
        sendEmailVerification();
      } else {
        //Verifie si l'adresse mail a été vérifiée
        bool checkEmail = await (AuthMethods.instance.checkEmailVerification()
            as FutureOr<bool>);

        if (checkEmail) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(firebaseUser.uid)
              .update({
            "providers.Apple": true, //Facebook
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const MyApp()));
        }
      }

      return firebaseUser;
    } catch (e) {
      print(e);
    }
  }

  // Envoie un email à l'adresse email enregistrée
  Future<void> sendEmailVerification() async {
    final User user = await AuthMethods().getCurrentUser();
    user.sendEmailVerification();
  }

  // Vérifie si l'adresse email a été vérifié, si oui alors il modifie dans la base de donnée le champe emailVerified en true,
  // Sinon il renvoie false
  Future checkEmailVerification() async {
    User? user = await AuthMethods().getCurrentUser();
    if (user != null) {
      FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "emailVerified": true,
      });
    }
    return true;
  }

  // Lie un compte identifé avec Facebook avec un compte Google
  Future linkExistingToGoogle() async {
    // //get currently logged in user
    final User existingUser = await AuthMethods().getCurrentUser();

    //get the credentials of the new linking account
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleUser =
        await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
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

    return linkauthresult.user!.displayName;
  }

  Future linkExistingToFacebook() async {
    // //get currently logged in user
    final User existingUser = await AuthMethods().getCurrentUser();
    final LoginResult result = await FacebookAuth.instance.login();

    final AuthCredential facebookCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);

    //now link these credentials with the existing user
    UserCredential linkauthresult =
        await existingUser.linkWithCredential(facebookCredential);

    FirebaseFirestore.instance
        .collection("users")
        .doc(existingUser.uid)
        .update({
      "providers.Facebook": true, //Facebook
    });

    return linkauthresult.user!.displayName;
  }

  // TODO refaire la fonction Lier Apple
  /*Future linkExistingToApple({
    List<apple.Scope> scopes = const [],
  }) async {
    //get currently logged in user
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
  } */

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
      String _email, String _password, String? _fname, String? _lname) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password);
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;

    const url = "https://api.stripe.com/v1/customers";

    var secret =
        'sk_test_51Ida2rD6J4doB8CzdZn86VYvrau3UlTVmHIpp8rJlhRWMK34rehGQOxcrzIHwXfpSiHbCrZpzP8nNFLh2gybmb5S00RkMpngY8';

    Map<String, String> headers = {
      'Authorization': 'Bearer $secret',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var response = await http.post(Uri.parse(url), headers: headers);
    paymentIntentData = json.decode(response.body);
    Map<String, dynamic> userInfoMap = {
      "id": user.uid,
      "email": _email,
      "fname": _fname,
      "lname": _lname,
      "customerId": paymentIntentData!["id"],
      "firstConnection": true,
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
        .user!;
    print(user.displayName);
    print('Connexion réussie : $user');
    return user;
  }

  Future<void> signUpWithMailSeller(
      String _email, String _password, String? _fname, String? _lname) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password);
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    // Map<String, dynamic> userInfoMap = {
    //   "ClickAndCollect": true,
    //   "email": _email,
    //   "fname": _fname,
    //   "livraison": false,
    //   "description": "description",
    //   "adresse": _adresseSeller,
    //   "imgUrl": "https://buyandbye.fr/avatar.png",
    //   "admin": true,
    //   "phone": "",
    // 'FCMToken': await messasing.FirebaseMessaging.instance.getToken(
    //     vapidKey:
    //         "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
    // };
    // DatabaseMethods().addInfoToDB("users", userid, userInfoMap);

    Map<String, dynamic> userInfoMap2 = {
      "ClickAndCollect": false,
      "livraison": false,
      "id": userid,
      "email": _email,
      "fname": _fname,
      "lname": _lname,
      "adresse": "",
      "description": "",
      "phone": "",
      "admin": true,
      "emailVerified": false,
      "premium": false,
      "isProfileComplete": false,
      "isShopVisible": false,
      // Couleur par défaut
      "colorStore": "000000",
      "imgUrl": "https://buyandbye.fr/avatar.png",
      "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
          vapidKey:
              "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
    };
    DatabaseMethods().addInfoToDB("magasins", userid, userInfoMap2);
    sendEmailVerification();
  }

  Future<User> signInWithMailSeller(String _email, String _password) async {
    final User user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password))
        .user!;
    print('Connexion réussi : $user');
    return user;
  }

  Future signOut() async {
    await auth.signOut();
  }

  Future<void> updateUserToken(userID, token) async {
    bool docExists = await DatabaseMethods().checkIfDocExists(userID);
    if (docExists) {
      await FirebaseFirestore.instance.collection('users').doc(userID).update({
        'FCMToken': token,
      });
    } else {
      await FirebaseFirestore.instance.collection('magasins').doc(userID).update({
        'FCMToken': token,
      });
    }
  }
}
