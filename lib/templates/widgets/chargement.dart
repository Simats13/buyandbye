import 'package:flutter/material.dart';

class Chargement extends StatefulWidget {
  const Chargement({Key? key}) : super(key: key);

  @override
  _ChargementState createState() => _ChargementState();
}

class _ChargementState extends State<Chargement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 220),
        child: Center(
          child: Column(
            children: const [
              CircleAvatar(
                radius: 40.0,
                backgroundImage: AssetImage('assets/logo.jpg'),
              ),
              SizedBox(height: 20.0,),
              Padding(
                padding: EdgeInsets.only(left: 130,right: 130),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
      
    );
  }
}
