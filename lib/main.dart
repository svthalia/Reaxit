import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
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

  Future<void> setupInteractedMessage(BuildContext context) async {
    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // User got a push notification outside of the app while the app was not running in the background
    if (initialMessage != null) {
      print(initialMessage);
    }

    // User got a push notification while the app is running
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showOverlayNotification((context) {
          return SafeArea(
            child: Card(
              child: ListTile(
                title: Text(message.notification!.title != null ? message.notification!.title! : ''),
                subtitle: Text(message.notification!.body != null ? message.notification!.body! : ''),
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)!.dismiss();
                    }),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 4000));
      }
    });

    // User clicked on push notification outside of app and the app was still in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title != null ? message.notification!.title! : ''),
              content: SingleChildScrollView(
                child: Text(message.notification!.title != null ? message.notification!.title! : ''),
              ),
              actions: [
                TextButton(
                onPressed: () {
                    Navigator.of(context).pop();
                  },
                child: Text('Ok'),
                ),
              ]
            );
          },
        );
      }
    });
  }

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
    return OverlaySupport(
      child: BlocBuilder<ThemeBloc, ThemeMode>(
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
                  setupInteractedMessage(context);
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
    )
    );
  }
}
