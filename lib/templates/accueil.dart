import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/templates/pages/pageAccueil.dart';
import 'package:oficihome/templates/pages/pageCompte.dart';
import 'package:oficihome/templates/pages/pageExplore.dart';
import 'package:oficihome/templates/pages/pageMessagerie.dart';
import 'package:oficihome/templates/pages/pageSearch.dart';
import 'package:oficihome/services/auth.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  void initState() {
    super.initState();
    AuthMethods.toogleNavBar = this.toogleNavBar;
  }
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

  bool showNavBar = true;
  void toogleNavBar() {
    showNavBar = !showNavBar;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
      return WillPopScope(
    onWillPop: () async => Navigator.of(context).userGestureInProgress,
      child: Scaffold(
        body: _affichePage,
        bottomNavigationBar: showNavBar
            ? CurvedNavigationBar(
                color: Theme.of(context).bottomAppBarColor,
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
              )
            : null,
      ),
    );
  }
}
