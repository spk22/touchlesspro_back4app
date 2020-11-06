import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

class LibraryUserDetails extends StatefulWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  LibraryUserDetails({Key key, this.servicePoint, this.authObject})
      : super(key: key);

  @override
  _LibraryUserDetailsState createState() => _LibraryUserDetailsState();
}

class _LibraryUserDetailsState extends State<LibraryUserDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'UserDetails',
          style: TextStyle(decoration: TextDecoration.none),
        ),
      ),
    );
  }
}
