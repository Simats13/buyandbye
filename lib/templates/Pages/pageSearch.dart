import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oficihome/json/menu_json.dart';
import 'package:oficihome/theme/styles.dart';

class PageSearch extends StatefulWidget {
  @override
  _PageSearchState createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  int activeMenu = 0;
  Widget getBody() {
    return Container(
      color: Colors.white30,
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(categories.length, (index) {
          return Column(
            children: [
              SizedBox(
                height: 20,
                width: 20,
              ),
              SvgPicture.asset(
                categories[index]['img'],
                width: 40,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                categories[index]['name'],
                style: customContent,
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }
}
