import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/ui/router.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/members_screen.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';
import 'package:reaxit/ui/screens/settings_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';
import 'package:reaxit/ui/widgets/cached_image.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routerDelegate = ThaliaRouterDelegate.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<FullMemberCubit, FullMemberState>(
              builder: (context, state) {
            if (state.result != null) {
              final me = state.result!;
              return InkWell(
                onTap: () {
                  routerDelegate.push(TypedMaterialPage(
                    child: ProfileScreen(pk: me.pk, member: me),
                    name: 'Profile(${me.pk} (me))',
                  ));
                },
                child: Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: const BoxDecoration(
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
                    Positioned(
                      left: 16,
                      bottom: 8,
                      child: Text(
                        me.displayName,
                        style: Theme.of(context).primaryTextTheme.headline5,
                      ),
                    ),
                    SafeArea(
                      minimum: const EdgeInsets.all(16),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedImageProvider(
                              me.photo.medium,
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(1, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return InkWell(
                onTap: null,
                child: Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: const BoxDecoration(
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
                    Positioned(
                      left: 16,
                      bottom: 8,
                      child: Text(
                        'Loading...',
                        style: Theme.of(context).primaryTextTheme.headline5,
                      ),
                    ),
                    SafeArea(
                      minimum: const EdgeInsets.all(16),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/img/default-avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(1, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
          const Divider(height: 0, thickness: 1),
          ListTile(
            title: const Text('Welcome'),
            leading: const Icon(Icons.home),
            selected: routerDelegate.stack.last.child is WelcomeScreen,
            onTap: () {
              if (routerDelegate.stack.last.child is WelcomeScreen) {
                Navigator.of(context).pop();
              } else {
                routerDelegate.replace(
                  TypedMaterialPage(child: WelcomeScreen(), name: 'Welcome'),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Calendar'),
            leading: const Icon(Icons.event),
            selected: routerDelegate.stack.last.child is CalendarScreen,
            onTap: () {
              if (routerDelegate.stack.last.child is CalendarScreen) {
                Navigator.of(context).pop();
              } else {
                routerDelegate.replace(
                  TypedMaterialPage(child: CalendarScreen(), name: 'Calendar'),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Member list'),
            leading: const Icon(Icons.people),
            selected: routerDelegate.stack.last.child is MembersScreen,
            onTap: () {
              if (routerDelegate.stack.last.child is MembersScreen) {
                Navigator.of(context).pop();
              } else {
                routerDelegate.replace(
                  TypedMaterialPage(child: MembersScreen(), name: 'Members'),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Photos'),
            leading: const Icon(Icons.photo),
            selected: routerDelegate.stack.last.child is AlbumsScreen,
            onTap: () {
              if (routerDelegate.stack.last.child is AlbumsScreen) {
                Navigator.of(context).pop();
              } else {
                routerDelegate.replace(
                  TypedMaterialPage(child: AlbumsScreen(), name: 'Albums'),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            selected: routerDelegate.stack.last.child is SettingsScreen,
            onTap: () {
              if (routerDelegate.stack.last.child is SettingsScreen) {
                Navigator.of(context).pop();
              } else {
                routerDelegate.replace(
                  TypedMaterialPage(child: SettingsScreen(), name: 'Settings'),
                );
              }
            },
          ),
          const Divider(height: 0, thickness: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              BlocProvider.of<AuthBloc>(context).add(
                LogOutAuthEvent(),
              );
            },
          ),
        ],
      ),
    );
  }
}
