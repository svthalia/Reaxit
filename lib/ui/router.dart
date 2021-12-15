import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/ui/screens/album_screen.dart';
import 'package:reaxit/ui/screens/albums_screen.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/food_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/members_screen.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:reaxit/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class that adds a key to [MaterialPage], and requires a `name`.
///
/// Including a key makes sure that transitions are animated when a page is
/// replaced. If we don't specify a key (or overwrite `canUpdate`), the
/// transition from e.g. `[MaterialPage(child: WelcomeScreen())]` to
/// `[MaterialPage(child: AlbumsScreen())]` would not animate, as both pages
/// have the same runtimeType and key, so `old.canUpdateFrom(new)` is true.
///
/// The `name` argument is required in order to provide useful debugging info,
/// for example in the Sentry logs.
class TypedMaterialPage extends MaterialPage {
  TypedMaterialPage({
    required Widget child,
    required String name,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          child: child,
          fullscreenDialog: fullscreenDialog,
          maintainState: maintainState,
          name: name,
          key: ValueKey(child.runtimeType),
        );

  // TODO: Someday: Create a Page subclass for each screen, that specifies the
  //  name, arguments, and possibly custom transitions.
}

class ThaliaRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  static ThaliaRouterDelegate of(BuildContext context) {
    var delegate = Router.of(context).routerDelegate;
    assert(delegate is ThaliaRouterDelegate, 'Delegate type must match.');
    return delegate as ThaliaRouterDelegate;
  }

  final AuthBloc authBloc;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final List<TypedMaterialPage> _stack = [
    TypedMaterialPage(child: WelcomeScreen(), name: 'Welcome'),
  ];

  List<TypedMaterialPage> get stack => _stack;

  final Future<FirebaseApp> _firebaseInitialization;

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
            Uri? uri;
            if (message.data.containsKey('url') &&
                message.data['url'] is String) {
              uri = Uri.tryParse(message.data['url'] as String);
            }

