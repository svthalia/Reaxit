import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pedantic/pedantic.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/ui/screens/album_screen.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/members_screen.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';
import 'package:reaxit/ui/widgets/tpay_sales_order_dialog.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reaxit/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class ThaliaRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  static ThaliaRouterDelegate of(BuildContext context) {
    var delegate = Router.of(context).routerDelegate;
    assert(delegate is ThaliaRouterDelegate, 'Delegate type must match.');
    return delegate as ThaliaRouterDelegate;
  }

  final AuthBloc authBloc;
  late final StreamSubscription authSubscription;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final List<Page> _stack = [MaterialPage(child: LoginScreen())];

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
      if (navigatorKey.currentContext != null) {
        unawaited(showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => PushNotificationDialog(message),
        ));
      }
    });

    // User got a push notification outside of the app while the app was not
    // running in the background. Open the deeplink in the notification.
    if (initialMessage != null) {
      if (navigatorKey.currentContext != null) {
        unawaited(showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => PushNotificationDialog(initialMessage),
        ));
      }
    }
  }

  ThaliaRouterDelegate({required this.authBloc})
      : navigatorKey = GlobalKey<NavigatorState>() {
    _setupFirebaseMessaging();
    authSubscription = authBloc.stream.listen((state) {
      if (state is LoggedInAuthState) {
        replaceStack([MaterialPage(child: WelcomeScreen())]);
      } else if (state is LoggedOutAuthState) {
        replaceStack([MaterialPage(child: LoginScreen())]);
      }
    });
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listener that creates SnackBars.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        if (previous is LoggedInAuthState && current is LoggedOutAuthState) {
          return true;
        } else if (previous is LoggingInAuthState &&
            current is LoggedInAuthState) {
          return true;
        } else if (current is FailureAuthState) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is LoggedOutAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logged out'),
            duration: Duration(seconds: 2),
          ));
        } else if (state is LoggedInAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Logged in'),
            duration: Duration(seconds: 2),
          ));
        } else if (state is FailureAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message ?? 'Logging in failed.'),
            duration: Duration(seconds: 2),
          ));
        }
      },
      // Listener for setting up push notifications.
      child: BlocListener<AuthBloc, AuthState>(
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
        child: Navigator(
          key: navigatorKey,
          onPopPage: _onPopPage,
          // Copy the stack with `.toList()` to have the navigator update.
          pages: _stack.toList(),
          observers: [SentryNavigatorObserver()],
        ),
      ),
    );
  }

  bool _onPopPage(route, result) {
    if (!route.didPop(result)) return false;
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
    return true;
  }

  @override
  Future<void> setNewRoutePath(Uri uri) async {
    var authState = authBloc.state;
    // Wait for the first non-loading authState, because deeplinks in
    // android are passed before the AuthBloc gets the chance to load.
    if (authState is LoadingAuthState) {
      authState = await authBloc.stream.firstWhere(
        (state) => !(state is LoadingAuthState),
      );
    }

    if (!(authState is LoggedInAuthState)) return SynchronousFuture(null);

    var path = uri.path;
    var segments = uri.pathSegments;

    if (segments.isEmpty) {
      // Handle "/".
      _stack
        ..clear()
        ..addAll([
          MaterialPage(child: WelcomeScreen()),
        ]);
    } else if (RegExp('^/pizzas/?\$').hasMatch(path)) {
      _stack
        ..clear()
        ..addAll([
          MaterialPage(child: WelcomeScreen()),
          // TODO: Get the right foodevent, probably using a disambiguation dialog
          //  that is a SimpleDialog and shortly creates its own cubit to load the
          //  possible foodevents.
          // MaterialPage(child: FoodScreen()),
        ]);
    } else if (RegExp('^/events/?\$').hasMatch(path)) {
      _stack
        ..clear()
        ..addAll([
          MaterialPage(child: CalendarScreen()),
        ]);
    } else if (RegExp('^/events/([0-9]+)/?\$').hasMatch(path)) {
      final pk = int.parse(segments[1]);
      _stack
        ..clear()
        ..addAll([
          MaterialPage(child: CalendarScreen()),
          MaterialPage(child: EventScreen(pk: pk))
        ]);
    } else if (RegExp('^/members/photos/([a-z0-9\-_]+)/?\$').hasMatch(path)) {
      _stack
        ..clear()
        ..addAll([
          MaterialPage(child: AlbumsScreen()),
          MaterialPage(child: AlbumScreen(slug: segments[2]))
        ]);
    } else if (RegExp('^/members/([0-9]+)/?\$').hasMatch(path)) {
      final pk = int.parse(segments[1]);
      _stack
        ..clear()
        ..addAll([
          MaterialPage(child: MembersScreen()),
          MaterialPage(child: ProfileScreen(pk: pk))
        ]);
    } else if (RegExp('^/sales/order/([a-f0-9\-]+)/pay/?\$').hasMatch(path)) {
      final pk = segments[2];
      if (navigatorKey.currentContext != null) {
        unawaited(showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => TPaySalesOrderDialog(pk: pk),
        ));
      }
    }

    return SynchronousFuture(null);
  }

  /// Adds a page to the top of the stack.
  void push(MaterialPage page) {
    _stack.add(page);
    notifyListeners();
  }

  /// Removes the top of the stack.
  void pop() {
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
  }

  // TODO: Fix missing animations. The old page is currently swapped for the
  //  new one. Instead, it should be rendered over it before removing the old one.

  /// Replaces the top of the stack.
  void replace(MaterialPage page) {
    _stack
      ..removeLast()
      ..add(page);
    notifyListeners();
  }

  /// Replaces the current stack.
  void replaceStack(List<MaterialPage> stack) {
    // TODO: Dispose the removed widgets if that doesn't happen automatically.
    _stack
      ..clear()
      ..addAll(stack);
    notifyListeners();
  }
}

class ThaliaRouteInformationParser implements RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(routeInformation) async {
    var uri = Uri.parse(routeInformation.location!);
    return SynchronousFuture(uri);
  }

  @override
  RouteInformation restoreRouteInformation(configuration) {
    return RouteInformation(location: configuration.toString());
  }
}
