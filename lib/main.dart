import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:reaxit/push_notifications.dart';
import 'package:reaxit/theme.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'blocs/setting_cubit.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDSN;
    },
    appRunner: () {
      Firebase.initializeApp();
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

  @override
  void initState() {
    _routerDelegate = ThaliaRouterDelegate(
      authBloc: BlocProvider.of<AuthBloc>(context),
    );
    _routeInformationParser = ThaliaRouteInformationParser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  var apiRepository = ApiRepository(client: authState.client, logOut: authState.logOut);
                  register(apiRepository);
                  FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
                    registerToken(token, apiRepository);
                  });
                  return RepositoryProvider(
                    create: (_) => apiRepository,
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
}
