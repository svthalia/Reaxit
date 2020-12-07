import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/auth_provider.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';
import 'package:reaxit/ui/screens/member_list.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/img/huygens.jpg'),
                  fit: BoxFit.cover,
                )),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [Color(0x88000000), Color(0x00000000)])),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) => Text(
                    auth.name,
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 20,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, child) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(auth.pictureUrl),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x88000000),
                              offset: Offset(2, 3),
                              blurRadius: 5,
                              spreadRadius: 3)
                        ]),
                  ),
                ),
              )
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
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            ),
          ),
          ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () => {}),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              Provider.of<AuthProvider>(context).logOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          )
        ],
      ),
    );
  }
}
