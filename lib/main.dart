import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reaxit/blocs/album_list_bloc.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/event_list_bloc.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/blocs/member_list_bloc.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/push_notifications.dart';
import 'package:reaxit/theme.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDSN;
    },
    appRunner: () async {
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
  final _firebaseInitialization = Firebase.initializeApp();

  /// Setup push notification handlers.
  Future<void> _setupFirebaseMessaging() async {
    // Make sure firebase has been initialized.
    await _firebaseInitialization;

    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // User got a push notification while the app is running.
    // Display a notification inside the app.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showOverlayNotification(
          (context) {
            return SafeArea(
              child: Card(
                child: ListTile(
                  onTap: () async {
                    if (message.data.containsKey('url') &&
                        message.data['url'] != null) {
                      final link = Uri.tryParse(message.data['url']);
                      if (link != null && await canLaunch(link.toString())) {
                        await launch(
                          link.toString(),
                          forceSafariVC: false,
                          forceWebView: false,
                        );
                      }
                    }
                  },
                  title: Text(message.notification!.title ?? '', maxLines: 1),
                  subtitle: Text(message.notification!.body ?? '', maxLines: 2),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => OverlaySupportEntry.of(context)!.dismiss(),
                  ),
                ),
              ),
            );
          },
          duration: Duration(milliseconds: 4000),
        );
      }
    });

    // User clicked on push notification outside of app and the app was still
    // in the background. Open the deeplink in the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.containsKey('url') && message.data['url'] != null) {
        final link = Uri.tryParse(message.data['url']);
        // TODO: Dialog?
        if (link != null && await canLaunch(link.toString())) {
          await launch(
            link.toString(),
            forceSafariVC: false,
            forceWebView: false,
          );
        }
      }
    });

    // User got a push notification outside of the app while the app was not
    // running in the background. Open the deeplink in the notification.
    if (initialMessage != null) {
      if (initialMessage.data.containsKey('url') &&
          initialMessage.data['url'] != null) {
        final link = Uri.tryParse(initialMessage.data['url']);
        // TODO: Dialog?
        if (link != null && await canLaunch(link.toString())) {
          await launch(
            link.toString(),
            forceSafariVC: false,
            forceWebView: false,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _routeInformationParser = ThaliaRouteInformationParser();
    _routerDelegate = ThaliaRouterDelegate(
      authBloc: BlocProvider.of<AuthBloc>(context),
    );
    _setupFirebaseMessaging();
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
    return OverlaySupport(child: BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, authState) async {
            if (authState is LoggedInAuthState) {
              // Make sure firebase has been initialized.
              await _firebaseInitialization;

              // Setup push notifications with the api.
              await registerPushNotifications(authState.apiRepository);
              FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
                registerPushNotificationsToken(authState.apiRepository, token);
              });
            }
          },
          builder: (context, authState) {
            if (authState is LoggedInAuthState) {
              return RepositoryProvider.value(
                value: authState.apiRepository,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => PaymentUserCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => FullMemberCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => WelcomeCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => EventListBloc(
                        authState.apiRepository,
                      )..add(EventListEvent.load()),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => MemberListBloc(
                        authState.apiRepository,
                      )..add(MemberListEvent.load()),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => AlbumListBloc(
                        authState.apiRepository,
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
                ),
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
    ));
  }
}
