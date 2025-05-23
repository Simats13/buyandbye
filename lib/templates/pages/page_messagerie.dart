import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../Messagerie/Controllers/fb_messaging.dart';
import '../Messagerie/Controllers/image_controller.dart';
import '../Messagerie/Controllers/utils.dart';
import '../Pages/chatscreen.dart';
import '../Messagerie/subWidgets/local_notification_view.dart';
import '../buyandbye_app_theme.dart';

class PageMessagerie extends StatefulWidget {
  const PageMessagerie({Key? key}) : super(key: key);

  @override
  _PageMessagerieState createState() => _PageMessagerieState();
}

class _PageMessagerieState extends State<PageMessagerie>
    with LocalNotificationView {
  String? myID, myUserName;
  bool messageExist = false;
  @override
  void initState() {
    super.initState();
    NotificationController.instance.updateTokenToServer();
    getMyInfo();
  }

  getMyInfo() async {
    final User user = await ProviderUserId().returnUser();
    final userid = user.uid;
    myID = userid;
    myUserName = user.displayName;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyandByeAppTheme.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text: 'Messagerie',
                    style: TextStyle(
                      fontSize: 20,
                      color: BuyandByeAppTheme.orangeMiFonce,
                      fontWeight: FontWeight.bold,
                    )),
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.chat,
                      color: BuyandByeAppTheme.orangeFonce,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: BuyandByeAppTheme.white,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          bottomOpacity: 0.0,
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('commonData')
              .where("users", arrayContains: myID)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              );
            }
            if (!userSnapshot.hasData) return const ColorLoader3();
            return countChatListUsers(myUserName,
                        userSnapshot as AsyncSnapshot<QuerySnapshot<Object>>) >
                    0
                ? Stack(
                    children: [
                      ListView.builder(
                        itemCount: userSnapshot.data!.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = userSnapshot.data!.docs[index];
                          return Slidable(
                            // Specify a key if the Slidable is dismissible.
                            key: const ValueKey(0),

                            // The end action pane is the one at the right or the bottom side.
                            endActionPane: const ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: null,
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Supprimer',
                                ),
                              ],
                            ),

                            // The child of the Slidable is what the user sees when the
                            // component is not dragged.
                            child: ChatRoomListTile(ds["lastMessage"], ds.id,
                                myUserName, ds["users"][0], index),
                          );
                        },
                      ),
                    ],
                  )
                : Center(
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
                        'Vous n\'avez aucun nouveau message.\n\nVous pouvez contacter n\'importe quel commerçant depuis sa page magasin.',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String? lastMessage, chatRoomId, myUsername, sellerID;
  final int index;
  const ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername,
      this.sellerID, this.index, {Key? key}) : super(key: key);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String? profilePicUrl, name, token, userid, myThumbnail, chatRoomId;

  getThisUserInfo() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
    var querySnapshot = await DatabaseMethods().getMagasinInfo(widget.sellerID);
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    token = "${querySnapshot.docs[0]["FCMToken"]}";
    setState(() {});
  }

  getMyInfo() async {
    QuerySnapshot querySnapshot = await ProviderUserInfo().returnData();
    myThumbnail = "${querySnapshot.docs[0]["imgUrl"]}";
  }

  @override
  void initState() {
    getThisUserInfo();
    getMyInfo();
    super.initState();
  }

  bool? isActive;

  @override
  Widget build(BuildContext context) {
    if (profilePicUrl == null) {
      const ColorLoader3(
        radius: 15.0,
        dotRadius: 6.0,
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commonData')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, chatListSnapshot) {
          if (chatListSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
            );
          }

          // if (chatListSnapshot.data!.docs[widget.index].get('badgeCount') !=
          //     0) {
          //   isActive = true;
          // } else {
          //   isActive = false;
          // }

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ImageController.instance.cachedImage(profilePicUrl!),
            ),
            title: Text(name!),
            subtitle: Text(
              widget.lastMessage!,
              style: isActive == true
                  ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                  : const TextStyle(),
            ),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 4, 4),
              child: (chatListSnapshot.hasData &&
                      chatListSnapshot.data!.docs.isNotEmpty)
                  ? SizedBox(
                      width: 80,
                      height: 50,
                      child: Column(
                        children: [
                          // Text(
                          //   (chatListSnapshot.hasData &&
                          //           chatListSnapshot.data!.docs.length > 0)
                          //       ? readTimestamp(chatListSnapshot
                          //           .data!.docs[widget.index]['timestamp'])
                          //       : '',
                          //   style: TextStyle(fontSize: size.width * 0.03),
                          // ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: CircleAvatar(
                              radius: 9,
                              child: Text(
                                chatListSnapshot.data!.docs[widget.index]
                                            .get('badgeCount') ==
                                        null
                                    ? ''
                                    : chatListSnapshot.data!.docs[widget.index]
                                                .get('badgeCount') !=
                                            0
                                        ? '${chatListSnapshot.data!.docs[widget.index].get('badgeCount')}'
                                        : '',
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: chatListSnapshot
                                          .data!.docs[widget.index]
                                          .get('badgeCount') ==
                                      null
                                  ? Colors.transparent
                                  : (chatListSnapshot.data!.docs[0]
                                              ['badgeCount'] !=
                                          0
                                      ? Colors.red[400]
                                      : Colors.transparent),
                              foregroundColor: Colors.black,
                            ),
                          )
                        ],
                      ),
                    )
                  : const Text(''),
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatRoom(
                        userid!, //ID DE L'UTILISATEUR
                        widget.myUsername!, // NOM DE L'UTILISATEUR
                        token!,
                        widget.sellerID!, // ID DU CORRESPONDANT
                        widget.chatRoomId!, //ID DE LA CONV
                        name!, // PRENOM DU CORRESPONDANT
                        "", // NOM DU CORRESPONDANT
                        profilePicUrl!, // IMAGE DU CORRESPONDANT
                        myThumbnail!, // IMAGE DE L'UTILISATEUR
                        "users" // TYPE D'UTILISATEUR
                        ))),
          );
        },
      );
    }
    return const SizedBox(width: 0.0, height: 0.0);
  }
}