import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/navigation.dart';
import 'package:reaxit/providers/auth_provider.dart';

import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  ImageProvider logo = AssetImage('assets/img/logo.png');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(logo, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE62272),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image(
              image: logo,
              width: 260,
            ),
          ),
          SizedBox(height: 50),
          SizedBox(
            height: 50,
            child: Center(
              child: Builder(
                builder: (context) {
                  if (_loading) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  } else {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black87,
                        onPrimary: Colors.white,
                      ),
                      child: Text('LOGIN'),
                      onPressed: () async {
                        setState(() => _loading = true);
                        String result = await Provider.of<AuthProvider>(context,
                                listen: false)
                            .logIn();
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        if (result == 'success') {
                          ThaliaRouterDelegate.of(context).replace(
                            MaterialPage(child: WelcomeScreen()),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
