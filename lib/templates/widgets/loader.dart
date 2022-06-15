import "package:flutter/material.dart";
import 'dart:math';

class ColorLoader3 extends StatefulWidget {
  final double radius;
  final double dotRadius;

  const ColorLoader3({Key? key, this.radius = 30.0, this.dotRadius = 3.0}) : super(key: key);

  @override
  _ColorLoader3State createState() => _ColorLoader3State();
}

class _ColorLoader3State extends State<ColorLoader3>
    with SingleTickerProviderStateMixin {
  late Animation<double> animationRotation;
  late Animation<double> animationRadiusIn;
  late Animation<double> animationRadiusOut;
  late AnimationController controller;

  double? radius;
  double? dotRadius;

  @override
  void initState() {
    super.initState();

    radius = widget.radius;
    dotRadius = widget.dotRadius;

    controller = AnimationController(
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 3000),
        vsync: this);

    animationRotation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    animationRadiusIn = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.75, 1.0, curve: Curves.elasticIn),
      ),
    );

    animationRadiusOut = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.75 && controller.value <= 1.0) {
          radius = widget.radius * animationRadiusIn.value;
        } else if (controller.value >= 0.0 && controller.value <= 0.25) {
          radius = widget.radius * animationRadiusOut.value;
        }
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {}
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.0,
      height: 100.0,
      //color: Colors.black12,
      child: Center(
        child: RotationTransition(
          turns: animationRotation,
          child: Center(
            child: Stack(
              children: <Widget>[
                Transform.translate(
                  offset: const Offset(0.0, 0.0),
                  child: Dot(
                    radius: radius,
                    color: Colors.black12,
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.amber,
                  ),
                  offset: Offset(
                    radius! * cos(0.0),
                    radius! * sin(0.0),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.deepOrangeAccent,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 1 * pi / 4),
                    radius! * sin(0.0 + 1 * pi / 4),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.pinkAccent,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 2 * pi / 4),
                    radius! * sin(0.0 + 2 * pi / 4),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.purple,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 3 * pi / 4),
                    radius! * sin(0.0 + 3 * pi / 4),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.yellow,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 4 * pi / 4),
                    radius! * sin(0.0 + 4 * pi / 4),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.lightGreen,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 5 * pi / 4),
                    radius! * sin(0.0 + 5 * pi / 4),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.orangeAccent,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 6 * pi / 4),
                    radius! * sin(0.0 + 6 * pi / 4),
                  ),
                ),
                Transform.translate(
                  child: Dot(
                    radius: dotRadius,
                    color: Colors.blueAccent,
                  ),
                  offset: Offset(
                    radius! * cos(0.0 + 7 * pi / 4),
                    radius! * sin(0.0 + 7 * pi / 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color? color;

  const Dot({Key? key, this.radius, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
