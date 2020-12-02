import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/model/auth_model.dart';

import 'welcome_screen/welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _loading = false;

  void _showSnackbar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text), duration: Duration(seconds: 1),));
  }

  Widget _showLoginForm() {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: 'Username',
            focusedBorder: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            isDense: true
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: passwordController,
          enableSuggestions: false,
          autocorrect: false,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            focusedBorder: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            isDense: true,
          ),
        ),
        SizedBox(height: 40),
        RaisedButton(
          textColor: Colors.white,
          color: Colors.black87,
          child: Text('LOGIN'),
          onPressed: () {
            if (usernameController.value.text == '')
              _showSnackbar('Missing username.');
            else if (passwordController.value.text == '')
              _showSnackbar('Missing password.');
            else {
              setState(() {
                _loading = true;
              });
              Provider.of<AuthModel>(context, listen: false).logIn(usernameController.value.text, passwordController.value.text).then((res) {
                setState(() {
                  _loading = false;
                });
                _showSnackbar(res);
                if (res == 'success')
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFE62272),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/img/logo.png'),
              width: 260,
            ),
            SizedBox(height: 50),
            _loading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : _showLoginForm(),
          ],
        ),
      ),
    );
  }
}
