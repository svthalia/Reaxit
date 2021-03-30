import 'package:flutter/material.dart';
import 'package:reaxit/router/router.dart';
import 'package:reaxit/ui/menu_drawer.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';

class MembersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MenuDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ThaliaRouterDelegate.of(context).push(
              MaterialPage(child: ProfileScreen(memberPk: 3)),
            );
          },
          child: Text('To member 3'),
        ),
      ),
    );
  }
}
