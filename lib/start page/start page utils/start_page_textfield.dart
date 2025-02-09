import 'package:flutter/material.dart';
import 'package:learn_n/components/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Color> getSelectedColor() async {
  final prefs = await SharedPreferences.getInstance();
  final colorString = prefs.getString('selectedColor') ?? rgbToHex(Colors.blue);
  return hexToColor(colorString);
}

Widget buildRetroTextField(
  String label, {
  bool isPassword = false,
  required TextEditingController controller,
  String? Function(String?)? validator,
  FocusNode? focusNode,
  void Function(String)? onFieldSubmitted,
}) {
  return FutureBuilder<Color>(
    future: getSelectedColor(),
    builder: (context, snapshot) {
      final selectedColor = snapshot.data ?? Colors.blue;
      return TextFormField(
        controller: controller,
        obscureText: isPassword,
        cursorColor: Colors.black,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(
          fontFamily: 'Arial',
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'PressStart2P',
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          filled: true,
          fillColor: selectedColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: selectedColor,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
        ),
        validator: validator,
      );
    },
  );
}
