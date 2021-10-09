import 'package:buyandbye/templates/Messagerie/Controllers/fb_messaging.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/image_controller.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/utils.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/local_notification_view.dart';
import 'package:buyandbye/templates/Pages/chatscreen.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';

class MessagerieCommercant extends StatefulWidget {
  @override
  _MessagerieCommercantState createState() => _MessagerieCommercantState();
}

class _MessagerieCommercantState extends State<MessagerieCommercant>
    with LocalNotificationView {
  String myID;
  String myName, myUserName, myEmail;
  String myProfilePic;
  bool messageExist = false;
  @override
  void initState() {
    super.initState();
    NotificationController.instance.updateTokenToServer();
    getMyInfoFromSharedPreference();
  }

  getMyInfoFromSharedPreference() async {
    final User user = await AuthMethods().getCurrentUser();
    final userid = user.uid;
    myID = userid;
    myName = user.displayName;
    myProfilePic = user.photoURL;
    myUserName = user.displayName;
    myEmail = user.email;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messagerie'),
        backgroundColor: BuyandByeAppTheme.black_electrik,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where("users", arrayContains: myID)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              );
              //METTRE UN SHIMMER
            }
            if (!userSnapshot.hasData) return ColorLoader3();
            return countChatListUsers(myUserName, userSnapshot) > 0
                ? Stack(
                    children: [
                      ListView.builder(
                        itemCount: userSnapshot.data.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = userSnapshot.data.docs[index];
                          return ChatRoomListTile(ds["lastMessage"], ds.id,
                              myUserName, ds["users"][0], index);
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
                            'Vous n\'avez aucun nouveau message.\n\nVous pouvez contacter n\'importe quel utilisateur depuis la page commande.',
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
  final String lastMessage, chatRoomId, myUsername, clientID;
  final int index;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername,
      this.clientID, this.index);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "",
      fname,
      lname,
      username = "",
      token = "",
      userid,
      idTest,
      myProfilePicUrl;

  bool isActive = false;
  getThisUserInfo() async {
    final User user = await AuthMethods().getCurrentUser();
    userid = user.uid;
    QuerySnapshot querySnapshot2 = await DatabaseMethods().getMyInfo(userid);
    myProfilePicUrl = "${querySnapshot2.docs[0]["imgUrl"]}";
    username = widget.clientID;
    QuerySnapshot querySnapshot = await DatabaseMethods().getMyInfo(username);
    fname = "${querySnapshot.docs[0]["fname"]}";
    lname = "${querySnapshot.docs[0]["lname"]}";
    idTest = "${querySnapshot.docs[0]["id"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
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
    if (profilePicUrl == null) {
      ColorLoader3(
        radius: 15.0,
        dotRadius: 6.0,
      );
    } else {
      final size = MediaQuery.of(context).size;
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userid)
            .collection('chatlist')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, chatListSnapshot) {
          if (chatListSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
            );
            //METTRE UN SHIMMER
          }
          // if (chatListSnapshot.data.docs[0].get('badgeCount') != 0) {
          //   isActive = true;
          // } else {
          //   isActive = false;
          // }

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ImageController.instance.cachedImage(profilePicUrl),
            ),
            title: fname == null
                ? CircularProgressIndicator()
                : Text(fname + " " + lname),
            subtitle: Text(
              widget.lastMessage,
              style: isActive == true
                  ? TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                  : TextStyle(),
            ),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 4, 4),
              child: (chatListSnapshot
                      .hasData /*&&
                      chatListSnapshot.data.docs.length > 0*/
                  )
                  ? Container(
                      width: 80,
                      height: 50,
                      child: Column(
                        children: [
                          Text(
                            (chatListSnapshot.hasData &&
                                    chatListSnapshot.data.docs.length > 0)
                                ? readTimestamp(chatListSnapshot
                                    .data.docs[widget.index]['timestamp'])
                                : '',
                            style: TextStyle(fontSize: size.width * 0.03),
                          ),
                          // Ecran rouge pendant 1 seconde
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          //   child: CircleAvatar(
                          //     radius: 9,
                          //     child: Text(
                          //       chatListSnapshot.data.docs[widget.index]
                          //                   .get('badgeCount') ==
                          //               null
                          //           ? ''
                          //           : ((chatListSnapshot.data.docs[widget.index]
                          //                       .get('badgeCount') !=
                          //                   0
                          //               ? '${chatListSnapshot.data.docs[widget.index].get('badgeCount')}'
                          //               : '')),
                          //       style: TextStyle(fontSize: 10),
                          //     ),
                          //     backgroundColor: chatListSnapshot
                          //                 .data.docs[widget.index]
                          //                 .get('badgeCount') ==
                          //             null
                          //         ? Colors.transparent
                          //         : (chatListSnapshot.data.docs[widget.index]
                          //                     ['badgeCount'] !=
                          //                 0
                          //             ? Colors.red[400]
                          //             : Colors.transparent),
                          //     foregroundColor: Colors.white,
                          //   ),
                          // )
                        ],
                      ),
                    )
                  : '',
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
                        fname, // PRENOM DU CORRESPONDANT
                        lname, // NOM DU CORRESPONDANT
                        profilePicUrl, // IMAGE DU CORRESPONDANT
                        myProfilePicUrl // IMAGE DE L'UTILISATEUR
                        ))),
          );
        },
      );
    }
    return Container(width: 0.0, height: 0.0);
  }

// Inutilisé
//   Future<void> _moveTochatRoom() async {
//     try {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => ChatRoom(
//                     userid, //ID DE L'UTILISATEUR
//                     widget.myUsername, // NOM DE L'UTILISATEUR
//                     token,
//                     idTest, // TOKEN DU CORRESPONDANT
//                     widget.chatRoomId, //ID DE LA CONV
//                     widget.clientID, // NOM DU CORRESPONDANT
//                     profilePicUrl,
//                   )));
//     } catch (e) {
//       print(e.message);
//     }
//   }
}
