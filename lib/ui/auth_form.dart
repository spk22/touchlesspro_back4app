import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/ui/auth_button.dart';
import 'package:touchlesspro_back4app/ui/toggle_auth.dart';
import 'admin_auth.dart';

class AuthForm extends StatefulWidget {
  final AuthType authType;
  const AuthForm({Key key, @required this.authType}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter your email',
                labelStyle: TextStyle(color: Colors.teal),
                hintText: 'eg: test@gmail.com',
              ),
              onChanged: (value) {
                _email = value;
              },
              validator: (value) =>
                  value.isEmpty ? 'You must enter a valid email' : null,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter your password',
                labelStyle: TextStyle(color: Colors.teal),
              ),
              obscureText: true,
              onChanged: (value) {
                _password = value;
              },
              validator: (value) => value.length <= 6
                  ? 'Your password must be larger than 6 characters'
                  : null,
            ),
            SizedBox(height: 20.0),
            AuthButton(
              text: widget.authType == AuthType.login ? 'Login' : 'Register',
              color: Colors.teal,
              textColor: Colors.white,
              onPressed: () {
                //TODO: Login/Register the admin
              },
            ),
            SizedBox(height: 30.0),
            ToggleAuthWidget(
              toggleText: widget.authType == AuthType.login
                  ? 'Don\'t have an account? '
                  : 'Already have an account? ',
              richTextName:
                  widget.authType == AuthType.login ? 'Register' : 'Login',
              routeName: widget.authType == AuthType.login
                  ? AdminAuthPage.registerId
                  : AdminAuthPage.loginId,
              richTextColor: Color(0xFF645AFF),
            ),
            // FlatButton(
            //   onPressed: () {
            //     if (widget.authType == AuthType.login) {
            //       Navigator.of(context)
            //           .pushReplacementNamed(AdminAuthPage.registerId);
            //     } else {
            //       Navigator.of(context)
            //           .pushReplacementNamed(AdminAuthPage.loginId);
            //     }
            //   },
            //   child: Text(
            //     widget.authType == AuthType.login
            //         ? 'Don\'t have an account?'
            //         : 'Already have an account?',
            //     style: TextStyle(
            //       fontSize: 18,
            //       color: Colors.black54,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
