import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/image_picker_service.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

class ServiceUsersPage extends StatefulWidget {
  final ServicePoint servicePoint;
  final ValueChanged<bool> setImage;
  ServiceUsersPage({Key key, this.servicePoint, this.setImage})
      : super(key: key);

  @override
  _ServiceUsersPageState createState() => _ServiceUsersPageState();
}

class _ServiceUsersPageState extends State<ServiceUsersPage> {
  bool hasImage;

  @override
  void initState() {
    setState(() {
      hasImage = widget.servicePoint.hasImage;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.teal[200],
            stretch: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onLongPress: () {},
                onTap: () => _chooseCoverPic(context),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[_buildImage(context)],
                ),
              ),
              title: Text(widget.servicePoint.name),
              centerTitle: true,
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    if (hasImage) {
      return FutureBuilder<String>(
        future: auth.getImageUrl(
          widget.servicePoint.adminId,
          widget.servicePoint.name,
        ),
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Image.network(snapshot.data, fit: BoxFit.cover);
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else {
      return Icon(
        Icons.camera_alt,
        size: 80.0,
        color: Colors.teal,
      );
    }
  }

  Future<void> _chooseCoverPic(BuildContext context) async {
    final picker = Provider.of<ImagePickerService>(context, listen: false);
    final isUploaded = await picker.uploadParseImage(
      context,
      widget.servicePoint.adminId,
      widget.servicePoint.name,
    );
    setState(() {
      hasImage = isUploaded;
      if (isUploaded) {
        widget.setImage(hasImage);
      }
    });
    print('upload response: $isUploaded');
  }
}
