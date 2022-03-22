import 'package:flutter/material.dart';
import 'package:buyandbye/templates/Compte/constants.dart';

import 'package:buyandbye/templates/Connexion/Tools/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String? hintText;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  const RoundedInputField({
    Key? key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    String? email;
    return TextFieldContainer(
      child: TextFormField(
        // ignore: missing_return
        validator: (input) {
          if (input!.isEmpty) {
            return "Veuillez rentrer une adresse mail";
          }
          return null;
        },
        onChanged: onChanged,
        onSaved: (input) => email = input,
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
