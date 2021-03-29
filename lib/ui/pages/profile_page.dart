import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final int memberPk;

  const ProfilePage({Key? key, @PathParam('pk') required this.memberPk})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    print(AutoRouter.of(context).stack);
    print(AutoRouter.of(context).root.stack);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('profile nr. ${widget.memberPk}'),
      ),
    );
  }
}
