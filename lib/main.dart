import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchlesspro_back4app/constants/routing_constants.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

import 'ui/admin_auth.dart';
import 'ui/dashboard.dart';
import 'ui/home.dart';
import 'ui/startup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isServerRunning = await ParseAuthService.initData();
  print(isServerRunning.toString());
  runApp(StartupController());
}

class StartupController extends StatefulWidget {
  StartupController({Key key}) : super(key: key);

  @override
  _StartupControllerState createState() => _StartupControllerState();
}

// State of StartupController also manages profile of User
class _StartupControllerState extends State<StartupController> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _profile;

  @override
  void initState() {
    // initialize profile using stored value of prefs
    _profile = _prefs
        .then((SharedPreferences prefs) => (prefs.getString('profile')) ?? '');

    //TODO: Check internet connection

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _profile,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            return const CircularProgressIndicator();
            break;
          default:
            return MultiProvider(
              providers: [
                Provider<ParseAuthService>(
                  create: (_) => ParseAuthService(),
                ),
              ],
              child: MaterialApp(
                initialRoute: _getProfileBasedRoute(snapshot.data),
                routes: {
                  RoutingConstants.startup: (context) =>
                      StartupPage(saveProfile: _handleProfileChange),
                  RoutingConstants.adminLogin: (context) =>
                      AdminAuthPage(authType: AuthType.login),
                  RoutingConstants.home: (context) => HomePage(),
                  RoutingConstants.adminRegister: (context) =>
                      AdminAuthPage(authType: AuthType.register),
                  RoutingConstants.dashboard: (context) => Dashboard(),
                },
              ),
            );
        }
      },
    );
  }

  String _getProfileBasedRoute(String currentProfile) {
    // print(currentProfile);
    if (currentProfile != null) {
      if (currentProfile == 'admin')
        return RoutingConstants.adminLogin;
      else
        return RoutingConstants.home;
    } else {
      return RoutingConstants.startup;
    }
  }

  Future<void> _handleProfileChange(String newProfile) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _profile = prefs
          .setString('profile', newProfile)
          .then((bool success) => newProfile);
    });
  }
}
