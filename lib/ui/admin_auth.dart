import 'package:flutter/material.dart';
import 'auth_form.dart';

enum AuthType { login, register }

class AdminAuthPage extends StatelessWidget {
  static final loginId = 'loginId';
  static final registerId = 'registerId';
  final AuthType authType;

  const AdminAuthPage({Key key, @required this.authType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(128, 166, 159, 1.0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'logoAnimation',
                  child: Image.asset(
                    'images/logo.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            AuthForm(authType: authType),
          ],
        ),
      ),
    );
  }
}
