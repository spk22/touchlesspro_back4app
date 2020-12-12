import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/library_rules.dart';
import 'package:touchlesspro_back4app/models/phone_details.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/library_entrance.dart';
import 'package:touchlesspro_back4app/ui/library_service.dart';

class Checkout extends StatelessWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  final int fee;
  final Map<String, dynamic> formMap;
  Checkout(
      {Key key, this.servicePoint, this.authObject, this.fee, this.formMap})
      : super(key: key);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String rules;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Your Plan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.teal,
                      child: Column(
                        children: <Widget>[
                          Text(
                            '\u{20B9} $fee',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${formMap['slot']} hours/day for ${durationMap[formMap['duration']]} months',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Library Rules:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              FutureBuilder<LibraryRules>(
                future: ParseAuthService.getLibraryRules(servicePoint),
                builder: (BuildContext context,
                    AsyncSnapshot<LibraryRules> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasData) {
                      Map<String, dynamic> _map = snapshot.data.toJson();
                      rules = (_map != null) ? _map['rules'] : '';
                    } else {
                      rules = '';
                    }
                    return Text(
                      rules,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 40.0),
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: RaisedButton(
              //     padding: const EdgeInsets.all(16.0),
              //     elevation: 2.0,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16.0),
              //     ),
              //     color: Colors.teal,
              //     onPressed: () {},
              //     child: const Text(
              //       'Pay Online',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 14.0,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 10.0),
              _payButton(context),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                          text: 'To change number, ',
                        ),
                        TextSpan(
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                          ),
                          text: 'Click Here',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // go to library service page for otp generation
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LibraryService(
                                      servicePoint: servicePoint),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _payButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RaisedButton(
        padding: const EdgeInsets.all(16.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.teal,
        onPressed: () async {
          // add subscriber as a new row to servicepoint
          Map<String, String> phoneMap = {
            'number': authObject['number'],
            'countryCode': authObject['countryCode'],
          };
          PhoneDetails phone = PhoneDetails.fromJson(phoneMap);
          int otp = 1000 + Random().nextInt(9999 - 1000);
          print('otp: ' + otp.toString());
          Subscriber subscriber = Subscriber(
            name: formMap['name'],
            preparingFor: formMap['prep'],
            slot: formMap['slot'],
            planMonths: durationMap[formMap['duration']],
            planFee: fee,
            phone: phone,
          );
          subscriber.otp = otp;
          final auth = Provider.of<ParseAuthService>(context, listen: false);
          bool success = await auth.addSubscriber(servicePoint, subscriber);
          // save configuration to local DB (Hive)
          String boxName = await auth.getServiceId(servicePoint);
          var box = await Hive.openBox(boxName);

          if (!success) {
            box.put('FormFilled', 'no');
            // snackbar
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                    'Account with phone ${phone.number} is already submitted & pending for approval!'),
              ),
            );
          } else {
            box.put('FormFilled', 'yes');
            box.put('name', subscriber.name);
            box.put('preparingFor', subscriber.preparingFor);
            box.put('slot', subscriber.slot);
            box.put('planMonths', subscriber.planMonths);
            box.put('planFee', subscriber.planFee);
            // navigate
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LibraryEntrance(
                  servicePoint: servicePoint,
                  authObject: authObject,
                  subscriber: subscriber,
                ),
              ),
            );
          }
        },
        child: const Text(
          'Pay Admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
