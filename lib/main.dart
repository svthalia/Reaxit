import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/routes.dart';

Future<void> testingMain() async {
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
    const ThaliApp(),
  );
}

class ThaliApp extends StatefulWidget {
  const ThaliApp();

  @override
  State<ThaliApp> createState() => _ThaliAppState();
}

class _ThaliAppState extends State<ThaliApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: routes,
      initialLocation: '/albums',
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FadeInImage.assetNetwork(
        placeholder: 'assets/img/photo_placeholder_0.png',
        image:
            'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg',
        fit: BoxFit.cover,
      ),
    );
    // return MaterialApp.router(
    //   title: 'ThaliApp',
    //   routerDelegate: _router.routerDelegate,
    //   routeInformationParser: _router.routeInformationParser,
    //   routeInformationProvider: _router.routeInformationProvider,
    //   builder: (context, navigator) {
    //     return navigator!;
    //   },
    // );
  }
}
