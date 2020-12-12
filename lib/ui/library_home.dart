import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';

class LibraryHome extends StatelessWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  final Subscriber subscriber;
  const LibraryHome(
      {Key key, this.servicePoint, this.authObject, this.subscriber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.teal),
      drawer: UserMenu(
        servicePoint: servicePoint,
        subscriber: subscriber,
      ),
      body: Container(
        color: Colors.white,
        child: Center(child: Text('Hi ${subscriber.name}')),
      ),
    );
  }
}

class UserMenu extends StatefulWidget {
  final ServicePoint servicePoint;
  final Subscriber subscriber;
  UserMenu({Key key, this.servicePoint, this.subscriber}) : super(key: key);

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.teal[200],
              backgroundImage: null,
              child: Icon(
                Icons.camera_alt,
                size: 30.0,
                color: Colors.teal[800],
              ),
            ),
            accountName: Text(widget.subscriber.name),
            accountEmail: Text('(${widget.subscriber.phone.number})'),
          ),
        ],
      ),
    );
  }
}
