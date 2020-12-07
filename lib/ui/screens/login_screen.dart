import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/model/auth_model.dart';

import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _loading = false;
  ImageProvider logo = AssetImage('assets/img/logo.png');

  void _showSnackbar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 1),
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(logo, context);
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
              image: logo,
              width: 260,
            ),
            SizedBox(height: 50),
            Center(
              child: _loading
                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : RaisedButton(
                      textColor: Colors.white,
                      color: Colors.black87,
                      child: Text('LOGIN'),
                      onPressed: () {
                        setState(() {
                          _loading = true;
                        });
                        Provider.of<AuthModel>(context, listen: false).logIn().then((res) {
                          setState(() {
                            _loading = false;
                          });
                          _showSnackbar(res);
                          if (res == 'success') Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
                        });
                      },
                    )
            ),
          ],
        ),
      ),
    );
  }
}
