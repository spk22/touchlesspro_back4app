import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/library_home.dart';
import 'package:touchlesspro_back4app/ui/library_service.dart';
import 'package:touchlesspro_back4app/ui/library_user_form.dart';
import 'package:touchlesspro_back4app/ui/service_item_widget.dart';

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
      body: RefreshIndicator(
        onRefresh: _getServiceList,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          itemCount: (listOfServices != null) ? listOfServices.length : 0,
          itemBuilder: (BuildContext context, int index) {
            print(index);
            return ServiceItem(
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
      ),
    );
  }

  Future<void> _onViewItem(
      BuildContext context, ServicePoint servicePoint, int index) async {
    print('pressed ${servicePoint.name}');
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    String boxName = await auth.getServiceId(servicePoint);
    bool boxPresent = await Hive.boxExists(boxName);
    if (boxPresent) {
      var box = await Hive.openBox(boxName);
      if (box.get('number') != null) {
        // Obtain values into map
        Map<String, String> boxMap = {
          'number': box.get('number'),
          'countryCode': box.get('countryCode'),
          'countryISOCode': box.get('countryISOCode'),
          'completeNumber': box.get('completeNumber'),
          'detailsFilled': box.get('detailsFilled'),
        };
        String token = box.get('detailsFilled');
        if (token == 'yes') {
          // navigate to library home page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LibraryHome(
                servicePoint: servicePoint,
                authObject: boxMap,
              ),
            ),
          );
        } else {
          // navigate to library user details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<ValueNotifier<int>>(
                create: (context) => ValueNotifier<int>(0),
                child: LibraryUserForm(
                  servicePoint: servicePoint,
                  authObject: boxMap,
                ),
              ),
            ),
          );
        }
      } else {
        // go to library service page for otp generation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LibraryService(servicePoint: servicePoint),
          ),
        );
      }
    } else {
      // go to library service page for otp generation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LibraryService(servicePoint: servicePoint),
        ),
      );
    }
  }

  Future<void> _getServiceList() async {
    savedList = await ParseAuthService.getAllServices(widget.serviceType);
    setState(() {
      listOfServices = savedList;
    });
  }
}
