import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final int memberPk;

  const ProfileScreen({Key? key, required this.memberPk}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('profile nr. ${widget.memberPk}'),
      ),
    );
  }
}
