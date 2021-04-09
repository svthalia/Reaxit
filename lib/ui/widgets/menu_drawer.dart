import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/members_screen.dart';
import 'package:reaxit/ui/screens/settings_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';
import 'package:url_launcher/link.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: add selected highlight, and make the onTap on the active item
    // dismiss the drawer if the top level page is the only item in the stack.
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          InkWell(
            onTap: () {
              // Member me = Provider.of<AuthProvider>(context, listen: false).me;
              // ThaliaRouterDelegate.of(context).push(MaterialPage(
              //   child: MemberDetail(me.pk, me),
              // ));
            },
            child: Stack(
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
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   left: 20,
                //   bottom: 10,
                //   child: Consumer<AuthProvider>(
                //     builder: (context, auth, child) => Text(
                //       auth.me?.displayName ?? "Loading",
                //       style: Theme.of(context).primaryTextTheme.headline5,
                //     ),
                //   ),
                // ),
                // SafeArea(
                //   minimum: EdgeInsets.all(20),
                //   child: Consumer<AuthProvider>(
                //     builder: (context, auth, child) => Container(
                //       width: 80,
                //       height: 80,
                //       decoration: BoxDecoration(
                //         image: DecorationImage(
                //           image: auth.me?.avatar?.small != null ?? false
                //               ? NetworkImage(auth.me.avatar.small)
                //               : AssetImage("assets/img/default-avatar.jpg"),
                //           fit: BoxFit.cover,
                //         ),
                //         borderRadius: BorderRadius.circular(40),
                //         boxShadow: [
                //           BoxShadow(
                //             offset: Offset(1, 2),
                //             blurRadius: 8,
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          ListTile(
            title: Text('Welcome'),
            leading: Icon(Icons.home),
            onTap: () => ThaliaRouterDelegate.of(context).replace(
              MaterialPage(child: WelcomeScreen()),
            ),
          ),
          ListTile(
            title: Text('Calendar'),
            leading: Icon(Icons.event),
            onTap: () => ThaliaRouterDelegate.of(context).replace(
              MaterialPage(child: CalendarScreen()),
            ),
          ),
          ListTile(
            title: Text('Member list'),
            leading: Icon(Icons.people),
            onTap: () => ThaliaRouterDelegate.of(context).replace(
              MaterialPage(child: MembersScreen()),
            ),
          ),
          ListTile(
            title: Text('Photos'),
            leading: Icon(Icons.photo),
            onTap: () => ThaliaRouterDelegate.of(context).replace(
              MaterialPage(child: AlbumsScreen()),
            ),
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () => ThaliaRouterDelegate.of(context).replace(
              MaterialPage(child: SettingsScreen()),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () async {
              BlocProvider.of<AuthBloc>(context).add(
                LogOutAuthEvent(),
              );
            },
          ),
          Divider(),
          AboutListTile(
            icon: Icon(Icons.info_outline),
            dense: true,
            applicationVersion: 'v2.0.1',
            applicationIcon: Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/img/logo-t-zwart.png'
                  : 'assets/img/logo-t-wit.png',
              width: 80,
            ),
            aboutBoxChildren: [
              Text(
                'There is an app for everything.',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Divider(),
              Link(
                uri: Uri.parse(
                  'https://github.com/svthalia/Reaxit/releases',
                ),
                builder: (context, followLink) => OutlinedButton.icon(
                  onPressed: followLink,
                  icon: Icon(Icons.history),
                  label: Text('Changelog'),
                ),
              ),
              Link(
                uri: Uri.parse(
                  'https://github.com/svthalia/Reaxit/issues',
                ),
                builder: (context, followLink) => OutlinedButton.icon(
                  onPressed: followLink,
                  icon: Icon(Icons.bug_report_outlined),
                  label: Text('Feedback'),
                ),
              ),
              Divider(),
            ],
          ),
        ],
      ),
    );
  }
}

class MemberList {}
