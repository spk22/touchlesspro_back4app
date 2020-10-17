enum ServiceType { office, library, exam }

class ServicePoint {
  final String adminId;
  final String name;
  final ServiceType serviceType;
  List<String> userIds;

  ServicePoint(this.adminId, this.name, this.serviceType);

  ServicePoint.withUserIds(
      this.adminId, this.name, this.serviceType, this.userIds);
}
