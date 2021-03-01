import 'package:flutter/material.dart';
import 'package:oficihome/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:oficihome/helperfun/sharedpref_helper.dart';
import 'package:oficihome/templates/pages/pageBienvenue.dart';

class PageCompte extends StatefulWidget {
  @override
  _PageCompteState createState() => _PageCompteState();
}

class _PageCompteState extends State<PageCompte> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Mon Compte',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                height: 200.0,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(.9),
                      Colors.black12.withOpacity(.05),
                    ], begin: Alignment.bottomRight)),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3.0),
                                image: DecorationImage(
                                    image: NetworkImage(""),
                                    fit: BoxFit.cover)),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NOM D'UTILISATEUR",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    onPressed: () {
                      AuthMethods().signOut().then((s) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PageBievenue()));
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.red,
                    child: Text(
                      'Deconnexion',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
