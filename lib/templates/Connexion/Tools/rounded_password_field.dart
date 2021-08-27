import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Compte/constants.dart';

import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    String _password;
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        // ignore: missing_return
        validator: (input) {
          if (input.isEmpty) {
            return "Veuillez rentrer une adresse mail";
          }
        },
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
        onSaved: (input) => _password = input,
      ),
    );
  }
}
