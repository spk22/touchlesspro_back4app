import 'package:flutter/foundation.dart';

enum ServiceType { office, library, exam }

class ServicePoint {
  final String adminId;
  final String name;
  final ServiceType serviceType;
  List<String> userIds;
  bool hasImage = false;

  ServicePoint(
      {@required this.adminId,
      @required this.name,
      @required this.serviceType,
      this.hasImage});

  ServicePoint.withUserIds(
      this.adminId, this.name, this.serviceType, this.hasImage, this.userIds);
}
