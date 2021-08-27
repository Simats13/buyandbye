import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Widgets/size_config.dart';
import 'package:buyandbye/templates/Pages/contentDecouverte.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return Scaffold(
      body: ContentDecouverte(),
    );
  }
}
