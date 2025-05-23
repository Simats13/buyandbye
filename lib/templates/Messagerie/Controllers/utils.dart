import 'dart:math';

import 'package:buyandbye/templates/Messagerie/Model/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// For Chat List Functions

// String readTimestamp(int timestamp) {
//   initializeDateFormatting('fr_FR');
//   var now = DateTime.now();
//   var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//   var diff = now.difference(date);
//   var time = '';

//   if (diff.inSeconds <= 0 ||
//       diff.inSeconds > 0 && diff.inMinutes == 0 ||
//       diff.inMinutes > 0 && diff.inHours == 0 ||
//       diff.inHours > 0 && diff.inDays == 0) {
//     if (diff.inHours > 0) {
//       time = 'Il y a ' + diff.inHours.toString() + ' h';
//     } else if (diff.inMinutes > 0) {
//       time = 'Il y a ' + diff.inMinutes.toString() + ' min';
//     } else if (diff.inSeconds > 0) {
//       time = 'Maintenant';
//     } else if (diff.inMilliseconds > 0) {
//       time = 'Maintenant';
//     } else if (diff.inMicroseconds > 0) {
//       time = 'Maintenant';
//     } else {
//       time = 'Maintenant';
//     }
//   } else if (diff.inDays > 0 && diff.inDays < 7) {
//     time = 'Il y a ' + diff.inDays.toString() + ' jour';
//   } else if (diff.inDays > 6) {
//     time = 'Il y a ' + (diff.inDays / 7).floor().toString() + ' sec';
//   } else if (diff.inDays > 29) {
//     time = 'Il y a ' + (diff.inDays / 30).floor().toString() + ' min';
//   } else if (diff.inDays > 365) {
//     time = '${date.day}-${date.month}-${date.year}';
//   }
//   return time;
// }

String makeChatId(myID, selectedUserID) {
  String chatID;
  if (myID.hashCode > selectedUserID.hashCode) {
    chatID = '$selectedUserID-$myID';
  } else {
    chatID = '$myID-$selectedUserID';
  }
  return chatID;
}

int countChatListUsers(myUserName, AsyncSnapshot<QuerySnapshot> snapshot) {
  int resultInt = snapshot.data!.docs.length;
  for (var data in snapshot.data!.docs) {
    if (data['users'][0] == myUserName) {
      resultInt++;
    }
  }
  return resultInt;
}

// For ChatRoom Functions

void setCurrentChatRoomID(value) async {
  // To know where I am in chat room. Avoid local notification.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('currentChatRoom', value);
}

List<dynamic> addInstructionInSnapshot(List<QueryDocumentSnapshot> snapshot) {
  List<dynamic> _returnList;
  List<dynamic> _newData = addChatDateInSnapshot(snapshot);
  _returnList = List<dynamic>.from(_newData.reversed);
  _returnList.add(chatInstruction);
  // print(_returnList);
  return _returnList;
}

List<dynamic> addChatDateInSnapshot(List<QueryDocumentSnapshot> snapshot) {
  List<dynamic> _returnList = [];
  Timestamp? _currentDate;

  for (QueryDocumentSnapshot snapshot in snapshot) {
    var date = snapshot['timestamp'];
    // print(date);

    if (_currentDate == null) {
      _currentDate = date;
      _returnList.add(_currentDate);
    }

    if (_currentDate == date) {
      _returnList.add(snapshot);
    } else {
      _currentDate = date;
      _returnList.add(_currentDate);
      _returnList.add(snapshot);
    }
  }

  return _returnList;
}

String checkValidUserData(userImageFile, userImageUrlFromFB, name, intro) {
  String returnString = '';
  if (userImageFile.path == '' && userImageUrlFromFB == '') {
    returnString = returnString + 'Please select a image.';
  }

  if (name.trim() == '') {
    if (returnString.trim() != '') {
      returnString = returnString + '\n\n';
    }
    returnString = returnString + 'Please type your name';
  }

  if (intro.trim() == '') {
    if (returnString.trim() != '') {
      returnString = returnString + '\n\n';
    }
    returnString = returnString + 'Please type your intro';
  }
  return returnString;
}

String randomIdWithName(userName) {
  int randomNumber = Random().nextInt(100000);
  return '$userName$randomNumber';
}
