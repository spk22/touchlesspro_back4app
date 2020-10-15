import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/constants/routing_constants.dart';
import 'package:touchlesspro_back4app/ui/dropdown_item.dart';
import 'package:touchlesspro_back4app/ui/row_with_card.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String uid;
  List<String> labels = ['office', 'library'];
  List<String> names = ['3R Infotech Pvt Ltd', 'Brainshapers'];
  String serviceName;
  Item selectedItem;

  @override
  Widget build(BuildContext context) {
    uid = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () async {
              await _signOut(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          //TODO: read rowCount from the ServicePoint table of User
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            print(index);
            return RowWithCardWidget(
              index: index,
              label: labels[index],
              name: names[index],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _addDialog(context),
        tooltip: 'Add Service Point',
        child: Icon(
          Icons.library_add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleItemChange(Item newItem) {
    setState(() {
      selectedItem = newItem;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    final result = await auth.signOut(uid);
    if (result) {
      Navigator.of(context).pushReplacementNamed(RoutingConstants.startup);
      print('user with $uid, successfuly logged out!');
    }
  }

  Future<bool> _addDialog(BuildContext context) {
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Service Point',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, color: Colors.teal),
          ),
          content: Container(
            height: 125.0,
            width: 150.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    hintStyle: TextStyle(color: Colors.teal),
                    alignLabelWithHint: true,
                  ),
                  onChanged: (String value) {
                    serviceName = value;
                  },
                ),
                SizedBox(height: 5.0),
                TypeDropdown(saveItem: _handleItemChange),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedItem = null;
                  serviceName = null;
                });
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.teal),
              ),
            ),
            FlatButton(
              onPressed: () async {
                if (selectedItem != null && serviceName != null) {
                  print(
                      'uid: $uid name: $serviceName serviceType: ${selectedItem.serviceType.toString()}');
                  final servicePoint =
                      ServicePoint(uid, serviceName, selectedItem.serviceType);
                  await auth.createServicePoint(servicePoint);
                }
                Navigator.of(context).pop();
                setState(() {
                  selectedItem = null;
                  serviceName = null;
                });
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TypeDropdown extends StatefulWidget {
  final ValueChanged<Item> saveItem;
  TypeDropdown({Key key, this.saveItem}) : super(key: key);

  @override
  _TypeDropdownState createState() => _TypeDropdownState();
}

class _TypeDropdownState extends State<TypeDropdown> {
  List<DropdownMenuItem<Item>> dropdownMenuItems;
  Item selectedDropdownItem;

  @override
  void initState() {
    dropdownMenuItems = _buildDropdownMenuItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Item>(
      hint: Text(
        'Select Type',
        style: TextStyle(color: Colors.teal),
      ),
      value: selectedDropdownItem,
      onChanged: (Item value) {
        setState(() {
          selectedDropdownItem = value;
          widget.saveItem(selectedDropdownItem);
        });
      },
      items: dropdownMenuItems,
    );
  }

  List<DropdownMenuItem<Item>> _buildDropdownMenuItems() {
    return serviceCategories.map((Item category) {
      return DropdownMenuItem<Item>(
        value: category,
        child: Row(
          children: <Widget>[
            category.icon,
            SizedBox(width: 10.0),
            Text(
              category.name,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    }).toList();
  }
}
