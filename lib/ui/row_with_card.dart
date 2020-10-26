import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/ui/overlayable.dart';

class RowWithCardWidget extends StatelessWidget {
  const RowWithCardWidget({
    Key key,
    @required this.index,
    @required this.servicePoint,
    this.onEditItem,
    this.onViewItem,
    this.onDeleteItem,
  }) : super(key: key);

  final int index;
  final ServicePoint servicePoint;
  final ValueChanged<BuildContext> onEditItem;
  final ValueChanged<BuildContext> onViewItem;
  final ValueChanged<BuildContext> onDeleteItem;

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
    return OverlayableContainerOnLongPress(
      child: Card(
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
        ),
        elevation: 2.0,
      ),
      overlayContentBuilder:
          (BuildContext context, VoidCallback onHideOverlay) {
        return Container(
          height: double.infinity,
          color: Colors.black38,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  onHideOverlay();
                  onEditItem(context);
                },
              ),
              SizedBox(width: 10.0),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  onHideOverlay();
                  onDeleteItem(context);
                },
              ),
            ],
          ),
        );
      },
      onTap: () {
        onViewItem(context);
      },
    );
  }
}
