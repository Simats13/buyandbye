import 'package:flutter/material.dart';

class PopupSlider extends StatefulWidget {
  final double sliderSize;
  const PopupSlider(this.sliderSize, {Key? key}) : super(key: key);

  @override
  _PopupSliderState createState() => _PopupSliderState();
}

class _PopupSliderState extends State<PopupSlider> {
  /// current selection of the slider
  double fontSize = 0.0;

  @override
  void initState() {
    super.initState();
    fontSize = widget.sliderSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Font Size'),
      content: Slider(
        value: fontSize,
        min: 10,
        max: 100,
        divisions: 9,
        onChanged: (value) {
          setState(() {
            fontSize = value;
          });
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Use the second argument of Navigator.pop(...) to pass
            // back a result to the page that opened the dialog
            Navigator.pop(context, fontSize);
          },
          child: const Text('DONE'),
        )
      ],
    );
  }
}
