import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE62272),
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/img/logo.png'), width: 260,),
              SizedBox(height: 50),
              TextField(decoration: InputDecoration(hintText: 'Username', focusedBorder: UnderlineInputBorder())),
              TextField(decoration: InputDecoration(hintText: 'Password', focusedBorder: UnderlineInputBorder())),
              SizedBox(height: 20),
              RaisedButton(
                textColor: Colors.white,
                color: Colors.black87,
                child: Text('LOGIN'),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}