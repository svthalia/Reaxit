import 'package:flutter/material.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
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
                  MaterialPage(child: ProfileScreen(pk: 5)),
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
