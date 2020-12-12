import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:touchlesspro_back4app/models/library_rules.dart';
import 'package:touchlesspro_back4app/models/phone_details.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/app_keys.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';

@immutable
class User {
  final String uid;
  const User({@required this.uid}) : assert(uid != null);
}

class ParseAuthService {
  // this method returns true if Parse Server is intialized & running healthy
  static Future<bool> initData() async {
    await Parse().initialize(
      AppKeys.APP_ID,
      AppKeys.APP_SERVER_URL,
      clientKey: AppKeys.APP_CLIENT_KEY,
      masterKey: AppKeys.APP_MASTER_KEY,
      autoSendSessionId: false,
      debug: false,
      coreStore: await CoreStoreSharedPrefsImp.getInstance(),
    );
    final ParseResponse parseResponse = await Parse().healthCheck();
    return parseResponse.success;
  }

  // Convert ParseUser into User
  User _userFromParse(ParseUser user) {
    return user == null ? null : User(uid: user.objectId);
  }

  // get User that is currently logged into server from your frontend/app
  Future<User> currentUser() async {
    ParseUser currentUser = await ParseUser.currentUser();
    return _userFromParse(currentUser);
  }

  // returns User after signing in
  Future<User> signIn(String userName, String password) async {
    final user = ParseUser(userName, password, userName);
    final response = await user.login();
    if (response.success) {
      // ParseUser currentUser = await ParseUser.currentUser();
      // bool isSame = (user.objectId == currentUser.objectId);
      // print('Is currentUser same as logined user: ' + isSame.toString());
      // print(currentUser.toString());
      return _userFromParse(user);
    } else {
      return null;
    }
  }

  // returns User that is signed up
  Future<User> signUp(String userName, String password) async {
    final user = ParseUser(userName, password, userName);
    final response = await user.signUp();
    if (response.success) {
      user.set<bool>('isAdmin', true);
      final apiResponse = await user.save();
      print('userSaved: ' + apiResponse.success.toString());
      return _userFromParse(user);
    } else {
      return null;
    }
  }

  Future<User> signUpUser(String userName, String password) async {
    final user = ParseUser(userName, password, null);
    final response = await user.signUp(allowWithoutEmail: true);
    if (response.success) {
      user.set<bool>('isAdmin', false);
      final apiResponse = await user.save();
      print('userSaved: ' + apiResponse.success.toString());
      return _userFromParse(user);
    } else {
      return null;
    }
  }

  // Get ParseUser from objectId aka uid
  Future<ParseUser> _parseUserFromUid(String uid) async {
    final response = await ParseUser.forQuery().getObject(uid);
    ParseUser parseUser = (response.success) ? response.results.first : null;
    return parseUser;
  }

  // returns true if user with given uid is logged out successfully
  Future<bool> signOut(String uid) async {
    ParseUser parseUser = await _parseUserFromUid(uid);
    ParseResponse response = await parseUser.logout();
    return response.success;
  }

