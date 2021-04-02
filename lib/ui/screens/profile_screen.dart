import 'package:flutter/material.dart';
import 'package:reaxit/models/member.dart';

class ProfileScreen extends StatefulWidget {
  final int pk;
  final ListMember? member;

  const ProfileScreen({Key? key, required this.pk, this.member})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('profile nr. ${widget.pk}'),
      ),
    );
  }
}
