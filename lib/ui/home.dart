import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/constants/routing_constants.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/ui/round_button.dart';
import 'package:touchlesspro_back4app/ui/services_list.dart';

class HomePage extends StatefulWidget {
  static final id = 'home';
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
//            color: Colors.white,
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(RoutingConstants.startup);
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        childAspectRatio: 0.8,
        children: <Widget>[
          _buildButton(context, Icon(Icons.work), 'Office'),
          _buildButton(context, Icon(Icons.local_library), 'Library'),
          _buildButton(context, Icon(Icons.assignment), 'Exam'),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, Widget icon, String label) {
    return RoundButton(
      icon: icon,
      label: label,
      size: 60.0,
      onPressed: () {
        // go to service list page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ServicesList(serviceType: _labelToType[label]),
          ),
        );
      },
    );
  }

  Map<String, ServiceType> _labelToType = {
    'Office': ServiceType.office,
    'Library': ServiceType.library,
    'Exam': ServiceType.exam,
  };
}
