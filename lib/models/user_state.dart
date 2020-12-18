import 'package:hive/hive.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

enum UserState { Unregistered, OTPVerified, FormFilled, AdminApproved }

class StateSelector {
  UserState state;
  String boxName;
  Box<dynamic> box;
  ServicePoint servicePoint;
  Map<String, String> boxMap;
  Subscriber subscriber;
  StateSelector({this.boxName, this.servicePoint});

  void _setBoxMap() {
    boxMap = {
      'number': box.get('number'),
      'countryCode': box.get('countryCode'),
      'countryISOCode': box.get('countryISOCode'),
      'completeNumber': box.get('completeNumber'),
      'OTPVerified': box.get('OTPVerified'),
      'FormFilled': box.get('FormFilled'),
      'AdminApproved': box.get('AdminApproved'),
    };
  }

  void _onSubscribedAction(Status status) {
    // set state to FormFilled
    state = UserState.FormFilled;
    // copy subscriber from backend
    subscriber = status.subscriber;
    // set values of other states
    box.put('FormFilled', 'yes');
    box.put('AdminApproved', 'no');
    // fill box with subscriber values from backend
    box.put('name', subscriber.name);
    box.put('preparingFor', subscriber.preparingFor);
    box.put('slot', subscriber.slot);
    box.put('planMonths', subscriber.planMonths);
    box.put('planFee', subscriber.planFee);
    box.put('number', subscriber.phone.number);
    box.put('countryCode', subscriber.phone.countryCode);
    _setBoxMap();
  }

  Future<UserState> getState() async {
    bool boxPresent = await Hive.boxExists(boxName);
    if (!boxPresent) {
      // user using app first time on this device
      state = UserState.Unregistered;
    } else {
      // when box is present
      state = UserState.OTPVerified;
      box = await Hive.openBox(boxName);
      box.put('OTPVerified', 'yes');
      // set boxMap
      _setBoxMap();
      Status status = await ParseAuthService.statusFromBackend(
          servicePoint, boxMap['number']);
      if (status.isSubscribed) {
        _onSubscribedAction(status);
        if (status.isApproved) {
          {
            state = UserState.AdminApproved;
            box.put('AdminApproved', 'yes');
            _setBoxMap();
          }
        }
        // in either case, the subscriber = status.subscriber
      } else {
        // not subscribed, but box present => form not filled yet
        String token = box.get('OTPVerified');
        if (token == 'no')
          state = UserState.Unregistered;
        else {
          state = UserState.OTPVerified;
          box.put('OTPVerified', 'yes');
          // reset boxMap here
          _setBoxMap();
        }
      }
    }
    return state;
  }
}
