import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/firebase_options.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/ui/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Fonts doesn't need to download fonts as they are bundled.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Add licenses for the used fonts.
  LicenseRegistry.addLicense(() async* {
    final openSansLicense = await rootBundle.loadString(
      'assets/google_fonts/OpenSans-OFL.txt',
    );
    final oswaldLicense = await rootBundle.loadString(
      'assets/google_fonts/Oswald-OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], openSansLicense);
    yield LicenseEntryWithLineBreaks(['google_fonts'], oswaldLicense);
  });

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
    },
    appRunner: () async {
      runApp(
        BlocProvider(
          create: (context) => AuthCubit()..load(),
          child: const ThaliApp(),
        ),
      );
    },
  );
}

/// A copy of [main] that allows inserting an [AuthCubit] for integration tests.
Future<void> testingMain(AuthCubit? authCubit, String? initialroute) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Fonts doesn't need to download fonts as they are bundled.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Add licenses for the used fonts.
  LicenseRegistry.addLicense(() async* {
    final openSansLicense = await rootBundle.loadString(
      'assets/google_fonts/OpenSans-OFL.txt',
    );
    final oswaldLicense = await rootBundle.loadString(
      'assets/google_fonts/Oswald-OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], openSansLicense);
    yield LicenseEntryWithLineBreaks(['google_fonts'], oswaldLicense);
  });

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    authCubit == null
        ? BlocProvider(
            create: (context) => AuthCubit()..load(),
            child: ThaliApp(
              initialRoute: initialroute,
            ),
          )
        : BlocProvider.value(
            value: authCubit..load(),
            child: ThaliApp(
              initialRoute: initialroute,
            )),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class ThaliApp extends StatefulWidget {
  final String? initialRoute;
  const ThaliApp({this.initialRoute});

  @override
  State<ThaliApp> createState() => _ThaliAppState();
}

class _ThaliAppState extends State<ThaliApp> {
  late final GoRouter _router;
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = BlocProvider.of<AuthCubit>(context);
    _router = GoRouter(
      // The list of routes is kept in a separate
      // file to keep the code readable and clean.
      routes: routes,

      // Provide navigation breadcrumbs to Sentry.
      observers: [SentryNavigatorObserver()],

      // Redirect to `/login?from=<original-path>` if the user is not
      // logged in. If the user is logged in, and there is an original
      // path in the query parameters, redirect to that original path.
      redirect: (context, state) {
        final authState = _authCubit.state;
        final loggedIn = authState is LoggedInAuthState;
        final justLoggedOut =
            authState is LoggedOutAuthState && authState.apiRepository != null;
        final goingToLogin = state.uri.toString().startsWith('/login');

        if (!loggedIn && !goingToLogin) {
          // Drop original location if you just logged out.
          if (justLoggedOut) return '/login';

          return Uri(path: '/login', queryParameters: {
            'from': state.uri.toString(),
          }).toString();
        } else if (loggedIn && goingToLogin) {
          return Uri.parse(state.uri.toString()).queryParameters['from'] ?? '/';
        } else {
          return null;
        }
      },

      // Refresh to look for redirects whenever auth state changes.
      refreshListenable: GoRouterRefreshStream(_authCubit.stream),

      initialLocation: widget.initialRoute,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp.router(
        title: 'ThaliApp',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        routeInformationProvider: _router.routeInformationProvider,

        // This adds listeners for authentication status snackbars and setting up
        // push notifications. This surrounds the navigator with providers when
        // logged in, and replaces it with a [LoginScreen] when not logged in.
        builder: (context, navigator) {
          return BlocConsumer<AuthCubit, AuthState>(
            listenWhen: (previous, current) {
              if (previous is LoggedInAuthState &&
                  current is LoggedOutAuthState) {
                return true;
              } else if (current is FailureAuthState) {
                return true;
              }
              return false;
            },

            // Listen to display login status snackbars and set up notifications.
            listener: (context, state) async {
              // Show a snackbar when the user logs out or logging in fails.
              switch (state) {
                case LoggedOutAuthState _:
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Logged out.'),
                  ));
                case FailureAuthState(message: var message):
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(message ?? 'Logging in failed.'),
                  ));
                case _:
              }
            },
            buildWhen: (previous, current) => current is! FailureAuthState,
            builder: (context, authState) {
              // Build with ApiRepository and cubits provided when an
              // ApiRepository is available. This is the case when logged
              // in, but also when just logged out (after having been logged
              // in), with a closed ApiRepository.
              // The latter allows us to keep the cubits alive
              // while animating towards the login screen.
              if (authState is LoggedInAuthState ||
                  (authState is LoggedOutAuthState &&
                      authState.apiRepository != null)) {
                final ApiRepository apiRepository;
                if (authState is LoggedInAuthState) {
                  apiRepository = authState.apiRepository;
                } else {
                  apiRepository =
                      (authState as LoggedOutAuthState).apiRepository!;
                }

                return InheritedConfig(
                  config: apiRepository.config,
                  child: RepositoryProvider.value(
                    value: apiRepository,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) => AlbumListCubit(apiRepository)..load(),
                          lazy: false,
                        ),
                      ],
                      child: navigator!,
                    ),
                  ),
                );
              } else {
                return navigator!;
              }
            },
          );
        },
      ),
    );
  }
}
