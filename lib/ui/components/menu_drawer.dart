import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/model/auth_model.dart';
import 'package:reaxit/ui/screens/login_screen.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Consumer<AuthModel>(
              builder: (context, auth, child) => Text(auth.name),
            ),
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
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              Provider.of<AuthModel>(context).logOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          )
        ],
      ),
    );
  }
}
