import 'package:flutter/foundation.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';

enum ServiceType { office, library, exam }

class ServicePoint {
  String serviceId;
  final String adminId;
  final String name;
  final ServiceType serviceType;
  List<String> userIds;
  String imageUrl;

  ServicePoint(
      {this.serviceId,
      @required this.adminId,
      @required this.name,
      @required this.serviceType,
      this.imageUrl});

  ServicePoint.withUserIds(this.serviceId, this.adminId, this.name,
      this.serviceType, this.imageUrl, this.userIds);

  int estimateCost(int slot, int duration, SubscriptionPlan plan) {
    if (slot == null) {
      return 0;
    } else {
      String key = slotToString[slot] + durationToString[duration];
      var planMap = plan.toJson();
      return int.parse(planMap[key]);
    }
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
