import 'package:buyandbye/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FBCloudStore {
  static FBCloudStore get instance => FBCloudStore();
  // About Firebase Database
  Future<List<String?>?> saveUserDataToFirebaseDatabase(
      userEmail, userId, userName, userIntro, downloadUrl) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: prefs.get('userId'))
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      String? myID = userId;
      if (documents.length == 0) {
        await prefs.setString('userId', userId);
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': userEmail,
          'name': userName,
          'intro': userIntro,
          'userImageUrl': downloadUrl,
          'userId': userId,
          'createdAt': DateTime.now(),
          'FCMToken': prefs.get('FCMToken') ?? 'NOToken',
        });
      } else {
        myID = documents[0]['userId'];
        await prefs.setString('userId', myID!);
        await FirebaseFirestore.instance.collection('users').doc(myID).update({
          'email': userEmail,
          'name': userName,
          'intro': userIntro,
          'userImageUrl': downloadUrl,
          'createdAt': DateTime.now(),
          'FCMToken': prefs.get('FCMToken') ?? 'NOToken',
        });
      }
      return [myID, downloadUrl];
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> updateMyChatListValues(
      bool isInRoom, String? documentID, chatID, userType) async {
    var updateData =
        isInRoom ? {'inRoom': isInRoom, 'badgeCount': 0} : {'inRoom': isInRoom};
    final DocumentReference result = FirebaseFirestore.instance
        .collection(userType)
        .doc(documentID)
        .collection('chatlist')
        .doc(chatID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(result);
      if (!snapshot.exists) {
        transaction.set(result, updateData);
      } else {
        transaction.update(result, updateData);
      }
    });
    int unReadMSGCount =
        await FBCloudStore.instance.getUnreadMSGCount(documentID);
    FlutterAppBadger.updateBadgeCount(unReadMSGCount);
  }

  Future<void> updateUserToken(userID, token) async {
    bool docExists = await DatabaseMethods().checkIfDocExists(userID);
    if (docExists) {
      await FirebaseFirestore.instance.collection('users').doc(userID).update({
        'FCMToken': token,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('magasins')
          .doc(userID)
          .update({
        'FCMToken': token,
      });
    }
  }

  Future<List<DocumentSnapshot>> takeUserInformationFromFBDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('FCMToken', isEqualTo: prefs.get('FCMToken') ?? 'None')
        .get();
    return result.docs;
  }

  // ignore: missing_return
  Future getUnreadMSGCount(String? peerUserID) async {
    try {
      int unReadMSGCount = 0;
      QuerySnapshot userChatList = await FirebaseFirestore.instance
          .collection('users')
          .doc(peerUserID)
          .collection('chatlist')
          .get();
      List<QueryDocumentSnapshot> chatListDocuments = userChatList.docs;
      for (QueryDocumentSnapshot snapshot in chatListDocuments) {
        unReadMSGCount = unReadMSGCount + snapshot['badgeCount'] as int;
      }
      // print('unread MSG count is $unReadMSGCount');
      return unReadMSGCount;
    } catch (e) {
      print(e);
    }
  }

  Future updateUserChatListField(String documentID, String lastMessage, chatID,
      myID, selectedUserID) async {
    int userBadgeCount = 0;
    var isRoom = false;

    print("myID : " + documentID);
    print("SelectedID : " + selectedUserID);

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(documentID)
        .collection('chatlist')
        .doc(chatID)
        .get();

    if (userDoc.data() != null) {
      isRoom = userDoc.get('inRoom') ?? false;
      if (selectedUserID != myID && !userDoc['inRoom']) {
        userBadgeCount = userDoc['badgeCount'];
        userBadgeCount++;
      }
    } else {
      userBadgeCount++;
    }

    await FirebaseFirestore.instance
        .collection('commonData')
        .doc(chatID)
        .update({'lastMessage': lastMessage, 'timestamp': DateTime.now()});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(documentID)
        .collection('chatlist')
        .doc(chatID)
        .set({
      'id': documentID,
      'chatID': chatID,
      'chatWith': documentID == myID ? selectedUserID : myID,
      'lastChat': lastMessage,
      'badgeCount': isRoom ? 0 : userBadgeCount,
      'inRoom': isRoom,
      'timestamp': DateTime.now()
    });
  }

  Future sendMessageToChatRoom(
      chatID, myID, selectedUserID, content, messageType) async {
    await FirebaseFirestore.instance
        .collection('commonData')
        .doc(chatID)
        .collection("messages")
        .doc()
        .set({
      "idFrom": myID,
      "idTo": selectedUserID,
      'timestamp': DateTime.now(),
      'message': content,
      'type': messageType,
      'isread': false,
      'sentByClient': true
    });
  }
}
