import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oficihome/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static NotificationController get instance => NotificationController();

  Future takeFCMTokenWhenAppLaunch() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.get('FCMToken');
    if (userToken == null) {
      FirebaseMessaging.instance.getToken().then((val) async {
        print('Token: ' + val);
        prefs.setString('FCMToken', val);
        final User user = auth.currentUser;
        final uid = user.uid;
        print('UserID :' + uid);
        if (uid != null) {
          AuthMethods.instanace.updateUserToken(uid, val);
        }
      });
    }
  }

  sendLocalNotification(name, msg) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(0, name, msg, platformChannelSpecifics, payload: 'item x');
  }

  Future<void> sendNotificationMessage(messageType, myName, tokenUser) async {
    const yourServerKey =
        "AAAAqk7liPM:APA91bHZUrcSZWjOgia117HltJ1BWSJ9_M1NEojTB8QXIGQXH8sWTrjQdJH_oUQrsH2DxAssSwSe_3rphP74uD4BkPdHgwWDn7yWypSItzovjkkxIubamzkQ1gEFBC6eT45P5GFSCl9S";

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$yourServerKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$messageType',
            'title': 'Nouveau message de $myName',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          // FCM Token lists.
          'to': '$tokenUser',
        },
      ),
    );
  }
}
