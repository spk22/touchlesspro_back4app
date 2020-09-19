import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/admin_auth.dart';
import 'ui/home.dart';
import 'ui/startup.dart';

void main() {
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
    super.initState();
    _profile = _prefs
        .then((SharedPreferences prefs) => (prefs.getString('profile')) ?? '');
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
            return MaterialApp(
              initialRoute: _getProfileBasedRoute(snapshot.data),
              routes: {
                StartupPage.id: (context) =>
                    StartupPage(saveProfile: _handleProfileChange),
                AdminAuthPage.loginId: (context) =>
                    AdminAuthPage(authType: AuthType.login),
                HomePage.id: (context) => HomePage(),
                AdminAuthPage.registerId: (context) =>
                    AdminAuthPage(authType: AuthType.register),
              },
            );
        }
      },
    );
  }

  String _getProfileBasedRoute(String currentProfile) {
    // print(currentProfile);
    if (currentProfile != null) {
      if (currentProfile == 'admin')
        return AdminAuthPage.loginId;
      else
        return HomePage.id;
    } else {
      return StartupPage.id;
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
