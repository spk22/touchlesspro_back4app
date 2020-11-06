import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

class LibraryHome extends StatelessWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  const LibraryHome({Key key, this.servicePoint, this.authObject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'Library Home',
          style: TextStyle(decoration: TextDecoration.none),
        ),
      ),
    );
  }
}
