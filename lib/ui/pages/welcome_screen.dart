import 'package:flutter/material.dart';
import 'package:reaxit/router/router.dart';
import 'package:reaxit/ui/menu_drawer.dart';
import 'package:reaxit/ui/pages/profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Welcome page'),
            ElevatedButton(
              onPressed: () {
                ThaliaRouterDelegate.of(context).push(
                  MaterialPage(child: ProfileScreen(memberPk: 5)),
                );
              },
              child: Text('to 5'),
            ),
          ],
        ),
      ),
    );
  }
}
