import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/helperfun/sharedpref_helper.dart';
import 'package:oficihome/screens/signin.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/services/database.dart';
import 'package:oficihome/screens/chatscreen.dart';
import 'package:oficihome/templates/loginPage2.dart';
import 'package:oficihome/templates/pages/pageAccueil.dart';
import 'package:oficihome/templates/pages/pageCompte.dart';
import 'package:oficihome/templates/pages/pageExplore.dart';
import 'package:oficihome/templates/pages/pageMessagerie.dart';
import 'package:oficihome/templates/pages/pageSearch.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {

  int pageIndex = 0;

  Widget _affichePage = PageAccueil();
  final PageAccueil _pageAccueil = PageAccueil();
  final PageCompte _pageCompte = PageCompte();
  final PageExplore _pageExplore = PageExplore();
  final PageSearch _pageSearch = PageSearch();
  final PageMessagerie _pageMessagerie = PageMessagerie();

  Widget _pageSelection(int page) {
    switch (page) {
      case 0:
        return _pageAccueil;
        break;
      case 1:
        return _pageSearch;
        break;
      case 2:
        return _pageExplore;
        break;
      case 3:
        return _pageMessagerie;
        break;
      case 4:
        return _pageCompte;
        break;
      default:
        return null;
    }
  }

  bool isSearching = false;
  String myName, myProfilePic, myUserName, myEmail;
  Stream userStream;

  TextEditingController searchUsernameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    userStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);
    setState(() {});
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(name), Text(email)],
          )
        ],
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds['imgUrl'],
                      name: ds['name'],
                      email: ds['email'],
                      username: ds['username']);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomList() {
    return Container();
  }

  @override
  void initState() {
    getMyInfoFromSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _affichePage,
        bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.grey[200],
        height: 70.0,
        items: [
          Icon(
            Icons.home,
            size: 30.0,
          ),
          Icon(
            Icons.search,
            size: 30.0,
          ),
          Icon(
            Icons.explore,
            size: 30.0,
          ),
          Icon(
            Icons.message,
            size: 30.0,
          ),
          Icon(
            Icons.person,
            size: 30.0,
          ),
        ],
        onTap: (int tappedIndex) {
          setState(() {
            _affichePage = _pageSelection(tappedIndex);
          });
        },
      ),
    );
  }
}
