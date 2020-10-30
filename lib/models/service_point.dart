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
}
