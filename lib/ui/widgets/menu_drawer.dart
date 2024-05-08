import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/config.dart' as config;

class MenuDrawer extends StatelessWidget {
  void _goTo(BuildContext context, String location) {
    context.pushNamed(location);
    // Pop the menu drawer
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        primary: false,
        padding: EdgeInsets.zero,
        children: [
          const Divider(height: 0, thickness: 1),
          ListTile(
            title: const Text('Welcome'),
            leading: const Icon(Icons.home),
            selected: GoRouterState.of(context).uri.toString() == '/',
            onTap: () {
              if (GoRouterState.of(context).uri.toString() == '/') {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'welcome');
              }
            },
          ),
          ListTile(
            title: const Text('Calendar'),
            leading: const Icon(Icons.event),
            selected: GoRouterState.of(context).uri.toString() == '/events',
            onTap: () {
              if (GoRouterState.of(context).uri.toString() == '/events') {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'calendar');
              }
            },
          ),
          ListTile(
            title: const Text('Member list'),
            leading: const Icon(Icons.people),
            selected: GoRouterState.of(context).uri.toString() == '/members',
            onTap: () {
              if (GoRouterState.of(context).uri.toString() == '/members') {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'members');
              }
            },
          ),
          ListTile(
            title: const Text('Groups'),
            leading: const Icon(Icons.groups),
            selected:
                GoRouterState.of(context).uri.toString().startsWith('/groups'),
            onTap: () {
              if (GoRouterState.of(context).uri.toString() == '/groups') {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'groups');
              }
            },
          ),
          ListTile(
            title: const Text('Photos'),
            leading: const Icon(Icons.photo),
            selected: GoRouterState.of(context).uri.toString() == '/albums',
            onTap: () {
              if (GoRouterState.of(context).uri.toString() == '/albums') {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'albums');
              }
            },
          ),
          ListTile(
            title: const Text('Payments'),
            leading: const Icon(Icons.euro),
            selected: GoRouterState.of(context).uri.toString() == '/pay',
            onTap: () {
              if (GoRouterState.of(context).uri.toString().startsWith('/pay')) {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'pay');
              }
            },
          ),
          const Divider(thickness: 1),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            selected: GoRouterState.of(context).uri.toString() == '/settings',
            onTap: () {
              if (GoRouterState.of(context).uri.toString() == '/settings') {
                Navigator.of(context).pop();
              } else {
                _goTo(context, 'settings');
              }
            },
          ),
          if (config.tostiEnabled)
            ListTile(
              title: const Text('T.O.S.T.I.'),
              leading: const Icon(Icons.breakfast_dining),
              selected:
                  GoRouterState.of(context).uri.toString().startsWith('/tosti'),
              onTap: () {
                if (GoRouterState.of(context)
                    .uri
                    .toString()
                    .startsWith('/tosti')) {
                  Navigator.of(context).pop();
                } else {
                  _goTo(context, 'tosti');
                }
              },
            ),
        ],
      ),
    );
  }
}
