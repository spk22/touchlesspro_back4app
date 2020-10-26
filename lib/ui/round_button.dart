import 'package:flutter/material.dart';

class RoundButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final double size;
  final VoidCallback onPressed;

  RoundButton(
      {Key key,
      @required this.icon,
      @required this.label,
      @required this.size,
      @required this.onPressed})
      : super(key: key);

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: FittedBox(
              child: FloatingActionButton(
                heroTag: widget.label.substring(1),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                child: widget.icon,
                onPressed: () {
                  widget.onPressed();
                },
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.teal),
          )
        ],
      ),
    );
  }
}
