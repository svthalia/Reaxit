import 'package:flutter/material.dart';

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
              onTap: () => {}),
          ListTile(
              title: Text('Calendar'),
              leading: Icon(Icons.event),
              onTap: () => {}),
          ListTile(
              title: Text('Member list'),
              leading: Icon(Icons.people),
              onTap: () => {}),
          ListTile(
              title: Text('Photos'),
              leading: Icon(Icons.photo),
              onTap: () => {}),
          ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () => {}),
        ],
      ),
    );
  }
}
