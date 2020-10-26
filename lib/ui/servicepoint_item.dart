import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/image_picker_service.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/avatar.dart';

//TODO: Use Dismissible to swipe-delete users in a servicePoint
class ServicePointItem extends StatefulWidget {
  final ServicePoint servicePoint;
  const ServicePointItem({Key key, this.servicePoint}) : super(key: key);

  @override
  _ServicePointItemState createState() => _ServicePointItemState();
}

class _ServicePointItemState extends State<ServicePointItem> {
  bool imageSet;
  List<User> listOfUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Home'),
        bottom: PreferredSize(
          child: Column(
            children: <Widget>[
              _buildAdminInfo(context),
              SizedBox(
                height: 16.0,
              ),
            ],
          ),
          preferredSize: Size.fromHeight(130.0),
        ),
      ),
    );
  }

  Widget _buildAdminInfo(BuildContext context) {
    // set the uploaded image into user Avatar
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    return FutureBuilder<bool>(
      future: auth.hasImage(widget.servicePoint),
      // initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Avatar(
          hasImage: snapshot.data ?? false,
          servicePoint: widget.servicePoint,
          radius: 50.0,
          borderColor: Colors.black54,
          borderWidth: 2.0,
          onPressed: () => _chooseAvatar(context, widget.servicePoint.adminId),
        );
      },
    );
  }

  Future<void> _chooseAvatar(BuildContext context, String uid) async {
    try {
      // 1. Get image from picker
      // 2. Upload to storage
      // 3. Save url to backend
      // 4. (optional) delete local file as no longer needed
      final picker = Provider.of<ImagePickerService>(context, listen: false);
      final isUploaded =
          await picker.uploadParseImage(context, uid, widget.servicePoint.name);
      setState(() {
        imageSet = isUploaded;
      });
      print('upload response: $isUploaded');
    } catch (e) {
      print(e);
    }
  }
}
