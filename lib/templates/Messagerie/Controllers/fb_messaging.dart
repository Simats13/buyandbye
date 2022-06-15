import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/templates/Messagerie/Model/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'fb_firestore.dart';

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationController get instance => NotificationController();

  Future takeFCMTokenWhenAppLaunch() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        saveUerTokenToSharedPreference();
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        saveUerTokenToSharedPreference();
      } else {
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Navigator.pushNamed(context, '/message',
        //     arguments: MessageArguments(message, true));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUerTokenToSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging
        .getToken(vapidKey: firebaseCloudvapidKey)
        .then((val) async {
      prefs.setString('FCMToken', val!);
    });
  }

  Future<void> updateTokenToServer() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging
        .getToken(vapidKey: firebaseCloudvapidKey)
        .then((val) async {
      prefs.setString('FCMToken', val!);
      String userID = userid;
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          FBCloudStore.instance.updateUserToken(userID, val);
        }
      });
    });
  }

  Future initLocalNotification() async {
    if (Platform.isIOS) {
      // set iOS Local notification.
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    } else {
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  Future _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {}

  Future _selectNotification(String? payload) async {}

  Future<void> sendNotificationMessageToPeerUser(
      unReadMSGCount,
      messageType,
      textFromTextField,
      myName,
      chatID,
      peerUserToken,
      imgUrl,
      otherToken,
      otherID) async {
    const yourServerKey =
        "AAAAqk7liPM:APA91bHZUrcSZWjOgia117HltJ1BWSJ9_M1NEojTB8QXIGQXH8sWTrjQdJH_oUQrsH2DxAssSwSe_3rphP74uD4BkPdHgwWDn7yWypSItzovjkkxIubamzkQ1gEFBC6eT45P5GFSCl9S";
    // FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    try {
      await http.post(
        // 'https://fcm.googleapis.com/fcm/send',
        // 'https://api.rnfirebase.io/messaging/send',
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$yourServerKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': messageType == 'text' ? '$textFromTextField' : '(Photo)',
              'title': '$myName',
              'badge': '$unReadMSGCount', //'$unReadMSGCount'
              "sound": "default",
            },
            // 'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'chatroomid': chatID,
              'userName': '$myName',
              'message':
                  messageType == 'text' ? '$textFromTextField' : '(Photo)',
              'profilePic': imgUrl,
              'otherToken': otherToken,
              'otherID': otherID
            },
            'to': peerUserToken,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
