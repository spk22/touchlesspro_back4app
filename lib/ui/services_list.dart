import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/row_with_card.dart';

class ServicesList extends StatefulWidget {
  final ServiceType serviceType;
  const ServicesList({Key key, @required this.serviceType}) : super(key: key);

  @override
  _ServicesListState createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  List<ServicePoint> listOfServices;
  List<ServicePoint> savedList;

  @override
  void initState() {
    _getServiceList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              //TODO: Implement Search
            },
            icon: Icon(Icons.search),
          ),
        ],
        title: Text('Search Service'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        itemCount: (listOfServices != null) ? listOfServices.length : 0,
        itemBuilder: (BuildContext context, int index) {
          print(index);
          return RowWithCardWidget(
            index: index,
            servicePoint: listOfServices[index],
            onViewItem: (context) => _onViewItem(
              context,
              listOfServices[index],
              index,
            ),
          );
        },
      ),
    );
  }

  _onViewItem(BuildContext context, ServicePoint servicePoint, int index) {
    print('pressed ${servicePoint.name}');
  }

  Future<void> _getServiceList() async {
    savedList = await ParseAuthService.getAllServices(widget.serviceType);
    setState(() {
      listOfServices = savedList;
    });
  }
}
