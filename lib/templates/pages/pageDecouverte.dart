import 'package:flutter/material.dart';
import 'package:oficihome/templates/Widgets/size_config.dart';
import 'package:oficihome/templates/Pages/contentDecouverte.dart';

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
