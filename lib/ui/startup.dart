import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/constants/routing_constants.dart';

class StartupPage extends StatelessWidget {
  static final id = 'startup';
  final ValueChanged<String> saveProfile;
  const StartupPage({Key key, @required this.saveProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration:
            BoxDecoration(color: const Color.fromRGBO(128, 166, 159, 1.0)),
        child: Center(
          child: OrientationLayoutWidget(saveProfile: saveProfile),
        ),
      ),
    );
  }
}

class OrientationLayoutWidget extends StatelessWidget {
  final ValueChanged<String> saveProfile;
  const OrientationLayoutWidget({Key key, @required this.saveProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Orientation _orientation = MediaQuery.of(context).orientation;
    switch (_orientation) {
      case Orientation.portrait:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Hero(
                tag: 'logoAnimation',
                child: Image.asset(
                  'images/logo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                'Choose your Role:',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(
                height: 45.0,
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    saveProfile('admin');
                    Navigator.pushNamed(
                      context,
                      RoutingConstants.adminLogin,
                      arguments: 'admin',
                    );
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'Admin',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(
                height: 45.0,
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    saveProfile('user');
                    Navigator.pushNamed(
                      context,
                      RoutingConstants.home,
                      arguments: 'user',
                    );
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'User',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ],
          ),
        );
      case Orientation.landscape:
        return Row(
          children: <Widget>[
            Expanded(
              child: Hero(
                tag: 'logoAnimation',
                child: Image.asset(
                  'images/logo.png',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.white.withOpacity(0.4),
              width: 2.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Choose your Role:',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(
                      height: 35.0,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          saveProfile('admin');
                          Navigator.pushNamed(
                            context,
                            RoutingConstants.adminLogin,
                            arguments: 'admin',
                          );
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35.0,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          saveProfile('user');
                          Navigator.pushNamed(
                            context,
                            RoutingConstants.home,
                            arguments: 'user',
                          );
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          'User',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
    return Container();
  }
}
