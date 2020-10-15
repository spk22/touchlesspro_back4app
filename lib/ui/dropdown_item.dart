import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

class Item {
  Item(this.name, this.icon, this.serviceType);
  String name;
  Icon icon;
  ServiceType serviceType;
}

List<Item> serviceCategories = <Item>[
  Item('Office', Icon(Icons.work, color: Colors.teal), ServiceType.office),
  Item('Library', Icon(Icons.local_library, color: Colors.teal),
      ServiceType.library),
  Item('Exam', Icon(Icons.assignment, color: Colors.teal), ServiceType.exam),
];
