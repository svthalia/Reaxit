import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  final int eventPk;
  final int registrationPk;

  RegistrationScreen({required this.eventPk, required this.registrationPk})
      : super(key: ValueKey(registrationPk));

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('registration ${widget.registrationPk}'),
      ),
    );
  }
}
