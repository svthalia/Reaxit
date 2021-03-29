import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/router/auth_guard.dart';
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
  late final _appRouter;

  @override
  void initState() {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    _appRouter = AppRouter(authGuard: AuthGuard(authBloc.stream));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'ThaliApp',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
        );
      },
    );
  }
}
