import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/user_state.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/library_entrance.dart';
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
    String boxName = servicePoint.serviceId;
    //
    StateSelector selector =
        StateSelector(boxName: boxName, servicePoint: servicePoint);
    UserState state = await selector.getState();
    switch (state) {
      case UserState.Unregistered:
        {
          // go to library service page for otp generation
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LibraryService(servicePoint: servicePoint),
            ),
          );
        }
        break;
      case UserState.OTPVerified:
        {
          // navigate to library Form page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<ValueNotifier<int>>(
                create: (context) => ValueNotifier<int>(0),
                child: LibraryUserForm(
                  servicePoint: servicePoint,
                  authObject: selector.boxMap,
                ),
              ),
            ),
          );
        }
        break;
      case UserState.FormFilled:
        {
          // state waiting for approval from admin
          // go to library entrance page and enter otp given by admin
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LibraryEntrance(
                servicePoint: servicePoint,
                authObject: selector.boxMap,
                subscriber: selector.subscriber,
              ),
            ),
          );
        }
        break;
      case UserState.AdminApproved:
        {
          // navigate to library home page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LibraryHome(
                servicePoint: servicePoint,
                authObject: selector.boxMap,
                subscriber: selector.subscriber,
              ),
            ),
          );
        }
        break;
      default:
        {
          // go to library service page for otp generation
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LibraryService(servicePoint: servicePoint),
            ),
          );
        }
    }
    //
  }

  Future<void> _getServiceList() async {
    savedList = await ParseAuthService.getAllServices(widget.serviceType);
    setState(() {
      listOfServices = savedList;
    });
  }
}
