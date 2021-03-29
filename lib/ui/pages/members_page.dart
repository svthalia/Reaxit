import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/router/router.dart';
import 'package:reaxit/ui/menu_drawer.dart';

class MembersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MenuDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AutoRouter.of(context).push(ProfileRoute(memberPk: 3));
          },
          child: Text('To member 3'),
        ),
      ),
    );
  }
}
