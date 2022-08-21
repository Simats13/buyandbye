import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';
import 'package:buyandbye/templates/Messagerie/Controllers/fb_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Messagerie/Controllers/fb_firestore.dart';
import '../Messagerie/Controllers/fb_storage.dart';
import '../Messagerie/Controllers/image_controller.dart';
import '../Messagerie/Controllers/utils.dart';
import '../Messagerie/subWidgets/chatListTile/mine_list_tile.dart';
import '../Messagerie/subWidgets/chatListTile/peer_user_list_tile.dart';
import '../Messagerie/subWidgets/chatListTile/string_list_tile.dart';
import '../Messagerie/subWidgets/common_widgets.dart';
import '../Messagerie/subWidgets/local_notification_view.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom(
      this.myID,
      this.myName,
      this.selectedUserToken,
      this.selectedUserID,
      this.chatID,
      this.selectedUserFname,
      this.selectedUserLname,
      this.selectedUserThumbnail,
      this.myThumbnail,
      this.userType, {Key? key}) : super(key: key);

  final String? myID,
      myName,
      selectedUserToken,
      selectedUserID,
      chatID,
      selectedUserFname,
      selectedUserLname,
      selectedUserThumbnail,
      myThumbnail,
      userType;

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>
    with WidgetsBindingObserver, LocalNotificationView {
  final TextEditingController _msgTextController = TextEditingController();
  final ScrollController _chatListController = ScrollController();
  String messageType = 'text';
  int chatListLength = 20;
  bool celafonctionne = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      switch (state) {
        case AppLifecycleState.resumed:
          FBCloudStore.instance.updateMyChatListValues(
              true, widget.myID, widget.chatID, widget.userType);
          break;
        case AppLifecycleState.inactive:
          FBCloudStore.instance.updateMyChatListValues(
              false, widget.myID, widget.chatID, widget.userType);
          break;
        case AppLifecycleState.paused:
          FBCloudStore.instance.updateMyChatListValues(
              false, widget.myID, widget.chatID, widget.userType);
          break;
        case AppLifecycleState.detached:
          break;
      }
    });
  }

  @override
  void initState() {
    print('hello');
    super.initState();
    // print("J'avais raison");
    // print(widget.selectedUserToken);
    // print(widget.selectedUserID);
    WidgetsBinding.instance!.addObserver(this);
    FBCloudStore.instance.updateMyChatListValues(
        true, widget.myID, widget.chatID, widget.userType);

    if (mounted) {
      isShowLocalNotification = true;
      _savedChatId(widget.chatID!);
      checkLocalNotification(localNotificationAnimation, widget.chatID);
    }
    initializeDateFormatting('fr_FR');
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

  Future<void> _savedChatId(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("inRoomChatId", value);
  }

  @override
  void dispose() {
    isShowLocalNotification = false;
    FBCloudStore.instance.updateMyChatListValues(
        false, widget.myID, widget.chatID, widget.userType);
    _savedChatId("");
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: const Color.fromRGBO(250, 250, 250, 1),
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              title: RichText(
                text: TextSpan(
                  // style: Theme.of(context).textTheme.bodyText2,
                  children: [
                    TextSpan(
                        text: widget.selectedUserFname! +
                            " " +
                            widget.selectedUserLname!,
                        style: const TextStyle(
                          fontSize: 20,
                          color: BuyandByeAppTheme.orangeMiFonce,
                          fontWeight: FontWeight.bold,
                        )),
                    const WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Icon(
                          Icons.message,
                          color: BuyandByeAppTheme.orangeMiFonce,
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
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: BuyandByeAppTheme.orange,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('commonData')
                    .doc(widget.chatID)
                    .collection("messages")
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: ListView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                reverse: true,
                                shrinkWrap: true,
                                controller: _chatListController,
                                children:
                                    addInstructionInSnapshot(snapshot.data.docs)
                                        .map(_returnChatWidget)
                                        .toList()),
                          ),
                          _buildTextComposer(),
                        ],
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget _returnChatWidget(dynamic data) {
    Widget returnWidget = Container();

    if (data is QueryDocumentSnapshot) {
      // print(data['timestamp']);
      if (data['idTo'] == widget.myID && data['isread'] == false) {
        FirebaseFirestore.instance
            .runTransaction((Transaction myTransaction) async {
          myTransaction.update(data.reference, {'isread': true});
        });
      }

      returnWidget = data['idFrom'] == widget.selectedUserID
          ? peerUserListTile(
              context,
              widget.selectedUserFname! + " " + widget.selectedUserLname!,
              widget.selectedUserThumbnail!,
              data['message'],
              data['timestamp'],
              data['type'])
          : mineListTile(context, data['message'], data['timestamp'],
              data['isread'], data['type']);
    } else if (data is String) {
      returnWidget = stringListTile(data);
    }
    // print(returnWidget);
    return returnWidget;
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                  icon: const Icon(
                    Icons.photo,
                    color: BuyandByeAppTheme.orangeMiFonce,
                  ),
                  onPressed: () {
                    ImageController.instance
                        .cropImageFromFile()
                        .then((croppedFile) {
                      setState(() {
                        messageType = 'image';
                      });
                      _saveUserImageToFirebaseStorage(croppedFile);
                    });
                  }),
            ),
            Flexible(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      celafonctionne = true;
                    } else {
                      celafonctionne = false;
                    }
                  });
                },
                textCapitalization: TextCapitalization.sentences,
                controller: _msgTextController,
                onSubmitted: _handleSubmitted,
                minLines: 1,
                maxLines: 5,
                decoration:
                    const InputDecoration.collapsed(hintText: "Envoyer un message"),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color:
                    celafonctionne ? BuyandByeAppTheme.orangeMiFonce : null,
              ),
              onPressed: celafonctionne
                  ? () {
                      setState(() {
                        messageType = 'text';
                      });
                      _handleSubmitted(_msgTextController.text);
                      _msgTextController.text = '';
                      celafonctionne = false;
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserImageToFirebaseStorage(croppedFile) async {
    try {
      String takeImageURL = await FBStorage.instance
          .sendImageToUserInChatRoom(croppedFile, widget.chatID);
      _handleSubmitted(takeImageURL);
    } catch (e) {
      showAlertDialog(context, "Impossible d'envoyer l'image");
    }
  }

  Future<void> _handleSubmitted(String text) async {
    try {
      await FBCloudStore.instance.sendMessageToChatRoom(
          widget.chatID, widget.myID, widget.selectedUserID, text, messageType);
      await FBCloudStore.instance.updateUserChatListField(
        widget.selectedUserID!,
        messageType == 'text' ? text : 'A envoyé une photo',
        widget.chatID,
        widget.myID,
        widget.selectedUserID,
      );

      await FBCloudStore.instance.updateUserChatListField(
          widget.myID!,
          messageType == 'text' ? text : 'A envoyé une photo',
          widget.chatID,
          widget.myID,
          widget.selectedUserID);
      _getUnreadMSGCountThenSendMessage();
    } catch (e) {
      showAlertDialog(context, 'Error user information to database');
    }
  }

  Future<void> _getUnreadMSGCountThenSendMessage() async {
    try {
      int unReadMSGCount =
          await FBCloudStore.instance.getUnreadMSGCount(widget.selectedUserID);
      await NotificationController.instance.sendNotificationMessageToPeerUser(
          unReadMSGCount,
          messageType,
          _msgTextController.text,
          widget.myName,
          widget.chatID,
          widget.selectedUserToken,
          widget.myThumbnail,
          widget.selectedUserToken,
          widget.selectedUserID);
    } catch (e) {
      print(e);
    }
  }
}
