import 'package:flutter/material.dart';

class ToggleAuthWidget extends StatelessWidget {
  final String toggleText;
  final String richTextName;
  final String routeName;
  final Color richTextColor;
  const ToggleAuthWidget({
    Key key,
    this.toggleText,
    this.richTextName,
    this.richTextColor,
    this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.of(context).pushReplacementNamed(routeName);
      },
      child: SizedBox(
        height: 30.0,
        child: RichText(
          text: TextSpan(
            text: toggleText,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            //Theme.of(context).textTheme.headline6,
            children: <TextSpan>[
              TextSpan(
                text: richTextName,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: richTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
