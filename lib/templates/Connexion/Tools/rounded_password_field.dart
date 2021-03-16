import 'package:flutter/material.dart';
import 'package:oficihome/templates/Compte/constants.dart';

import 'package:oficihome/templates/Connexion/Tools/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Votre mot de passe",
          icon: Icon(
            Icons.lock,
            color: kLightPrimaryColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: kLightPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
