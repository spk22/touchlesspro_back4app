import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/ui/overlayable.dart';

import 'servicepoint_item.dart';

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
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             ServicePointItem(servicePoint: servicePoint)),
          //   );
          //   print('Tapped on Row $index');
          // },
          // onLongPress: () {
          //
          // },
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
                  _onEditItem();
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
                  _onDeleteItem();
                },
              ),
            ],
          ),
        );
      },
      onTap: () {
        _onViewItem(context);
      },
    );
  }

  void _onEditItem() {
    //TODO: Edit the servicePoint via dialog
    print('edit item: $index');
  }

  void _onDeleteItem() {
    //TODO: Delete the servicePoint via dialog
    print('delete item: $index');
  }

  void _onViewItem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ServicePointItem(servicePoint: servicePoint)),
    );
    print('Tapped on Row $index');
    // print('view item: $index');
  }
}
