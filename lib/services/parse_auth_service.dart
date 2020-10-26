import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/app_keys.dart';

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

  Future<bool> setImage(
      PickedFile selectedImage, String uid, String name) async {
    ParseFileBase parseFile = ParseFile(File(selectedImage.path));
    // get record from ServicePoints having adminId = uid & serviceName = name
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)..whereEqualTo('adminId', uid);
    final ParseResponse response = await queryBuilder.query();
    bool imageSuccess = false;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == name) {
          record.set('image', parseFile);
          final imageResponse = await record.save();
          imageSuccess = imageResponse.success;
        }
      }
    }
    return imageSuccess;
  }

  Future<ParseFileBase> getImage(String uid, String name) async {
    // get record from ServicePoints having adminId = uid & serviceName = name
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)..whereEqualTo('adminId', uid);
    final ParseResponse response = await queryBuilder.query();
    Future<ParseFileBase> result;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == name) {
          result = record.get<ParseFileBase>('image').download();
        }
      }
    }

    return result;
  }

  Future<String> getImageUrl(String uid, String name) async {
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)..whereEqualTo('adminId', uid);
    final ParseResponse response = await queryBuilder.query();
    String url;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == name) {
          url = record.get<ParseFileBase>('image').url;
        }
      }
    }
    return url;
  }

  Future<bool> hasImage(ServicePoint servicePoint) async {
    //
    final ParseObject serviceObject = ParseObject('ServicePoints');
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(serviceObject)
          ..whereEqualTo('adminId', servicePoint.adminId);
    final ParseResponse response = await queryBuilder.query();
    bool hasImage = false;
    if (response.success && response.count > 0) {
      for (ParseObject record in response.results) {
        String serviceName = record.get<String>('serviceName');
        if (serviceName == servicePoint.name) {
          var result = record.get<ParseFileBase>('image');
          print('hasImage: ' + (result != null).toString());
          hasImage = (result != null);
        }
      }
    }
    return hasImage;
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

  // returns username of the user added by admin
  // Future<String> addUser(ServicePoint servicePoint, String password) async {}

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
        var result = record.get<ParseFileBase>('image');
        bool hasImage = (result != null);
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
          hasImage,
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
        var result = record.get<ParseFileBase>('image');
        bool hasImage = (result != null);
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
          hasImage,
          userIds,
        ));
      }
    }
    return listOfServicePoints;
  }

  Future<void> addUser() async {}

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
