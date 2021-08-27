import 'package:flutter/material.dart';
import 'package:buyandbye/templates/pages/pageAccueil.dart';
import 'package:buyandbye/templates/pages/pageCompte.dart';
import 'package:buyandbye/templates/pages/pageExplore.dart';
import 'package:buyandbye/templates/pages/pageMessagerie.dart';
import 'package:buyandbye/templates/pages/pageSearch.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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
            ? Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
                ]),
                child: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8),
                        child: GNav(
                          gap: 2,
                          haptic: true,
                          iconSize: 28,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          duration: Duration(milliseconds: 400),
                          tabs: [
                            GButton(
                              icon: Icons.home,
                              text: 'Accueil',
                              hoverColor: Colors.purple[100],
                              backgroundColor: Colors.purple[100],
                              iconActiveColor: Colors.purple,
                              textColor: Colors.purple,
                            ),
                            GButton(
                              icon: Icons.search,
                              text: 'Recherche',
                              hoverColor: Colors.pink[100],
                              backgroundColor: Colors.pink[100],
                              iconActiveColor: Colors.pink,
                              textColor: Colors.pink,
                            ),
                            GButton(
                              icon: Icons.map,
                              text: 'Carte',
                              hoverColor: Colors.orange[100],
                              backgroundColor: Colors.orange[100],
                              iconActiveColor: Colors.orange,
                              textColor: Colors.orange,
                            ),
                            GButton(
                              icon: Icons.message,
                              text: 'Messages',
                              hoverColor: Colors.teal[100],
                              backgroundColor: Colors.teal[100],
                              iconActiveColor: Colors.teal,
                              textColor: Colors.teal,
                            ),
                            GButton(
                              icon: Icons.person,
                              text: 'Compte',
                              hoverColor: Colors.blue[100],
                              backgroundColor: Colors.blue[100],
                              iconActiveColor: Colors.blue,
                              textColor: Colors.blue,
                            ),
                          ],
                          onTabChange: (int tappedIndex) {
                            setState(() {
                              _affichePage = _pageSelection(tappedIndex);
                            });
                          },
                        ))))
            : null,
      ),
    );
  }
}
