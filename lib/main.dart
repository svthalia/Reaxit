import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/album_list_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/blocs/member_list_bloc.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/theme.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  @override
  void initState() {
    _routerDelegate = ThaliaRouterDelegate(
      authBloc: BlocProvider.of<AuthBloc>(context),
    );
    _routeInformationParser = ThaliaRouteInformationParser();
    super.initState();
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  /// This key prevents initializing a new [MaterialApp] state and, through
  /// that, a new [Router] state, that would otherwise unintentionally make
  /// an additional call to [ThaliaRouterDelegate.setInitialRoutePath] on
  /// uthentication events.
  final _materialAppKey = GlobalKey();

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
                  final apiRepository =
                      RepositoryProvider.of<ApiRepository>(context);
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => PaymentUserCubit(
                          apiRepository,
                        )..load(),
                        lazy: false,
                      ),
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
                    child: MaterialApp.router(
                      key: _materialAppKey,
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
                key: _materialAppKey,
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
