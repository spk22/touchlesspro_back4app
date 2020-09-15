import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static final id = 'home';
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
