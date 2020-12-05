import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/welcome_screen/welcome_screen.dart';
import 'package:reaxit/ui/screens/member_list.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Thalia App'),
          ),
          ListTile(
            title: Text('Welcome'),
            leading: Icon(Icons.home),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ),
          ),
          ListTile(
            title: Text('Calendar'),
            leading: Icon(Icons.event),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ),
          ),
          ListTile(
            title: Text('Member list'),
            leading: Icon(Icons.people),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MemberList()),
            ),
          ),
          ListTile(
            title: Text('Photos'),
            leading: Icon(Icons.photo),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ),
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
