import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/image_picker_service.dart';

class ServiceUsersPage extends StatefulWidget {
  final ServicePoint servicePoint;
  final ValueChanged<String> setImage;
  ServiceUsersPage({Key key, this.servicePoint, this.setImage})
      : super(key: key);

  @override
  _ServiceUsersPageState createState() => _ServiceUsersPageState();
}

class _ServiceUsersPageState extends State<ServiceUsersPage> {
  String imageUrl;

  @override
  void initState() {
    setState(() {
      imageUrl = widget.servicePoint.imageUrl;
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
    if (imageUrl != null) {
      return Image.network(imageUrl, fit: BoxFit.cover);
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
    final url = await picker.uploadParseImage(
      context,
      widget.servicePoint.adminId,
      widget.servicePoint.name,
    );
    setState(() {
      imageUrl = url;
      if (url != null) {
        widget.setImage(imageUrl);
      }
    });
    print('upload response: $url');
  }
}
