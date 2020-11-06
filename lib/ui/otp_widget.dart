import 'package:flutter/material.dart';

enum OtpBorder { RECT, UNDERLINE }

class OtpWidget extends StatefulWidget {
  final int count;
  final double screenWidth;
  final ValueChanged<String> onComplete;
  OtpWidget({Key key, this.count, this.onComplete, this.screenWidth})
      : super(key: key);

  @override
  _OtpWidgetState createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  double kDimenNano = 4.0;
  double kDimenNormal = 8.0;
  double kDimenMedium = 16.0;
  double width = 20.0;
  List<FocusNode> _focusNodes;
  List<TextEditingController> _controllers;
  List<Widget> _fields;
  List<String> _pins;

  @override
  void initState() {
    _focusNodes = List<FocusNode>(widget.count);
    _controllers = List<TextEditingController>(widget.count);
    _pins = List.generate(widget.count, (int v) => '');
    _fields = List.generate(widget.count, (index) => _buildField(index));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = (widget.screenWidth / widget.count) + kDimenNormal;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: kDimenMedium),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _fields,
      ),
    );
  }

  Widget _buildField(int index) {
    double width = (widget.screenWidth / widget.count) - (kDimenNano * 2);
    if (_focusNodes[index] == null) _focusNodes[index] = FocusNode();

    if (_controllers[index] == null)
      _controllers[index] = TextEditingController();

    return Container(
      width: width,
      height: width * (width * 0.6),
      padding: EdgeInsets.symmetric(horizontal: kDimenNano),
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        focusNode: _focusNodes[index],
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(),
        ),
        onChanged: (String s) {
          if (s.isEmpty) {
            if (index == 0) return;
            _focusNodes[index].unfocus();
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {
            _pins[index] = s;
          });
          if (s.isNotEmpty) _focusNodes[index].unfocus();
          if (index + 1 != widget.count && s.isNotEmpty)
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          String currentPin = '';
          _pins.forEach((String value) {
            currentPin += value;
          });
          if (!_pins.contains(null) &&
              !_pins.contains('') &&
              currentPin.length == widget.count) {
            widget.onComplete(currentPin);
          }
          // widget.onChanged(currentPin);
        },
      ),
    );
  }
}
