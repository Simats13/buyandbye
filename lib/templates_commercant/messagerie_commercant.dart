import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/image_controller.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/utils.dart';
import 'package:buyandbye/templates/Messagerie/subWidgets/local_notification_view.dart';
import 'package:buyandbye/templates/Pages/chatscreen.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buyandbye/services/database.dart';
import 'package:buyandbye/templates/Widgets/loader.dart';

class MessagerieCommercant extends StatefulWidget {
  const MessagerieCommercant({Key? key}) : super(key: key);

  @override
  _MessagerieCommercantState createState() => _MessagerieCommercantState();
}

class _MessagerieCommercantState extends State<MessagerieCommercant> with LocalNotificationView {
  String? myUserName, myProfilePic, userid;
  bool messageExist = false;

  getMyInfo(context) async {
    StreamBuilder<dynamic>(
      stream: ProviderUserId().returnUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          userid = snapshot.data.uid;
          myUserName = snapshot.data.displayName;
          myProfilePic = snapshot.data.photoUrl;
        }
        return const Text('bla');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
        backgroundColor: BuyandByeAppTheme.blackElectrik,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where("users", arrayContains: ProviderUserId().returnData())
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
              //METTRE UN SHIMMER
            } else if (!userSnapshot.hasData) {
              return const ColorLoader3();
            } else {
              getMyInfo(context);
              return countChatListUsers(myUserName, userSnapshot as AsyncSnapshot<QuerySnapshot<Object>>) > 0
                  ? Stack(
                      children: [
                        ListView.builder(
                          itemCount: userSnapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            DocumentSnapshot ds = userSnapshot.data!.docs[index];
                            return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName, ds["users"][0], index);
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
                            'Vous n\'avez aucun nouveau message.\n\nVous pouvez contacter n\'importe quel utilisateur depuis la page commande.',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ));
            }
          }),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String? lastMessage, chatRoomId, myUsername, clientID;
  final int index;
  const ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername, this.clientID, this.index, {Key? key}) : super(key: key);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String? profilePicUrl = "", fname, lname, token = "", userid, idTest, myProfilePicUrl;

  bool isActive = false;
  getThisUserInfo() async {
    final User user = await ProviderUserId().returnUser();
    userid = user.uid;
    QuerySnapshot querySnapshot2 = await DatabaseMethods().getMagasinInfo(userid);
    myProfilePicUrl = "${querySnapshot2.docs[0]["imgUrl"]}";
    QuerySnapshot querySnapshot = await ProviderUserInfo().returnData();
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
      const ColorLoader3(
        radius: 15.0,
        dotRadius: 6.0,
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('magasins').doc(userid).collection('chatlist').orderBy("timestamp", descending: true).snapshots(),
        builder: (context, chatListSnapshot) {
          if (chatListSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ColorLoader3(
                radius: 15.0,
                dotRadius: 6.0,
              ),
            );
          }

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ImageController.instance.cachedImage(profilePicUrl!),
            ),
            title: fname == null ? const CircularProgressIndicator() : Text(fname! + " " + lname!),
            subtitle: Text(
              widget.lastMessage!,
              style: isActive == true ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold) : const TextStyle(),
            ),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 4, 4),
              child: (chatListSnapshot.hasData)
                  ? SizedBox(
                      width: 80,
                      height: 50,
                      child: Column(
                        children: const [
                          // Text(
                          //   (chatListSnapshot.hasData &&
                          //           chatListSnapshot.data!.docs.length > 0)
                          //       ? readTimestamp(chatListSnapshot
                          //           .data!.docs[widget.index]['timestamp'])
                          //       : '',
                          //   style: TextStyle(fontSize: size.width * 0.03),
                          // ),
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
                  : '' as Widget?,
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatRoom(
                        userid!, //ID DE L'UTILISATEUR
                        widget.myUsername!, // NOM DE L'UTILISATEUR
                        token!,
                        idTest!, // ID DU CORRESPONDANT
                        widget.chatRoomId!, //ID DE LA CONV
                        fname!, // PRENOM DU CORRESPONDANT
                        lname!, // NOM DU CORRESPONDANT
                        profilePicUrl!, // IMAGE DU CORRESPONDANT
                        myProfilePicUrl!, // IMAGE DE L'UTILISATEUR
                        "magasins" // TYPE D'UTILISATEUR
                        ))),
          );
        },
      );
    }
    return const SizedBox(width: 0.0, height: 0.0);
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
