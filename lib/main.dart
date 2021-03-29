import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/router/router.dart';
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
              // TODO: MultiBlocProvider.
              return MaterialApp.router(
                title: 'ThaliApp',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                routerDelegate: _routerDelegate,
                routeInformationParser: _routeInformationParser,
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
