import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/helperfun/sharedpref_helper.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/fb_messaging.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/image_controller.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/utils.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/common_widgets.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/local_notification_view.dart';
import 'package:buyandbye/templates/Pages/chatscreen.dart';

class MessagerieCommercant extends StatefulWidget {
  @override
  _MessagerieCommercantState createState() => _MessagerieCommercantState();
}

class _MessagerieCommercantState extends State<MessagerieCommercant>
    with LocalNotificationView {
  String myID;
  String myName, myUserName, myEmail;
  String myProfilePic;
  @override
  void initState() {
    super.initState();
    NotificationController.instance.updateTokenToServer();
    if (mounted) {
      checkLocalNotification(localNotificationAnimation, "");
    }
    getMyInfoFromSharedPreference();
  }

  void localNotificationAnimation(List<dynamic> data) {
    if (mounted) {
      setState(() {
        if (data[1] == 1.0) {
          localNotificationData = data[0];
        }
        localNotificationAnimationOpacity = data[1] as double;
      });
    }
  }

  getMyInfoFromSharedPreference() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(userid);
    myID = userid;
    myUserName = "${querySnapshot.docs[0]["name"]}";
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messagerie Commerçant'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where("users", arrayContains: myID)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) return loadingCircleForFB();
            return countChatListUsers(myUserName, userSnapshot) > 0
                ? Column(
                    children: [
                      ListView.builder(
                        itemCount: userSnapshot.data.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = userSnapshot.data.docs[index];
                          return ChatRoomListTile(ds["lastMessage"], ds.id,
                              myUserName, ds["users"][0]);
                        },
                      ),
                    ],
                  )
                : Container(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.forum,
                          color: Colors.grey[700],
                          size: 64,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Vous n\'avez aucun nouveau message.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
                  );
          }),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, nameOther;
  ChatRoomListTile(
      this.lastMessage, this.chatRoomId, this.myUsername, this.nameOther);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "",
      name = "",
      username = "",
      token = "",
      userid,
      idTest;

  getThisUserInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    username = widget.nameOther;
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]["name"]}";
    name = "test";
    print("Name :" + name);
    idTest = "${querySnapshot.docs[0]["id"]}";
    print("idTest :" + idTest);
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    print("profilePicUrl :" + profilePicUrl);
    token = "${querySnapshot.docs[0]["FCMToken"]}";

    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .collection('chatlist')
          .where('id', isEqualTo: userid)
          .snapshots(),
      builder: (context, chatListSnapshot) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ImageController.instance.cachedImage(profilePicUrl),
          ),
          title: Text(name),
          subtitle: Text(widget.lastMessage),
          trailing: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 4, 4),
            child: (chatListSnapshot.hasData &&
                    chatListSnapshot.data.docs.length > 0)
                ? Container(
                    width: 60,
                    height: 50,
                    child: Column(
                      children: [
                        Text(
                          (chatListSnapshot.hasData &&
                                  chatListSnapshot.data.docs.length > 0)
                              ? readTimestamp(
                                  chatListSnapshot.data.docs[0]['timestamp'])
                              : '',
                          style: TextStyle(fontSize: size.width * 0.03),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: CircleAvatar(
                            radius: 9,
                            child: Text(
                              chatListSnapshot.data.docs[0].get('badgeCount') ==
                                      null
                                  ? ''
                                  : ((chatListSnapshot.data.docs[0]
                                              .get('badgeCount') !=
                                          0
                                      ? '${chatListSnapshot.data.docs[0].get('badgeCount')}'
                                      : '')),
                              style: TextStyle(fontSize: 10),
                            ),
                            backgroundColor: chatListSnapshot.data.docs[0]
                                        .get('badgeCount') ==
                                    null
                                ? Colors.transparent
                                : (chatListSnapshot.data.docs[0]
                                            ['badgeCount'] !=
                                        0
                                    ? Colors.red[400]
                                    : Colors.transparent),
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                : Text('Nothing to see here'),
          ),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatRoom(
                        userid, //ID DE L'UTILISATEUR
                        widget.myUsername, // NOM DE L'UTILISATEUR
                        token,
                        idTest, // ID DU CORRESPONDANT
                        widget.chatRoomId, //ID DE LA CONV
                        name, // NOM DU CORRESPONDANT
                        profilePicUrl, // IMAGE DU CORRESPONDANT
                      ))),
        );
      },
    ));
  }
}
