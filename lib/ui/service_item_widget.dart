import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

class ServiceItem extends StatelessWidget {
  final int index;
  final ServicePoint servicePoint;
  final ValueChanged<BuildContext> onViewItem;
  const ServiceItem({Key key, this.index, this.servicePoint, this.onViewItem})
      : super(key: key);

  static const Map<ServiceType, IconData> _serviceIconData = {
    ServiceType.office: Icons.work,
    ServiceType.library: Icons.local_library,
    ServiceType.exam: Icons.assignment,
  };

  static const Map<ServiceType, String> _serviceLabels = {
    ServiceType.office: 'Office',
    ServiceType.library: 'Library',
    ServiceType.exam: 'Exam',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          _serviceIconData[servicePoint.serviceType],
          size: 48.0,
          color: Colors.teal,
        ),
        title: Text(servicePoint.name),
        subtitle: Text(_serviceLabels[servicePoint.serviceType]),
        trailing: Text(
          (servicePoint.userIds != null)
              ? '${servicePoint.userIds.length}'
              : '0',
          style: TextStyle(color: Colors.teal),
        ),
        onTap: () {
          onViewItem(context);
        },
      ),
      elevation: 2.0,
    );
  }
}
