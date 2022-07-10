import 'package:buyandbye/services/provider.dart';
import 'package:buyandbye/templates/buyandbye_app_theme.dart';
import 'package:flutter/material.dart';

class MesReservations extends StatefulWidget {
  @override
  const MesReservations({Key? key}) : super(key: key);

  @override
  _MesReservationsState createState() => _MesReservationsState();
}

class _MesReservationsState extends State<MesReservations> {
  String? userid, firstName, lastName, email;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: ProviderUserInfo().returnData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userid = snapshot.data["id"];
            firstName = snapshot.data["fname"];
            lastName = snapshot.data["lname"];
            email = snapshot.data["email"];
          }
          return Scaffold(
            backgroundColor: BuyandByeAppTheme.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                title: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Mes réservations',
                          style: TextStyle(
                            fontSize: 20,
                            color: BuyandByeAppTheme.orangeMiFonce,
                            fontWeight: FontWeight.bold,
                          )),
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Icon(
                            Icons.restaurant_menu,
                            color: BuyandByeAppTheme.orangeMiFonce,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: BuyandByeAppTheme.white,
                automaticallyImplyLeading: false,
                elevation: 0.0,
                bottomOpacity: 0.0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: BuyandByeAppTheme.orange,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            body: ListView(
              children: [
              ],
            ),
          );
        });
  }
}
