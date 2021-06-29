import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/album_list_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/blocs/member_list_bloc.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/theme.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDSN;
    },
    appRunner: () {
      runApp(BlocProvider(
        create: (_) => ThemeBloc()..add(ThemeLoadEvent()),
        lazy: false,
        child: BlocProvider(
          create: (context) => AuthBloc()..add(LoadAuthEvent()),
          child: ThaliApp(),
        ),
      ));
    },
  );
}

class ThaliApp extends StatefulWidget {
  @override
  _ThaliAppState createState() => _ThaliAppState();
}

class _ThaliAppState extends State<ThaliApp> {
  late final ThaliaRouterDelegate _routerDelegate;
  late final ThaliaRouteInformationParser _routeInformationParser;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    _routerDelegate = ThaliaRouterDelegate(
      authBloc: BlocProvider.of<AuthBloc>(context),
    );
    _routeInformationParser = ThaliaRouteInformationParser();
    super.initState();
  }

  Widget _buildThaliApp() {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return MaterialApp.router(
              title: 'ThaliApp',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              routerDelegate: _routerDelegate,
              routeInformationParser: _routeInformationParser,
              builder: (context, router) {
                if (authState is LoggedInAuthState) {
                  return RepositoryProvider(
                    create: (_) => ApiRepository(
                      client: authState.client,
                      logOut: authState.logOut,
                    ),
                    child: Builder(builder: (context) {
                      final apiRepository =
                      RepositoryProvider.of<ApiRepository>(context);
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => FullMemberCubit(
                              apiRepository,
                            )..load(),
                            lazy: false,
                          ),
                          BlocProvider(
                            create: (_) => WelcomeCubit(
                              apiRepository,
                            )..load(),
                            lazy: false,
                          ),
                          BlocProvider(
                            create: (_) => EventListBloc(
                              apiRepository,
                            )..add(EventListEvent.load()),
                            lazy: false,
                          ),
                          BlocProvider(
                            create: (_) => MemberListBloc(
                              apiRepository,
                            )..add(MemberListEvent.load()),
                            lazy: false,
                          ),
                          BlocProvider(
                            create: (_) => AlbumListBloc(
                              apiRepository,
                            )..add(AlbumListEvent.load()),
                            lazy: false,
                          ),
                        ],
                        child: router!,
                      );
                    }),
                  );
                } else {
                  return router!;
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (!snapshot.hasError) {
          // TODO: Display nice error message
          return Text('Firebase failed to initialize');
        }
        else if (snapshot.connectionState == ConnectionState.done) {
          return _buildThaliApp();
        }
        else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}
