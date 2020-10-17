import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

class RowWithCardWidget extends StatelessWidget {
  const RowWithCardWidget({
    Key key,
    @required this.index,
    @required this.servicePoint,
  }) : super(key: key);

  final int index;
  final ServicePoint servicePoint;

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
        //selected: true,
        onTap: () {
          print('Tapped on Row $index');
        },
      ),
    );
  }
}
