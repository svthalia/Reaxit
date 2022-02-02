import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/blocs/auth_cubit.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/ui/widgets/cached_image.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<FullMemberCubit, FullMemberState>(
            builder: (context, state) {
              if (state.result != null) {
                final me = state.result!;
                return Stack(
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
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.pushNamed(
                            'member',
                            params: {'memberPk': me.pk.toString()},
                            extra: me,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Stack(
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
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(onTap: () {}),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const Divider(height: 0, thickness: 1),
          ListTile(
            title: const Text('Welcome'),
            leading: const Icon(Icons.home),
            selected: router.location == '/welcome',
            onTap: () {
              if (router.location == '/welcome') {
                Navigator.of(context).pop();
              } else {
                context.goNamed('welcome');
              }
            },
          ),
          ListTile(
            title: const Text('Calendar'),
            leading: const Icon(Icons.event),
            selected: router.location == '/events',
            onTap: () {
              if (router.location == '/events') {
                Navigator.of(context).pop();
              } else {
                context.goNamed('calendar');
              }
            },
          ),
          ListTile(
            title: const Text('Member list'),
            leading: const Icon(Icons.people),
            selected: router.location == '/members',
            onTap: () {
              if (router.location == '/members') {
                Navigator.of(context).pop();
              } else {
                context.goNamed('members');
              }
            },
          ),
          ListTile(
            title: const Text('Photos'),
            leading: const Icon(Icons.photo),
            selected: router.location == '/albums',
            onTap: () {
              if (router.location == '/albums') {
                Navigator.of(context).pop();
              } else {
                context.goNamed('albums');
              }
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            selected: router.location == '/settings',
            onTap: () {
              if (router.location == '/settings') {
                Navigator.of(context).pop();
              } else {
                context.goNamed('settings');
              }
            },
          ),
          const Divider(height: 0, thickness: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              BlocProvider.of<AuthCubit>(context).logOut();
            },
          ),
        ],
      ),
    );
  }
}
