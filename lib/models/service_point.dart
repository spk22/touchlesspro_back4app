import 'package:flutter/foundation.dart';

enum ServiceType { office, library, exam }

class ServicePoint {
  final String adminId;
  final String name;
  final ServiceType serviceType;
  List<String> userIds;
  String imageUrl;

  ServicePoint(
      {@required this.adminId,
      @required this.name,
      @required this.serviceType,
      this.imageUrl});

  ServicePoint.withUserIds(
      this.adminId, this.name, this.serviceType, this.imageUrl, this.userIds);

  int estimateCost(int slot, int duration) {
    String key = slotToString[slot] + durationToString[duration];
  }
}

Map<int, String> slotToString = {
  6: 'six',
  9: 'nine',
  12: 'twelve',
};

Map<int, String> durationToString = {
  1: 'one',
  3: 'three',
  6: 'six',
  12: 'twelve',
};
