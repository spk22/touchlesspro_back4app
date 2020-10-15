import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
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

  // returns User that is signed in
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

  Future<void> createServicePoint(ServicePoint servicePoint) {}
}
