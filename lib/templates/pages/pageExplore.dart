import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PageExplore extends StatefulWidget {
  @override
  _PageExploreState createState() => _PageExploreState();
}

class _PageExploreState extends State<PageExplore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorer'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(43.834670, 4.359501),
          zoom: 15,
        ),
      ),
    );
  }
}