  // sets the image of servicepoint having servicename = name and
  // returns the imageUrl
  Future<String> setImage(
      PickedFile selectedImage, String uid, String name) async {
    ParseFileBase parseFile = ParseFile(File(selectedImage.path));
    // get record from ServicePoints having adminId = uid & serviceName = name
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', uid)
          ..whereEqualTo('serviceName', name);
    final ParseResponse response = await queryBuilder.query();
    String imageUrl;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        record.set('image', parseFile);
        final imageResponse = await record.save();
        if (imageResponse.success) {
          imageUrl = record.get<ParseFileBase>('image').url;
        }
      }
    }
    return imageUrl;
  }

  Future<void> createServicePoint(ServicePoint servicePoint) async {
    String tempName = servicePoint.name + servicePoint.adminId;
    String servicePointName = tempName.replaceAll(RegExp(' +'), '');
    final ParseObject newObject = ParseObject(servicePointName);
    await newObject.create();
    final ParseObject newServicePoint = ParseObject('ServicePoints');

    newServicePoint.set<String>('adminId', servicePoint.adminId);
    newServicePoint.set<String>('serviceName', servicePoint.name);
    newServicePoint.set<String>(
        'serviceType', _typeToLabel[servicePoint.serviceType]);
    newServicePoint.set<String>('serviceClass', servicePointName);
    var response = await newServicePoint.create();
    if (response.success) {
      await newObject.delete();
    }
  }

  Future<void> updateServiceName(
      ServicePoint newServicePoint, ServicePoint oldServicePoint) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', oldServicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == oldServicePoint.name) {
          record.set<String>('serviceName', newServicePoint.name);
          record.save();
        }
      }
    }
  }

  Future<void> deleteServiceFromList(ServicePoint servicePoint) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          final String className = record.get<String>('serviceClass');
          await ParseObject(className).delete();
          await record.delete();
        }
      }
    }
  }

  Future<String> getServiceId(ServicePoint servicePoint) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    String id;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          id = record.objectId;
        }
      }
    }
    return id;
  }

  static Future<List<ServicePoint>> getServiceList(String uid) async {
    List<ServicePoint> listOfServicePoints = <ServicePoint>[];
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)..whereEqualTo('adminId', uid);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        ServiceType serviceType =
            _labelToType[record.get<String>('serviceType')];
        String imageUrl;
        ParseFileBase parseFileBase = record.get<ParseFileBase>('image');
        if (parseFileBase != null) {
          imageUrl = parseFileBase.url;
        }
        List<String> userIds = <String>[];
        String className = record.get<String>('serviceClass');
        var apiResponse = await ParseObject(className).getAll();
        if (apiResponse.success && apiResponse.count > 0) {
          if (apiResponse.results != null) {
            for (ParseObject testObject in apiResponse.results) {
              String userId = testObject.get<String>('userId');
              if (userId != null) {
                userIds.add(userId);
              }
            }
          }
        }
        listOfServicePoints.add(ServicePoint.withUserIds(
          uid,
          serviceName,
          serviceType,
          imageUrl,
          userIds,
        ));
      }
    }
    return listOfServicePoints;
  }

  static Future<List<ServicePoint>> getAllServices(
      ServiceType serviceType) async {
    List<ServicePoint> listOfServicePoints = <ServicePoint>[];
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('serviceType', _typeToLabel[serviceType]);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        String uid = record.get<String>('adminId');
        String imageUrl;
        ParseFileBase parseFileBase = record.get<ParseFileBase>('image');
        if (parseFileBase != null) {
          imageUrl = parseFileBase.url;
        }
        List<String> userIds = <String>[];
        String className = record.get<String>('serviceClass');
        var apiResponse = await ParseObject(className).getAll();
        if (apiResponse.success && response.count > 0) {
          if (apiResponse.results != null) {
            for (ParseObject testObject in apiResponse.results) {
              String userId = testObject.get<String>('userId');
              if (userId != null) {
                userIds.add(userId);
              }
            }
          }
        }
        listOfServicePoints.add(ServicePoint.withUserIds(
          uid,
          serviceName,
          serviceType,
          imageUrl,
          userIds,
        ));
      }
    }
    return listOfServicePoints;
  }

  Future<void> saveSubscriptionPlan(
      ServicePoint servicePoint, String mapString) async {
    //
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          record.set<String>('plan', mapString);
          record.save();
        }
      }
    }
  }

  static Future<SubscriptionPlan> getSubscriptionPlan(
      ServicePoint servicePoint) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    SubscriptionPlan plan;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          String jsonString = record.get<String>('plan');
          plan = (jsonString != null) ? planFromJson(jsonString) : null;
        }
      }
    }
    return plan;
  }

  Future<void> saveLibraryRules(
      ServicePoint servicePoint, String mapString) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          record.set<String>('rules', mapString);
          record.save();
        }
      }
    }
  }

  static Future<LibraryRules> getLibraryRules(ServicePoint servicePoint) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    String jsonString;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String rules = record.get<String>('rules');
        if (rules != null) jsonString = rules;
      }
    }
    return rulesFromJson(jsonString);
  }

  static Future<Status> statusFromBackend(
      ServicePoint servicePoint, String number) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId)
          ..whereEqualTo('serviceName', servicePoint.name);
    final ParseResponse response = await queryBuilder.query();
    Status status = Status(false, false);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('serviceClass');
      final ParseObject classObject = ParseObject(serviceClassName);
      final QueryBuilder<ParseObject> phoneQueryBuilder =
          QueryBuilder<ParseObject>(classObject)
            ..whereEqualTo('number', number);
      final ParseResponse phoneResponse = await phoneQueryBuilder.query();
      if (phoneResponse.success && phoneResponse.count > 0) {
        ParseObject record = phoneResponse.results[0];
        status.isSubscribed = true;
        status.isApproved = record.get<bool>('paid');
        Map<String, String> phoneMap = {
          'number': record.get<String>('number'),
          'countryCode': record.get<String>('countryCode'),
        };
        PhoneDetails phone = PhoneDetails.fromJson(phoneMap);
        Subscriber subscriber = Subscriber.withUid(
          uid: record.objectId,
          name: record.get<String>('name'),
          preparingFor: record.get<String>('prep'),
          slot: record.get<int>('slot'),
          planMonths: record.get<int>('months'),
          planFee: record.get<int>('fee'),
          phone: phone,
          otp: record.get<int>('otp'),
        );
        status.subscriber = subscriber;
      }
    }
    return status;
  }

  static Future<bool> isSubscribed(
      String serviceClassName, String number) async {
    bool isSubscribed = false;
    final ParseObject classObject = ParseObject(serviceClassName);
    final QueryBuilder<ParseObject> phoneQueryBuilder =
        QueryBuilder<ParseObject>(classObject)..whereEqualTo('number', number);
    final ParseResponse phoneResponse = await phoneQueryBuilder.query();
    if (phoneResponse.success && phoneResponse.count > 0) {
      ParseObject record = phoneResponse.results[0];
      String phone = record.get<String>('number');
      if (phone == number) isSubscribed = true;
    }
    return isSubscribed;
  }

  Future<bool> addSubscriber(
      ServicePoint servicePoint, Subscriber subscriber) async {
    // int otp = 1000 + Random().nextInt(9999 - 1000);
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId)
          ..whereEqualTo('serviceName', servicePoint.name);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('serviceClass');
      bool subscriptionStatus =
          await isSubscribed(serviceClassName, subscriber.phone.number);
      if (subscriptionStatus) return false;
      final objectResponse = await ParseObject(serviceClassName).create();
      final ParseObject record = objectResponse.results[0];
      record.set<String>('name', subscriber.name);
      record.set<String>('prep', subscriber.preparingFor);
      record.set<int>('slot', subscriber.slot);
      record.set<int>('months', subscriber.planMonths);
      record.set<int>('fee', subscriber.planFee);
      record.set<bool>('paid', false);
      record.set<int>('otp', subscriber.otp);
      record.set<String>('countryCode', subscriber.phone.countryCode);
      record.set<String>('number', subscriber.phone.number);
      record.save();
    }
    return true;
  }

  static Future<SubscriberGroup> getSubscribers(
      ServicePoint servicePoint) async {
    List<Subscriber> paidList = [];
    List<Subscriber> unpaidList = [];
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId)
          ..whereEqualTo('serviceName', servicePoint.name);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('serviceClass');
      final ParseObject serviceObject = ParseObject(serviceClassName);
      var apiResponse = await serviceObject.getAll();
      if (apiResponse.success && apiResponse.count > 0) {
        if (apiResponse.results != null) {
          for (ParseObject record in apiResponse.results) {
            String uId = record.objectId;
            if (uId != null) {
              PhoneDetails phone = PhoneDetails.fromJson({
                'number': record.get<String>('number'),
                'countryCode': record.get<String>('countryCode'),
              });
              final subscriber = Subscriber.withUid(
                uid: record.objectId,
                name: record.get<String>('name'),
                preparingFor: record.get<String>('prep'),
                slot: record.get<int>('slot'),
                planMonths: record.get<int>('months'),
                planFee: record.get<int>('fee'),
                phone: phone,
                otp: record.get<int>('otp'),
              );
              (record.get<bool>('paid'))
                  ? paidList.add(subscriber)
                  : unpaidList.add(subscriber);
            }
          }
        }
      }
    }
    SubscriberGroup subscriberGroup = SubscriberGroup(
      paidSubscribers: paidList,
      unpaidSubscribers: unpaidList,
    );
    return subscriberGroup;
  }

  Future<void> approveSubscriber(
      ServicePoint servicePoint, Subscriber subscriber) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId)
          ..whereEqualTo('serviceName', servicePoint.name);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('serviceClass');
      final ParseObject classObject = ParseObject(serviceClassName);
      final QueryBuilder<ParseObject> phoneQueryBuilder =
          QueryBuilder<ParseObject>(classObject)
            ..whereEqualTo('number', subscriber.phone.number);
      final ParseResponse phoneResponse = await phoneQueryBuilder.query();
      if (phoneResponse.success && phoneResponse.count > 0) {
        ParseObject record = phoneResponse.results[0];
        record.set<bool>('paid', true);
        record.save();
        // set subscriber as record in User table
        await signUpUser(record.objectId, subscriber.otp.toString());
      }
    }
  }

  static Future<void> removeSubscriber(
      ServicePoint servicePoint, String uid) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId)
          ..whereEqualTo('serviceName', servicePoint.name);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('serviceClass');
      final apiResponse = await ParseObject(serviceClassName).getObject(uid);
      if (apiResponse.success && apiResponse.count > 0) {
        final ParseObject record = apiResponse.results[0];
        await record.delete();
      }
    }
    // remove user where username = uid
    final ParseObject parseObject = ParseObject('User');
    final QueryBuilder<ParseObject> userQueryBuilder =
        QueryBuilder<ParseObject>(parseObject)..whereEqualTo('username', uid);
    final ParseResponse userResponse = await userQueryBuilder.query();
    if (userResponse.success && userResponse.count > 0) {
      ParseObject record = userResponse.results[0];
      await record.delete();
    }
  }

  static const Map<String, ServiceType> _labelToType = {
    'office': ServiceType.office,
    'library': ServiceType.library,
    'exam': ServiceType.exam,
  };

  static const Map<ServiceType, String> _typeToLabel = {
    ServiceType.office: "office",
    ServiceType.library: "library",
    ServiceType.exam: "exam",
  };
}
