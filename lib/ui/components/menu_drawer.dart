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
            leading: Icon(Icons.home),
            title: Text('Welcome'),
          )
        ],
      ),
    );
  }
}