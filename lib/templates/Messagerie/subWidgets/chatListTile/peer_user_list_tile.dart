import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../common_widgets.dart';

Widget peerUserListTile(BuildContext context, String name, String thumbnail,
    String? message, Timestamp time, String? type) {
  final size = MediaQuery.of(context).size;
  return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: CachedNetworkImage(
                    imageUrl: thumbnail,
                    placeholder: (context, url) => Container(
                      transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                      child: const SizedBox(
                          width: 60,
                          height: 60,
                          child:
                              Center(child: CircularProgressIndicator())),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: size.width - 150),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(type == 'text' ? 10.0 : 0),
                          child: Container(
                              child: type == 'text'
                                  ? Text(
                                      message!,
                                      style: const TextStyle(color: Colors.black),
                                    )
                                  : imageMessage(context, message)),
                        ),
                      ),
                    ),
                    // padding contenant le timestamp
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14.0, left: 4),
                      child: Text(
                        "",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