            return SafeArea(
              child: Card(
                child: ListTile(
                  onTap: uri != null
                      ? () async {
                          await launch(
                            uri.toString(),
                            forceSafariVC: false,
                            forceWebView: false,
                          );
                        }
                      : null,
                  title: Text(message.notification!.title ?? '', maxLines: 1),
                  subtitle: Text(message.notification!.body ?? '', maxLines: 2),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => OverlaySupportEntry.of(context)!.dismiss(),
                  ),
                ),
              ),
            );
          },
          duration: const Duration(milliseconds: 4000),
        );
      }
    });

    // User clicked on push notification outside of app and the app was still
    // in the background. Open the url or show a dialog.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.containsKey('url') && message.data['url'] is String) {
        final uri = Uri.tryParse(message.data['url'] as String);
        if (uri != null) {
          await launch(
            uri.toString(),
            forceSafariVC: false,
            forceWebView: false,
          );
        }
      } else if (navigatorKey.currentContext != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => PushNotificationDialog(message),
        );
      }
    });

    // User got a push notification outside of the app while the app was not
    // running in the background. Open the url or show a dialog.
    if (initialMessage != null) {
      final message = initialMessage;
      if (message.data.containsKey('url') && message.data['url'] is String) {
        final uri = Uri.tryParse(message.data['url'] as String);
        if (uri != null) {
          await launch(
            uri.toString(),
            forceSafariVC: false,
            forceWebView: false,
          );
        }
      } else if (navigatorKey.currentContext != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => PushNotificationDialog(message),
        );
      }
    }
  }

  ThaliaRouterDelegate(
      {required this.authBloc,
      required Future<FirebaseApp> firebaseInitialization})
      : navigatorKey = GlobalKey<NavigatorState>(),
        _firebaseInitialization = firebaseInitialization {
    _setupFirebaseMessaging();
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Logged out.'),
          ));
        } else if (state is LoggedInAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Logged in.'),
          ));
        } else if (state is FailureAuthState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(state.message ?? 'Logging in failed.'),
          ));
        }
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, authState) async {
          // Setting up pushnotifications on login.
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
          if (authState is! LoggedInAuthState) {
            return const LoginScreen();
          }
          return Navigator(
            key: navigatorKey,
            onPopPage: _onPopPage,
            // Copy the stack with `.toList()` to have the navigator update.
            pages: _stack.toList(),
            observers: [SentryNavigatorObserver()],
          );
        },
      ),
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) return false;
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
    return true;
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    var authState = authBloc.state;
    // Wait for the first non-loading authState, because deeplinks in
    // android are passed before the AuthBloc gets the chance to load.
    if (authState is LoadingAuthState) {
      authState = await authBloc.stream.firstWhere(
        (state) => state is! LoadingAuthState,
      );
    }

    if (authState is! LoggedInAuthState) return SynchronousFuture(null);

    var path = configuration.path;
    var segments = configuration.pathSegments;

    if (segments.isEmpty) {
      // Handle "/".
      _stack
        ..clear()
        ..addAll([
          TypedMaterialPage(child: WelcomeScreen(), name: 'Welcome'),
        ]);
    } else if (RegExp('^/pizzas/?\$').hasMatch(path)) {
      _stack
        ..clear()
        ..addAll([
          TypedMaterialPage(child: WelcomeScreen(), name: 'Welcome'),
          TypedMaterialPage(child: FoodScreen(), name: 'FoodEvent(current)'),
        ]);
    } else if (RegExp('^/events/?\$').hasMatch(path)) {
      _stack
        ..clear()
        ..addAll([
          TypedMaterialPage(child: CalendarScreen(), name: 'Calendar'),
        ]);
    } else if (RegExp('^/events/([0-9]+)/?\$').hasMatch(path)) {
      final pk = int.parse(segments[1]);
      _stack
        ..clear()
        ..addAll([
          TypedMaterialPage(child: CalendarScreen(), name: 'Calendar'),
          TypedMaterialPage(child: EventScreen(pk: pk), name: 'Event($pk)'),
        ]);
    } else if (RegExp('^/members/photos/([a-z0-9-_]+)/?\$').hasMatch(path)) {
      _stack
        ..clear()
        ..addAll([
          TypedMaterialPage(child: AlbumsScreen(), name: 'Albums'),
          TypedMaterialPage(
            child: AlbumScreen(slug: segments[2]),
            name: 'Album(${segments[2]})',
          ),
        ]);
    } else if (RegExp('^/members/([0-9]+)/?\$').hasMatch(path)) {
      final pk = int.parse(segments[1]);
      _stack
        ..clear()
        ..addAll([
          TypedMaterialPage(child: MembersScreen(), name: 'Members'),
          TypedMaterialPage(child: ProfileScreen(pk: pk), name: 'Profile($pk)'),
        ]);
    }
    // TODO: Add SalesOrderDialog back in, waiting for
    //  https://github.com/svthalia/concrexit/issues/1785.
    // else if (RegExp('^/sales/order/([a-f0-9-]+)/pay/?\$').hasMatch(path)) {
    //   final pk = segments[2];
    //   if (navigatorKey.currentContext != null) {
    //     unawaited(showDialog(
    //       context: navigatorKey.currentContext!,
    //       builder: (context) => TPaySalesOrderDialog(pk: pk),
    //     ));
    //   }
    // }

    return SynchronousFuture(null);
  }

  /// Adds a page to the top of the stack.
  void push(TypedMaterialPage page) {
    _stack.add(page);
    notifyListeners();
  }

  /// Removes the top of the stack.
  void pop() {
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
  }

  /// Replaces the top of the stack.
  void replace(TypedMaterialPage page) {
    _stack
      ..removeLast()
      ..add(page);
    notifyListeners();
  }

  /// Replaces the current stack.
  void replaceStack(List<TypedMaterialPage> stack) {
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
