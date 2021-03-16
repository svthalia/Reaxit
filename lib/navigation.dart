import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/auth_provider.dart';
import 'package:reaxit/ui/screens/album_detail.dart';
import 'package:reaxit/ui/screens/album_list.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';
import 'package:reaxit/ui/screens/event_screen.dart';
import 'package:reaxit/ui/screens/login_screen.dart';
import 'package:reaxit/ui/screens/pizza_screen.dart';
import 'package:reaxit/ui/screens/welcome_screen.dart';

class ThaliaRouterDelegate extends RouterDelegate<List<Page>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<Page>> {
  final GlobalKey<NavigatorState> navigatorKey;

  static ThaliaRouterDelegate of(BuildContext context) {
    RouterDelegate delegate = Router.of(context).routerDelegate;
    assert(delegate is ThaliaRouterDelegate, 'Delegate type must match.');
    return delegate as ThaliaRouterDelegate;
  }

  ThaliaRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  List<Page> _stack = [MaterialPage(child: WelcomeScreen())];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.status == AuthStatus.signedOut) {
          _stack
            ..clear()
            ..add(MaterialPage(child: LoginScreen()));
        }

        return Navigator(
          key: navigatorKey,
          onPopPage: _onPopPage,
          pages: auth.status == AuthStatus.init
              ? [MaterialPage(child: _SplashScreen())]
              : _stack.toList(),
        );
      },
    );
  }

  bool _onPopPage(route, result) {
    if (!route.didPop(result)) return false;
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
    return true;
  }

  @override
  Future<void> setNewRoutePath(List<Page> stack) async {
    _stack
      ..clear()
      ..addAll(stack);
    return SynchronousFuture(null);
  }

  /// Adds a page to the top of the stack.
  void push(Page page) {
    _stack.add(page);
    notifyListeners();
  }

  /// Removes the top of the stack.
  void pop() {
    if (_stack.length > 1) _stack.removeLast();
    notifyListeners();
  }

  /// Replaces the top of the stack.
  void replace(Page page) {
    _stack
      ..removeLast()
      ..add(page);
    notifyListeners();
  }

  /// Replaces the current stack.
  void replaceStack(List<Page> stack) {
    _stack
      ..clear()
      ..addAll(stack);
    notifyListeners();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFE62272),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

class ThaliaRouteInformationParser
    implements RouteInformationParser<List<Page>> {
  @override
  Future<List<Page>> parseRouteInformation(routeInformation) async {
    Uri uri = Uri.parse(routeInformation.location);
    String path = uri.path;
    List<String> segments = uri.pathSegments;

    // Handle "/".
    if (uri.pathSegments.length == 0)
      return [MaterialPage(child: WelcomeScreen())];

    if (RegExp('^/pizzas/\$').hasMatch(path)) {
      return [
        MaterialPage(child: WelcomeScreen()),
        MaterialPage(child: PizzaScreen()),
      ];
    } else if (RegExp('^/events/\$').hasMatch(path)) {
      return [MaterialPage(child: CalendarScreen())];
    } else if (RegExp('^/events/([0-9]+)/\$').hasMatch(path)) {
      return [
        MaterialPage(child: CalendarScreen()),
        MaterialPage(child: EventScreen(int.parse(segments[1])))
      ];
    } else if (RegExp('^/members/photos/([0-9]+)/\$').hasMatch(path)) {
      return [
        MaterialPage(child: AlbumList()),
        MaterialPage(child: AlbumDetail(int.parse(segments[1])))
      ];
    }

    // Handle unknown path.
    return [MaterialPage(child: WelcomeScreen())];
  }

  @override
  RouteInformation restoreRouteInformation(configuration) {
    return RouteInformation(location: "/");
  }
}
