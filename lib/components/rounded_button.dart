import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    required this.buttonColor,
    required this.onPress,
    required this.buttonTitle,
  }) : super(key: key);

  final Color buttonColor;
  final VoidCallback onPress;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            buttonTitle,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
