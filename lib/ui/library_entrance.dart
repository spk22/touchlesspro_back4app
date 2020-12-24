import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/session_booking.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/library_home.dart';
import 'package:touchlesspro_back4app/ui/otp_widget.dart';

class LibraryEntrance extends StatefulWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  final Subscriber subscriber;
  LibraryEntrance(
      {Key key, this.servicePoint, this.authObject, this.subscriber})
      : super(key: key);

  @override
  _LibraryEntranceState createState() => _LibraryEntranceState();
}

class _LibraryEntranceState extends State<LibraryEntrance> {
  String inputOtp;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _approvalView(context),
        ],
      ),
    );
  }

  Widget _approvalView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OtpWidget(
              count: 4,
              screenWidth: MediaQuery.of(context).size.width,
              onComplete: (value) {
                setState(() {
                  inputOtp = value;
                });
              },
            ),
            SizedBox(height: 30.0),
            RaisedButton(
              onPressed: () {
                _verifyOTP(context);
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOTP(BuildContext context) async {
    if (int.parse(inputOtp) == widget.subscriber.otp) {
      // set approvedAt time to subscriber
      widget.subscriber.approvedAt = DateTime.now();
      // set initial extension of days = 0
      widget.subscriber.extension = 0;
      // set sessionStatus of subscriber
      widget.subscriber.sessionStatus = SessionStatus.outside;
      // approve subscriber
      final auth = Provider.of<ParseAuthService>(context, listen: false);
      await auth.approveSubscriber(widget.servicePoint, widget.subscriber);

      // Navigate
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LibraryHome(
            servicePoint: widget.servicePoint,
            authObject: widget.authObject,
            subscriber: widget.subscriber,
          ),
        ),
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Entered number did not match with OTP!'),
        ),
      );
    }
  }
}
