import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Pages/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion?> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  late PlaceApiProvider apiClient;
  String get searchFieldLabel => 'Rechercher une adresse';
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Effacer',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  // Obligé de créer buildResults mais je sais pas comment ça fonctionne #Clément
  @override
  Widget buildResults(BuildContext context) {
    return IconButton(
        tooltip: "I don't know",
        onPressed: () {},
        icon: Icon(Icons.ac_unit_outlined));
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Retour',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Entrez votre adresse'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(snapshot.data.description),
                    onTap: () {
                      close(context, snapshot.data[index] as Suggestion?);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(
                  child: Center(
                  child: Platform.isIOS
                      ? Column(
                          children: [
                            CupertinoActivityIndicator(),
                            Text('Chargement...'),
                          ],
                        )
                      : Column(
                          children: [
                            CircularProgressIndicator(),
                            Text('Chargement...'),
                          ],
                        ),
                )),
    );
  }
}
