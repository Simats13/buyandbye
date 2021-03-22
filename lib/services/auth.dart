import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as messasing;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oficihome/helperfun/sharedpref_helper.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/templates/accueil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (result == null) {
    } else {
      SharedPreferenceHelper().saveUserEmail(userDetails.email);
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      SharedPreferenceHelper()
          .saveUserName(userDetails.email.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
      SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);

      // DatabaseMethods()
      //     .addUserInfoToDB(
      //         userID: userDetails.uid,
      //         email: userDetails.email,
      //         username: userDetails.email.replaceAll("@gmail.com", ""),
      //         name: userDetails.displayName,
      //         profileUrl: userDetails.photoURL)
      //     .then(() {
      //   Navigator.pushReplacement(
      //       context, MaterialPageRoute(builder: (context) => HomePage()));
      // });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
        'FCMToken': await messasing.FirebaseMessaging.instance.getToken(
            vapidKey:
                "BJv98CAwXNrZiF2xvM4GR8vpR9NvaglLX6R1IhgSvfuqU4gzLAIpCqNfBySvoEwTk6hsM2Yz6cWGl5hNVAB4cUA"),
      };
      DatabaseMethods()
          .addUserInfoToDB(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Accueil()));
      });
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

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    final User user = auth.currentUser;
    final uid = user.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'FCMToken': 'NoToken',
    });
    await auth.signOut();
  }

  Future<void> updateUserToken(userID, token) async {
    await FirebaseFirestore.instance.collection('users').doc(userID).set({
      'FCMToken': token,
    });
  }

  Future getMagasin() async {
    List magasinList = [];

    try {
      await FirebaseFirestore.instance
          .collection('magasins')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          magasinList.add(element.data());
        });
      });
      return magasinList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
