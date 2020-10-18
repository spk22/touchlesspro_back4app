import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

//TODO: Use Dismissible to swipe-delete users in a servicePoint
class ServicePointItem extends StatelessWidget {
  final ServicePoint servicePoint;
  const ServicePointItem({Key key, this.servicePoint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
    );
  }
}
