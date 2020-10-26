import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

class Avatar extends StatelessWidget {
  final bool hasImage;
  final ServicePoint servicePoint;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback onPressed;

  const Avatar({
    Key key,
    @required this.servicePoint,
    @required this.radius,
    this.borderColor,
    this.borderWidth,
    this.onPressed,
    this.hasImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _borderDecoration(),
      child: InkWell(
        onTap: onPressed,
        child: _buildImage(context),
      ),
    );
  }

  Decoration _borderDecoration() {
    if (borderColor != null && borderWidth != null) {
      return BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      );
    }
    return null;
  }

  Widget _buildImage(BuildContext context) {
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    if (hasImage) {
      return FutureBuilder<ParseFileBase>(
        future: auth.getImage(servicePoint.adminId, servicePoint.name),
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot<ParseFileBase> snapshot) {
          if (snapshot.hasData) {
            // return Image.file((snapshot.data as ParseFile).file);
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.black12,
              backgroundImage: (hasImage)
                  ? FileImage((snapshot.data as ParseFile).file)
                  : null,
              child: (!hasImage) ? Icon(Icons.camera_alt, size: radius) : null,
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black12,
        backgroundImage: null,
        child: Icon(Icons.camera_alt, size: radius),
      );
    }
  }
}
