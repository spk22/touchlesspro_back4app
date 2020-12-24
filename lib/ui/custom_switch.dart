import 'package:flutter/material.dart';

Map<String, bool> nameToState = {
  'closed': false,
  'open': true,
};

Map<bool, String> stateToName = {
  false: 'closed',
  true: 'open',
};

class CustomSwitch extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onAltered;
  CustomSwitch({Key key, this.initialName, this.onAltered}) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool isSwitched;

  @override
  void initState() {
    isSwitched ??= nameToState[widget.initialName];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isSwitched,
      onChanged: (value) {
        setState(() {
          isSwitched = value;
        });
        widget.onAltered(stateToName[value]);
      },
      activeColor: Colors.teal.shade800,
      activeTrackColor: Colors.tealAccent,
    );
  }
}
