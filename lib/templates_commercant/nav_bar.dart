import 'package:flutter/material.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:badges/badges.dart';

import 'accueilCommercant.dart';
import 'commandesCommercant.dart';
import 'produitsCommercant.dart';
import 'compteCommercant.dart';
import 'messagerieCommercant.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  void initState() {
    super.initState();
    AuthMethods.toogleNavBar = this.toogleNavBar;
  }

  int pageIndex = 0;
  int badgeCommandes = 8;
  int badgeMessages = 1;
  double gap = 8;

  Widget _affichePage = AccueilCommercant();
  final AccueilCommercant _accueilCommercant = AccueilCommercant();
  final CommandesCommercant _commandesCommercant = CommandesCommercant();
  final Products _products = Products();
  final MessagerieCommercant _messagerieCommercant = MessagerieCommercant();
  final CompteCommercant _compteCommercant = CompteCommercant();

  Widget _pageSelection(int page) {
    switch (page) {
      case 0:
        return _accueilCommercant;
        break;
      case 1:
        return _commandesCommercant;
        break;
      case 2:
        return _products;
        break;
      case 3:
        return _messagerieCommercant;
        break;
      case 4:
        return _compteCommercant;
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
                              gap: gap,
                              iconActiveColor: Colors.pink,
                              iconColor: Colors.black,
                              textColor: Colors.pink,
                              backgroundColor: Colors.pink.withOpacity(.2),
                              iconSize: 24,
                              icon: Icons.shopping_bag_rounded,
                              leading: pageIndex == 1 || badgeCommandes == 0
                                  ? null
                                  : Badge(
                                      badgeColor: Colors.red.shade100,
                                      elevation: 0,
                                      position: BadgePosition.topEnd(
                                          top: -12, end: -10),
                                      badgeContent: Text(
                                        badgeCommandes.toString(),
                                        style: TextStyle(
                                            color: Colors.red.shade900),
                                      ),
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        color: pageIndex == 1
                                            ? Colors.pink
                                            : Colors.black,
                                      ),
                                    ),
                              text: 'Commandes',
                            ),
                            GButton(
                              icon: Icons.add_business_rounded,
                              text: 'Produits',
                              hoverColor: Colors.orange[100],
                              backgroundColor: Colors.orange[100],
                              iconActiveColor: Colors.orange,
                              textColor: Colors.orange,
                            ),
                            GButton(
                              gap: gap,
                              icon: Icons.message,
                              text: 'Messages',
                              hoverColor: Colors.teal[100],
                              backgroundColor: Colors.teal[100],
                              iconActiveColor: Colors.teal,
                              textColor: Colors.teal,
                              leading: pageIndex == 1 || badgeMessages == 0
                                  ? null
                                  : Badge(
                                      badgeColor: Colors.red.shade100,
                                      elevation: 0,
                                      position: BadgePosition.topEnd(
                                          top: -12, end: -12),
                                      badgeContent: Text(
                                        badgeMessages.toString(),
                                        style: TextStyle(
                                            color: Colors.red.shade900),
                                      ),
                                      child: Icon(
                                        Icons.message,
                                        color: pageIndex == 1
                                            ? Colors.teal
                                            : Colors.black,
                                      ),
                                    ),
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
