import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

class RegenerativeQRImage extends StatefulWidget {
  final int periodInSeconds;
  final ServicePoint servicePoint;
  RegenerativeQRImage({Key key, this.periodInSeconds, this.servicePoint})
      : super(key: key);

  @override
  _RegenerativeQRImageState createState() => _RegenerativeQRImageState();
}

class _RegenerativeQRImageState extends State<RegenerativeQRImage> {
  Stream<String> qrCodeStream() async* {
    while (true) {
      String codeReceived =
          await ParseAuthService.getQRCode(widget.servicePoint);
      yield codeReceived;
      await Future.delayed(Duration(seconds: widget.periodInSeconds));
    }
  }

  @override
  void dispose() async {
    await ParseAuthService.deleteUnbookedSessions(widget.servicePoint);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: qrCodeStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (!snapshot.hasData) {
            return Text(
              'Some Error',
              style: Theme.of(context).textTheme.headline4,
            );
          } else {
            print('qrCode = ${snapshot.data}');
            return QrImage(
              data: snapshot.data,
              embeddedImage: NetworkImage(widget.servicePoint.imageUrl),
            );
          }
        }
      },
    );
  }
}
