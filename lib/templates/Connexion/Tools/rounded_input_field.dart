import 'package:flutter/material.dart';
import 'package:oficihome/templates/Compte/constants.dart';

import 'package:oficihome/templates/widgets/constants.dart';

import 'package:oficihome/templates/Connexion/Tools/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key key, 
    this.hintText, 
    this.icon = Icons.person, 
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kLightPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}