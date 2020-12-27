import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:touchlesspro_back4app/models/library_announcement.dart';
import 'package:touchlesspro_back4app/models/library_rules.dart';
import 'package:touchlesspro_back4app/models/library_timings.dart';
import 'package:touchlesspro_back4app/models/phone_details.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/app_keys.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/models/session_booking.dart';

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
      PickedFile selectedImage, ServicePoint servicePoint) async {
    ParseFileBase parseFile = ParseFile(File(selectedImage.path));
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    String imageUrl;
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      record.set('image', parseFile);
      final imageResponse = await record.save();
      if (imageResponse.success) {
        imageUrl = record.get<ParseFileBase>('image').url;
      }
    }
    return imageUrl;
  }

  Future<void> createServicePoint(ServicePoint servicePoint) async {
    final ParseObject newServicePoint = ParseObject('ServicePoints');
    await newServicePoint.create();
    // create subscriber class (table)
    String subscriberClassName = newServicePoint.objectId + 'Subscribers';
    final ParseObject subscriberObject = ParseObject(subscriberClassName);
    await subscriberObject.create();
    // create session class (table)
    String sessionClassName = newServicePoint.objectId + 'Sessions';
    final ParseObject sessionObject = ParseObject(sessionClassName);
    await sessionObject.create();
    // create feedback class (table)
    String feedbackClassName = newServicePoint.objectId + 'Feedbacks';
    final ParseObject feedbackObject = ParseObject(feedbackClassName);
    await feedbackObject.create();
    // create dues class (table)
    String duesClassName = newServicePoint.objectId + 'Dues';
    final ParseObject duesObject = ParseObject(duesClassName);
    await duesObject.create();

    newServicePoint.set<String>('adminId', servicePoint.adminId);
    newServicePoint.set<String>('serviceName', servicePoint.name);
    newServicePoint.set<String>(
        'serviceType', _typeToLabel[servicePoint.serviceType]);
    newServicePoint.set<String>('subscriberClass', subscriberClassName);
    newServicePoint.set<String>('sessionClass', sessionClassName);
    newServicePoint.set<String>('feedbackClass', feedbackClassName);
    newServicePoint.set('duesClass', duesClassName);
    newServicePoint.set<String>('plan', '');
    newServicePoint.set<String>('rules', '');
    newServicePoint.set<String>('timings', '');
    var response = await newServicePoint.save();
    if (response.success) {
      await subscriberObject.delete();
      await sessionObject.delete();
      await feedbackObject.delete();
      await duesObject.delete();
    }
  }

  Future<void> updateServiceName(
      ServicePoint servicePoint, String newName) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      record.set('serviceName', newName);
      record.save();
    }
  }

  Future<void> deleteServiceFromList(ServicePoint servicePoint) async {
    //TODO: store names of deleted classes in a separate class "Deleted"
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          final String className = record.get<String>('subscriberClass');
          await ParseObject(className).delete();
          await record.delete();
        }
      }
    }
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
        String className = record.get<String>('subscriberClass');
        var apiResponse = await ParseObject(className).getAll();
        if (apiResponse.success && apiResponse.count > 0) {
          if (apiResponse.results != null) {
            for (ParseObject testObject in apiResponse.results) {
              String userId = testObject.objectId;
              if (userId != null) {
                userIds.add(userId);
              }
            }
          }
        }
        listOfServicePoints.add(ServicePoint.withUserIds(
          record.objectId,
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
        String className = record.get<String>('subscriberClass');
        var apiResponse = await ParseObject(className).getAll();
        if (apiResponse.success && response.count > 0) {
          if (apiResponse.results != null) {
            for (ParseObject testObject in apiResponse.results) {
              String userId = testObject.objectId;
              if (userId != null) {
                userIds.add(userId);
              }
            }
          }
        }
        listOfServicePoints.add(ServicePoint.withUserIds(
          record.objectId,
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
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      record.set<String>('plan', mapString);
      record.save();
    }
  }

  static Future<SubscriptionPlan> getSubscriptionPlan(
      ServicePoint servicePoint) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    SubscriptionPlan plan;
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      String jsonString = record.get<String>('plan');
      plan = (jsonString != null) ? planFromJson(jsonString) : null;
    }
    return plan;
  }

  Future<void> saveLibraryRules(
      ServicePoint servicePoint, String mapString) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      record.set<String>('rules', mapString);
      record.save();
    }
  }

  static Future<LibraryRules> getLibraryRules(ServicePoint servicePoint) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    LibraryRules rules;
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      String jsonString = record.get<String>('rules');
      rules = (jsonString != null) ? rulesFromJson(jsonString) : null;
    }
    return rules;
  }

  Future<void> saveLibraryTimings(
      ServicePoint servicePoint, String mapString) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      record.set('timings', mapString);
      record.save();
    }
  }

  static Future<LibraryTimings> getLibraryTimings(
      ServicePoint servicePoint) async {
    LibraryTimings timings;
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      String jsonString = record.get<String>('timings');
      timings = (jsonString != null) ? timingsFromJson(jsonString) : null;
    }
    return timings;
  }

  static Future<Status> statusFromBackend(
      ServicePoint servicePoint, String number) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    Status status = Status(false, false);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String subscriberClassName = parseObject.get<String>('subscriberClass');
      final ParseObject classObject = ParseObject(subscriberClassName);
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
          approvedAt: record.get<DateTime>('approvedAt'),
        );
        subscriber.extension = (record.containsKey('extendedBy'))
            ? record.get<int>('extendedBy')
            : 0;
        if (record.containsKey('sessionStatus'))
          subscriber.sessionStatus =
              nameToStatus[record.get<String>('sessionStatus')];
        if (record.containsKey('token'))
          subscriber.token = record.get<String>('token');
        status.subscriber = subscriber;
      }
    }
    return status;
  }

  static Future<bool> isSubscribed(
      String subscriberClassName, String number) async {
    bool isSubscribed = false;
    final ParseObject classObject = ParseObject(subscriberClassName);
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
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String subscriberClassName = parseObject.get<String>('subscriberClass');
      bool subscriptionStatus =
          await isSubscribed(subscriberClassName, subscriber.phone.number);
      if (subscriptionStatus) return false;
      final objectResponse = await ParseObject(subscriberClassName).create();
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
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String subscriberClassName = parseObject.get<String>('subscriberClass');
      final ParseObject serviceObject = ParseObject(subscriberClassName);
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
                approvedAt: record.get<DateTime>('approvedAt'),
              );
              if (record.containsKey('extendedBy'))
                subscriber.extension = record.get<int>('extendedBy');
              if (record.containsKey('sessionStatus'))
                subscriber.sessionStatus =
                    nameToStatus[record.get<String>('sessionStatus')];
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
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String subscriberClassName = parseObject.get<String>('subscriberClass');
      final ParseObject classObject = ParseObject(subscriberClassName);
      final QueryBuilder<ParseObject> phoneQueryBuilder =
          QueryBuilder<ParseObject>(classObject)
            ..whereEqualTo('number', subscriber.phone.number);
      final ParseResponse phoneResponse = await phoneQueryBuilder.query();
      if (phoneResponse.success && phoneResponse.count > 0) {
        ParseObject record = phoneResponse.results[0];
        record.set<bool>('paid', true);
        record.set<DateTime>('approvedAt', subscriber.approvedAt);
        record.set<int>('extendedBy', subscriber.extension);
        record.set<String>(
            'sessionStatus', statusToName[subscriber.sessionStatus]);
        // record.set<String>('token', 'abc');
        record.save();
        // set subscriber as record in User table
        await signUpUser(record.objectId, subscriber.otp.toString());
      }
    }
  }

  static Future<void> removeSubscriber(
      ServicePoint servicePoint, String uid) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('subscriberClass');
      final apiResponse = await ParseObject(serviceClassName).getObject(uid);
      if (apiResponse.success && apiResponse.count > 0) {
        final ParseObject record = apiResponse.results[0];
        await record.delete();
      }
    }
    // Remove user where username = uid, through code
    final ParseObject parseObject = ParseObject('User');
    final QueryBuilder<ParseObject> userQueryBuilder =
        QueryBuilder<ParseObject>(parseObject)..whereEqualTo('username', uid);
    final ParseResponse userResponse = await userQueryBuilder.query();
    if (userResponse.success && userResponse.count > 0) {
      ParseObject record = userResponse.results[0];
      await record.delete();
    }
  }

  Future<void> incrementDaysBy(
      int increment, ServicePoint servicePoint, Subscriber subscriber) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('subscriberClass');
      final ParseObject classObject = ParseObject(serviceClassName);
      final QueryBuilder<ParseObject> phoneQueryBuilder =
          QueryBuilder<ParseObject>(classObject)
            ..whereEqualTo('number', subscriber.phone.number);
      final ParseResponse phoneResponse = await phoneQueryBuilder.query();
      if (phoneResponse.success && phoneResponse.count > 0) {
        ParseObject record = phoneResponse.results[0];
        if (record.containsKey('extendedBy')) {
          record.setIncrement('extendedBy', increment);
          await record.save();
        }
      }
    }
  }

  static Future<String> getQRCode(ServicePoint servicePoint) async {
    String result;
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String sessionClassName = parseObject.get<String>('sessionClass');
      final ParseObject classObject = ParseObject(sessionClassName);
      final objectResponse = await classObject.create();
      if (objectResponse.success) {
        final ParseObject record = objectResponse.results[0];
        result = record.objectId;
        record.set<bool>('isBooked', false);
        await record.save();
      }
    }
    return result;
  }

  Future<SessionBooking> startBooking(ServicePoint servicePoint,
      Subscriber subscriber, SessionBooking booking) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String sessionClassName = parseObject.get<String>('sessionClass');
      final ParseObject sessionClass = ParseObject(sessionClassName);
      final classResponse = await sessionClass.getObject(booking.token);
      if (classResponse.success && classResponse.count > 0) {
        final ParseObject record = classResponse.results[0];
        record.set<bool>('isBooked', true);
        record.set<DateTime>('bookedAt', booking.timing);
        record.set<int>('extension', booking.extension);
        final bookedResponse = await record.save();
        booking.success = bookedResponse.success;
        if (bookedResponse.success) {
          // set token and sessionStatus of subscriber
          String serviceClassName = parseObject.get<String>('subscriberClass');
          final serviceResponse =
              await ParseObject(serviceClassName).getObject(subscriber.uid);
          final ParseObject newRecord = serviceResponse.results[0];
          newRecord.set<String>('token', booking.token);
          newRecord.set<String>('sessionStatus', statusToName[booking.status]);
          await newRecord.save();
        }
      }
      // unbooked records will be deleted from admin side
    }
    return booking;
  }

  static Future<SessionBooking> getSessionBooking(
      ServicePoint servicePoint, String token) async {
    SessionBooking booking;
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String sessionClassName = parseObject.get<String>('sessionClass');
      final ParseObject sessionClass = ParseObject(sessionClassName);
      final classResponse = await sessionClass.getObject(token);
      if (classResponse.success && classResponse.count > 0) {
        final ParseObject record = classResponse.results[0];
        DateTime timing = record.get<DateTime>('bookedAt');
        SessionStatus status = SessionStatus.inside;
        int extensions = record.get<int>('extension');
        booking = SessionBooking(
          token: token,
          timing: timing,
          status: status,
          extension: extensions,
        );
        booking.success = true;
      }
    }
    return booking;
  }

  Future<SessionBooking> endBooking(ServicePoint servicePoint,
      Subscriber subscriber, SessionBooking booking) async {
    booking.success = false;
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String serviceClassName = parseObject.get<String>('subscriberClass');
      final apiResponse =
          await ParseObject(serviceClassName).getObject(subscriber.uid);
      final ParseObject record = apiResponse.results[0];
      String token = record.get<String>('token');
      String sessionClassName = parseObject.get<String>('sessionClass');
      final ParseObject sessionClass = ParseObject(sessionClassName);
      final classResponse = await sessionClass.getObject(token);
      if (classResponse.success && classResponse.count > 0) {
        final ParseObject sessionRecord = classResponse.results[0];
        sessionRecord.set<DateTime>('endedAt', booking.timing);
        record.set<String>('sessionStatus', statusToName[booking.status]);
        await record.save();
        final endResponse = await sessionRecord.save();
        booking.success = endResponse.success;
      }
    }
    return booking;
  }

  static Future<void> deleteUnbookedSessions(ServicePoint servicePoint) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      ParseObject parseObject = response.results[0];
      String sessionClassName = parseObject.get<String>('sessionClass');
      final ParseObject sessionClass = ParseObject(sessionClassName);
      final QueryBuilder<ParseObject> myQueryBuilder =
          QueryBuilder<ParseObject>(sessionClass)
            ..whereNotEqualTo('isBooked', true);
      final ParseResponse apiResponse = await myQueryBuilder.query();
      if (apiResponse.success && apiResponse.count > 0) {
        // iterate over all unbooked sessions (records)
        if (apiResponse.results != null) {
          for (ParseObject record in apiResponse.results) {
            await record.delete();
          }
        }
      }
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

  Future<void> saveLibraryAnnouncement(
      ServicePoint servicePoint, String mapString) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      record.set('announcement', mapString);
      record.save();
    }
  }

  static Future<LibraryAnnouncement> getLibraryAnnouncement(
      ServicePoint servicePoint) async {
    final ParseResponse response =
        await ParseObject('ServicePoints').getObject(servicePoint.serviceId);
    LibraryAnnouncement announcement;
    if (response.success && response.count > 0) {
      final ParseObject record = response.results[0];
      String jsonString = record.get<String>('announcement');
      announcement =
          (jsonString != null) ? announcementFromJson(jsonString) : null;
    }
    return announcement;
  }
}
