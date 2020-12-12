import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/user_state.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/library_entrance.dart';
import 'package:touchlesspro_back4app/ui/library_home.dart';
import 'package:touchlesspro_back4app/ui/library_user_form.dart';
import 'package:touchlesspro_back4app/ui/otp_widget.dart';
import 'package:flutter_otp/flutter_otp.dart';

class LibraryService extends StatefulWidget {
  final ServicePoint servicePoint;
  LibraryService({Key key, this.servicePoint}) : super(key: key);

  @override
  _LibraryServiceState createState() => _LibraryServiceState();
}

class _LibraryServiceState extends State<LibraryService> {
  bool toggleOTP;
  FlutterOtp otp;
  String inputOtp;
  GlobalKey<FormState> _preKey = GlobalKey<FormState>();
  GlobalKey<FormState> _postKey = GlobalKey<FormState>();
  Map<String, String> _authObject = Map<String, String>();

  Widget get _buildPhoneNumberField {
    String initialCountry = 'IN';
    return IntlPhoneField(
      initialCountryCode: initialCountry,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        focusColor: Colors.teal,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),
      onChanged: (phone) {
        print(phone.completeNumber);
      },
      dropDownArrowColor: Colors.teal,
      onSaved: (phone) {
        _authObject['number'] = phone.number;
        _authObject['countryCode'] = phone.countryCode;
        _authObject['countryISOCode'] = phone.countryISOCode;
        _authObject['completeNumber'] = phone.completeNumber;
        _authObject['FormFilled'] = 'no';
        _authObject['OTPVerified'] = 'no';
        _authObject['AdminApproved'] = 'no';
      },
    );
  }

  Widget get _preSend {
    return Form(
      key: _preKey,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildPhoneNumberField,
            SizedBox(height: 30.0),
            RaisedButton(
              onPressed: _getOTP,
              child: const Text('Get OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postSend(BuildContext context) {
    return Form(
      key: _postKey,
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

  @override
  void initState() {
    super.initState();
    toggleOTP = false;
    otp = FlutterOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            onStretchTrigger: () {
              // Function callback for stretch
              return;
            },
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              title: Text(widget.servicePoint.name),
              centerTitle: true,
              background: Hero(
                tag: 'serviceImage',
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    (widget.servicePoint.imageUrl != null)
                        ? Image.network(
                            widget.servicePoint.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 100.0,
                            color: Colors.teal,
                          ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              <Widget>[
                // User Auth Form (mobile number registration through otp)
                SizedBox(height: 30.0),
                (!toggleOTP) ? _preSend : _postSend(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getOTP() {
    if (_preKey.currentState.validate()) {
      // commit the field values to their variables
      _preKey.currentState.save();
      print("""
                      The user has a phone number '${_authObject['number']}'
                      and countryCode '${_authObject['countryCode']}'
                    """);
      // send otp
      otp.sendOtp(_authObject['number']);
      setState(() {
        toggleOTP = true;
      });
    }
  }

  Future<void> _verifyOTP(BuildContext context) async {
    if (otp.resultChecker(int.parse(inputOtp))) {
      final auth = Provider.of<ParseAuthService>(context, listen: false);
      // save phone number to local db
      String boxName = await auth.getServiceId(widget.servicePoint);
      var box = await Hive.openBox(boxName);
      box.put('number', _authObject['number']);
      box.put('countryCode', _authObject['countryCode']);
      box.put('countryISOCode', _authObject['countryISOCode']);
      box.put('completeNumber', _authObject['completeNumber']);
      box.put('FormFilled', _authObject['FormFilled']);
      box.put('OTPVerified', 'yes');
      box.put('AdminApproved', _authObject['AdminApproved']);

      // check user state
      StateSelector selector =
          StateSelector(boxName: boxName, servicePoint: widget.servicePoint);
      UserState state = await selector.getState();

      // navigate
      switch (state) {
        case UserState.Unregistered:
          {
            // go to library service page for otp generation
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    LibraryService(servicePoint: widget.servicePoint),
              ),
            );
          }
          break;
        case UserState.OTPVerified:
          {
            // navigate to library Form page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChangeNotifierProvider<ValueNotifier<int>>(
                  create: (context) => ValueNotifier<int>(0),
                  child: LibraryUserForm(
                    servicePoint: widget.servicePoint,
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
                  servicePoint: widget.servicePoint,
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
                  servicePoint: widget.servicePoint,
                  authObject: selector.boxMap,
                  subscriber: selector.subscriber,
                ),
              ),
            );
          }
          break;
        default:
          {
            // navigate to library Form page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChangeNotifierProvider<ValueNotifier<int>>(
                  create: (context) => ValueNotifier<int>(0),
                  child: LibraryUserForm(
                    servicePoint: widget.servicePoint,
                    authObject: selector.boxMap,
                  ),
                ),
              ),
            );
          }
      }
    } else {
      print('Wrong OTP');
      Navigator.of(context).pop();
    }
  }
}
