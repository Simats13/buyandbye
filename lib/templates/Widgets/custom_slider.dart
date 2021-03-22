import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';
import 'package:oficihome/theme/colors.dart';

/*
 * for slider home page
 */
class CustomSliderWidget extends StatefulWidget {
  // final List<String> items;
  final List items;

  CustomSliderWidget({this.items});

  @override
  _CustomSliderWidgetState createState() => _CustomSliderWidgetState();
}

class _CustomSliderWidgetState extends State<CustomSliderWidget> {
  int activeIndex = 0;
  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider(
            options: CarouselOptions(
              enableInfiniteScroll: true,
              // autoPlayCurve: Curves.fastLinearToSlowEaseIn,
              // autoPlayAnimationDuration: Duration(seconds: 2),
              // autoPlay: true,
              viewportFraction: 1.0,
            ),
            items: widget.items.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: item,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          )),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
