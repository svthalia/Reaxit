import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/album_list_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/blocs/member_list_bloc.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/theme.dart';

void main() async {
  runApp(BlocProvider(
    create: (_) => ThemeBloc()..add(ThemeLoadEvent()),
    lazy: false,
    child: BlocProvider(
      create: (context) => AuthBloc()..add(LoadAuthEvent()),
      child: ThaliApp(),
    ),
  ));
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
      authBloc: BlocProvider.of<AuthBloc>(context, listen: false),
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
            if (authState is LoggedInAuthState) {
              return RepositoryProvider(
                create: (_) => ApiRepository(
                  client: authState.client,
                  logOut: authState.logOut,
                ),
                child: Builder(builder: (context) {
                  var apiRepository = RepositoryProvider.of<ApiRepository>(
                    context,
                    listen: false,
                  );
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => EventListBloc(apiRepository)
                          ..add(EventListEvent.load()),
                        lazy: false,
                      ),
                      BlocProvider(
                        create: (_) => MemberListBloc(apiRepository)
                          ..add(MemberListEvent.load()),
                        lazy: false,
                      ),
                      BlocProvider(
                        create: (_) => AlbumListBloc(apiRepository)
                          ..add(AlbumListEvent.load()),
                        lazy: false,
                      ),
                    ],
                    child: MaterialApp.router(
                      title: 'ThaliApp',
                      theme: lightTheme,
                      darkTheme: darkTheme,
                      themeMode: themeMode,
                      routerDelegate: _routerDelegate,
                      routeInformationParser: _routeInformationParser,
                    ),
                  );
                }),
              );
            } else {
              return MaterialApp.router(
                title: 'ThaliApp',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                routerDelegate: _routerDelegate,
                routeInformationParser: _routeInformationParser,
              );
            }
          },
        );
      },
    );
  }
}
