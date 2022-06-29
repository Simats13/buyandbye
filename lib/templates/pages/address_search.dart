import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Pages/place_service.dart';

class AddressSearch extends SearchDelegate {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  String sessionToken;
  late PlaceApiProvider apiClient;
  @override
  String get searchFieldLabel => 'Rechercher une adresse';
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Effacer',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Retour',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // close(context, null)
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(child: Text("buildResults"));
  }

  // List<String> listExample = List.generate(10, (index) => "Text $index");
  // List<String> recentList = ["Text 4", "Text 3"];
  // @override
  // Widget buildSuggestions(BuildContext context) {
  //   List<String> suggestionList = [];
  //   query.isEmpty
  //       ? suggestionList = recentList
  //       : suggestionList.addAll(listExample.where(
  //           (element) => element.contains(query),
  //         ));

  //   return ListView.builder(
  //       itemCount: suggestionList.length,
  //       itemBuilder: (context, index) {
  //         return ListTile(title: Text(suggestionList[index]));
  //       });
  // }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Entrez votre adresse'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data[index].description),
                    onTap: () {
                      close(context, snapshot.data[index]);
                    },
                  ),
                )
              : Center(
              child: Platform.isIOS
                  ? Column(
                      children: const [
                        CupertinoActivityIndicator(),
                        Text('Chargement...'),
                      ],
                    )
                  : Column(
                      children: const [
                        CircularProgressIndicator(),
                        Text('Chargement...'),
                      ],
                    ),
                ),
    );
  }
}
