import 'package:flutter/material.dart';
import 'package:buyandbye/templates/pages/page_accueil.dart';
import 'package:buyandbye/templates/pages/page_compte.dart';
import 'package:buyandbye/templates/pages/page_explore.dart';
import 'package:buyandbye/templates/pages/page_messagerie.dart';
import 'package:buyandbye/templates/pages/page_search.dart';
import 'package:buyandbye/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Accueil extends StatefulWidget {
  final List<Widget>? screens;

  const Accueil({Key? key, this.screens}) : super(key: key);
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  void initState() {
    super.initState();
    AuthMethods.toogleNavBar = toogleNavBar;
  }

  //INDEX DES PAGES
  int pageIndex = 0;
  // Création d'une liste permettant l'indexation des pages
  final List<Widget> pages = [
    const PageAccueil(),
    const PageSearch(),
    const PageExplore(),
    const PageMessagerie(),
    const PageCompte(),
  ];

  //Affiche la barre de navigation si l'utilisateur est connecté ou non
  bool showNavBar = true;
  void toogleNavBar() {
    showNavBar = !showNavBar;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
        //Empile les pages afin de les garder dans des états
        body: IndexedStack(
          index: pageIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
            ]),
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 6),
                    child: GNav(
                      gap: 2,
                      haptic: true,
                      iconSize: 28,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12.5, vertical: 10),
                      duration: const Duration(milliseconds: 400),
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
                      selectedIndex: pageIndex,
                      onTabChange: (int tappedIndex) {
                        setState(() {
                          // _affichePage = _pageSelection(tappedIndex);
                          pageIndex = tappedIndex;
                        });
                      },
                    )))));
  }
}
