import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messasing;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = new GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);
    User userDetails = result.user;

    bool docExists = await DatabaseMethods().checkIfDocExists(userDetails.uid);
    print("doc exists");
    print(docExists);
    if (result == null) {
    } else {
      if (docExists == false) {
        // SharedPreferenceHelper().saveUserEmail(userDetails.email);
        // SharedPreferenceHelper().saveUserId(userDetails.uid);
        // SharedPreferenceHelper()
        //     .saveUserName(userDetails.email.replaceAll("@gmail.com", ""));
        // SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
        // SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);
        Map<String, dynamic> userInfoMap = {
          "id": userDetails.uid,
          "email": userDetails.email,
          "username": userDetails.email.replaceAll("@gmail.com", ""),
          "fname": userDetails.displayName.split(" ")[0],
          "lname": userDetails.displayName.split(" ")[1],
          "imgUrl": userDetails.photoURL,
          "admin": false,
          "FCMToken": await messasing.FirebaseMessaging.instance.getToken(
              vapidKey:
                  "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
          "phone": "01 02 03 04 05"
        };
        DatabaseMethods()
            .addUserInfoToDB(userDetails.uid, userInfoMap)
            .then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        });
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyApp()));
      }
    }
    isconnected = true;
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

  Future<void> signUpWithMail(String _email, String _password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password);
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    Map<String, dynamic> userInfoMap = {
      "id": user.uid,
      "email": _email,
      "username": _email,
      "name": _email,
      "imgUrl": "https://buyandbye.fr/avatar.png",
      "admin": false,
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
    print('Connexion réussi : $user');
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
      "username": _nomSeller,
      "livraison": false,
      "description": "description",
      "adresse": _adresseSeller,
      "imgUrl": "https://buyandbye.fr/avatar.png",
      "admin": true,
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
      "username": _nomSeller,
      "adresse": _adresseSeller,
      "imgUrl":
          "https://upload.wikimedia.org/wikipedia/commons/f/f4/User_Avatar_2.png",
      "admin": true,
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
