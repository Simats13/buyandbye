import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:oficihome/templates/Compte/constants.dart';
import 'package:oficihome/templates/Compte/help.dart';
import 'package:oficihome/templates/Compte/user_history.dart';
import 'package:oficihome/templates/Compte/editProfile.dart';
import 'package:oficihome/templates/pages/pageBienvenue.dart';
import 'package:oficihome/services/auth.dart';
import 'package:oficihome/templates/widgets/profile_list_item.dart';
import 'package:oficihome/templates/oficihome_app_theme.dart';

void main() {
  runApp(PageCompte());
}

class PageCompte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: 896, width: 414, allowFontScaling: true);

    var profileInfo = Expanded(
      child: FutureBuilder(
          future: AuthMethods().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Container(
                    height: kSpacingUnit.w * 10,
                    width: kSpacingUnit.w * 10,
                    margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            snapshot.data.photoURL,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: kSpacingUnit.w * 2),
                  Text(
                    snapshot.data.displayName,
                    style: kTitleTextStyle,
                  ),
                  SizedBox(height: kSpacingUnit.w * 0.5),
                  Text(
                    snapshot.data.email,
                    style: kCaptionTextStyle,
                  ),
                  SizedBox(height: kSpacingUnit.w * 2),
                  Container(
                    height: kSpacingUnit.w * 4,
                    width: kSpacingUnit.w * 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
                      color: OficihomeAppTheme.orange,
                    ),
                    child: Center(
                      child: Text(
                        'Compte client',
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        SizedBox(width: ScreenUtil().setSp(kSpacingUnit.w * 3)),
        profileInfo,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(height: kSpacingUnit.w * 5),
            header,
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SizedBox(height: kSpacingUnit.w * 2),
                  ProfileListItem(
                      icon: LineAwesomeIcons.user_shield,
                      text: 'Mes informations',
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      }),
                  ProfileListItem(
                      icon: LineAwesomeIcons.history,
                      text: 'Historique d\'achat',
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return UserHistory();
                            },
                          ),
                        );
                      }),
                  ProfileListItem(
                      icon: LineAwesomeIcons.question_circle,
                      text: 'Aide / Support',
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Help();
                            },
                          ),
                        );
                      }),
                  ProfileListItem(
                      icon: LineAwesomeIcons.alternate_sign_out,
                      text: 'Se déconnecter',
                      press: () {
                        AuthMethods().signOut().then((s) {
                          AuthMethods.toogleNavBar();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PageBievenue()));
                        });
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
