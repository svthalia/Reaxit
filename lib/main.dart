import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/ui/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
      routes: routes,
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
    return MaterialApp.router(
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
          listenWhen: (previous, current) => false,
          listener: (context, state) async {},
          buildWhen: (previous, current) => current is! FailureAuthState,
          builder: (context, authState) {
            return navigator!;
          },
        );
      },
    );
  }
}
