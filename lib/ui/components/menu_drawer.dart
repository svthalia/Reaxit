import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/auth_provider.dart';
import 'package:reaxit/ui/screens/album_list.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/settings_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';
import 'package:reaxit/ui/screens/member_list.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: add selected highlight
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/huygens.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset.bottomCenter,
                    end: FractionalOffset.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 10,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) => Text(
                    auth.name,
                    style: Theme.of(context).primaryTextTheme.headline5,
                  ),
                ),
              ),
              SafeArea(
                minimum: EdgeInsets.all(20),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(auth.pictureUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(1, 2),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
              MaterialPageRoute(builder: (context) => CalendarScreen()),
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
              MaterialPageRoute(builder: (context) => AlbumList()),
            ),
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              Provider.of<AuthProvider>(context).logOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          )
        ],
      ),
    );
  }
}
