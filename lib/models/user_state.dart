import 'package:hive/hive.dart';
import 'package:touchlesspro_back4app/models/phone_details.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

enum UserState { Unregistered, OTPVerified, FormFilled, AdminApproved }

class StateSelector {
  String boxName;
  ServicePoint servicePoint;
  Map<String, String> boxMap;
  Subscriber subscriber;
  StateSelector({this.boxName, this.servicePoint});

  Future<UserState> getState() async {
    UserState state;
    bool boxPresent = await Hive.boxExists(boxName);
    if (!boxPresent) {
      state = UserState.Unregistered;
    } else {
      var box = await Hive.openBox(boxName);
      // set boxMap
      boxMap = {
        'number': box.get('number'),
        'countryCode': box.get('countryCode'),
        'countryISOCode': box.get('countryISOCode'),
        'completeNumber': box.get('completeNumber'),
        'OTPVerified': box.get('OTPVerified'),
        'FormFilled': box.get('FormFilled'),
        'AdminApproved': box.get('AdminApproved'),
      };
      Status status = await ParseAuthService.statusFromBackend(
          servicePoint, boxMap['number']);
      if (status.isSubscribed == true)
        box.put('FormFilled', 'yes');
      else
        box.put('FormFilled', 'no');
      if (status.isApproved == true)
        box.put('AdminApproved', 'yes');
      else
        box.put('AdminApproved', 'no');
      if (status.subscriber != null) {
        // set Hive box with subscriber values, else ignore
        box.put('name', status.subscriber.name);
        box.put('preparingFor', status.subscriber.preparingFor);
        box.put('slot', status.subscriber.slot);
        box.put('planMonths', status.subscriber.planMonths);
        box.put('planFee', status.subscriber.planFee);
      }
      //
      String tokenForm = box.get('FormFilled');
      String tokenAdmin = box.get('AdminApproved');
      if (tokenForm == 'no' && tokenAdmin == 'no') {
        String token = box.get('OTPVerified');
        if (token == 'no')
          state = UserState.Unregistered;
        else
          state = UserState.OTPVerified;
      } else if (tokenForm == 'yes' && tokenAdmin == 'no') {
        state = UserState.FormFilled;
      } else {
        // set subscriber
        Map<String, String> phoneMap = {
          'number': box.get('number'),
          'countryCode': box.get('countryCode'),
        };
        PhoneDetails phone = PhoneDetails.fromJson(phoneMap);
        subscriber = Subscriber(
          name: box.get('name'),
          preparingFor: box.get('preparingFor'),
          slot: box.get('slot'),
          planMonths: box.get('planMonths'),
          planFee: box.get('planFee'),
          phone: phone,
        );
        state = UserState.AdminApproved;
      }
    }
    return state;
  }
}
